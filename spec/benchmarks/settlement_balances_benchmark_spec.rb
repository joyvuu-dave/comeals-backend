require "rails_helper"
require "benchmark"

# This benchmark compares the original N+1 settlement_balances implementation
# against the optimized batch-loaded version. It builds a large dataset (40
# residents, 200 meals, ~5000 attendees, ~1500 guests) and measures wall-clock
# time, SQL query count, object allocations, and CPU time for each.
#
# Run with: BENCHMARK=1 bundle exec rspec spec/benchmarks/settlement_balances_benchmark_spec.rb
#
# MAINTENANCE NOTE: The naive implementation below is a frozen snapshot of the
# original algorithm (before optimization). If the cost calculation formula
# changes, the correctness assertion (expect(optimized).to eq(naive)) will fail.
# This is intentional — update the naive version to match. The authoritative
# correctness tests live in spec/models/reconciliation_spec.rb.

RSpec.describe "Reconciliation#settlement_balances performance", :benchmark, type: :model do
  # ---------------------------------------------------------------------------
  # Helpers
  # ---------------------------------------------------------------------------

  # Count SQL queries executed during a block, excluding schema/cache queries.
  def count_queries(&block)
    count = 0
    counter = lambda { |*, payload|
      unless payload[:name] == "SCHEMA" || payload[:cached]
        count += 1
      end
    }
    ActiveSupport::Notifications.subscribed(counter, "sql.active_record", &block)
    count
  end

  # Run a block and collect all four metrics.
  def measure_all(label, &block)
    result = nil
    GC.start
    alloc_before = GC.stat[:total_allocated_objects]
    cpu_before = Process.times

    query_count = count_queries do
      @_timing = Benchmark.measure { result = block.call }
    end

    cpu_after = Process.times
    alloc_after = GC.stat[:total_allocated_objects]

    {
      label: label,
      result: result,
      wall_time: @_timing.real,
      cpu_user: cpu_after.utime - cpu_before.utime,
      cpu_system: cpu_after.stime - cpu_before.stime,
      query_count: query_count,
      allocations: alloc_after - alloc_before
    }
  end

  # The original N+1 implementation, preserved verbatim for comparison.
  # This is the SLOW version that triggers 6-8 SQL queries per MealResident/Guest
  # via Meal#unit_cost -> Meal#multiplier (not memoized) + Meal#total_cost + Meal#max_cost.
  def naive_settlement_balances(reconciliation)
    balances = {}

    reconciliation.community.residents.find_each do |resident|
      credits = resident.bills.joins(:meal).where(meals: { reconciliation_id: reconciliation.id })
                        .where(no_cost: false).sum(:amount)

      debits = resident.meal_residents.joins(:meal).where(meals: { reconciliation_id: reconciliation.id })
                       .sum(&:cost)

      guest_debits = resident.guests.joins(:meal).where(meals: { reconciliation_id: reconciliation.id })
                             .sum(&:cost)

      raw_balance = credits - debits - guest_debits
      balances[resident.id] = raw_balance.round(2, BigDecimal::ROUND_HALF_EVEN)
    end

    balances
  end

  # ---------------------------------------------------------------------------
  # Benchmark
  # ---------------------------------------------------------------------------

  it "optimized version matches naive results with dramatically fewer queries" do
    # Deterministic RNG for reproducible data.
    srand(42)

    # -- Build community + unit --
    community = FactoryBot.create(:community, cap: BigDecimal("4.50"))
    unit = FactoryBot.create(:unit, community: community)

    # -- Build residents (40: 30 adults, 10 children) --
    now = Time.current
    password_digest = "benchmark_not_a_real_hash"
    resident_rows = 40.times.map do |i|
      {
        community_id: community.id,
        unit_id: unit.id,
        name: "Resident #{i}",
        email: "bench#{i}@example.com",
        password_digest: password_digest,
        multiplier: i < 30 ? 2 : 1,
        active: true,
        can_cook: true,
        vegetarian: false,
        birthday: Date.new(1990, 1, 1),
        created_at: now,
        updated_at: now
      }
    end
    Resident.insert_all(resident_rows)
    residents = Resident.where(community_id: community.id).order(:id).to_a

    # -- Build meals (200, sequential dates, ~30% uncapped) --
    start_date = Date.new(2025, 1, 1)
    end_date = start_date + 199.days
    meal_rows = 200.times.map do |i|
      date = start_date + i.days
      {
        community_id: community.id,
        date: date,
        description: "",
        closed: false,
        cap: i % 3 == 0 ? nil : community.cap, # ~33% uncapped
        start_time: date.wday == 0 ? date.to_datetime + 18.hours : date.to_datetime + 19.hours,
        created_at: now,
        updated_at: now
      }
    end
    Meal.insert_all(meal_rows)
    meals = Meal.where(community_id: community.id).order(:date).to_a

    # -- Build bills (2-3 cooks per meal, ~5% no_cost) --
    bill_rows = meals.flat_map do |meal|
      cook_count = rand(2..3)
      residents.sample(cook_count).map do |cook|
        {
          meal_id: meal.id,
          resident_id: cook.id,
          community_id: community.id,
          amount: BigDecimal(rand(20.0..80.0).round(2).to_s),
          no_cost: rand(100) < 5,
          created_at: now,
          updated_at: now
        }
      end
    end
    Bill.insert_all(bill_rows)

    # -- Build meal_residents (20-30 per meal) --
    mr_rows = meals.flat_map do |meal|
      attendee_count = rand(20..30)
      residents.sample(attendee_count).map do |resident|
        {
          meal_id: meal.id,
          resident_id: resident.id,
          community_id: community.id,
          multiplier: resident.multiplier,
          vegetarian: false,
          late: false,
          created_at: now,
          updated_at: now
        }
      end
    end
    MealResident.insert_all(mr_rows)

    # -- Build guests (5-10 per meal) --
    guest_rows = meals.flat_map do |meal|
      guest_count = rand(5..10)
      residents.sample(guest_count).map do |host|
        {
          meal_id: meal.id,
          resident_id: host.id,
          multiplier: 2,
          name: "Guest of #{host.name}",
          vegetarian: false,
          late: false,
          created_at: now,
          updated_at: now
        }
      end
    end
    Guest.insert_all(guest_rows)

    # -- Create reconciliation (bypass callbacks via insert_all) --
    Reconciliation.insert_all([{
      community_id: community.id,
      start_date: start_date,
      end_date: end_date,
      date: end_date,
      created_at: now,
      updated_at: now
    }])
    reconciliation = Reconciliation.find_by!(community_id: community.id, start_date: start_date, end_date: end_date)
    reconciliation.assign_meals

    # Report dataset size
    total_bills = Bill.where(meal_id: meals.map(&:id)).count
    total_mrs = MealResident.where(meal_id: meals.map(&:id)).count
    total_guests = Guest.where(meal_id: meals.map(&:id)).count

    # -- Run naive (N+1) implementation --
    naive = measure_all("Naive (N+1)") { naive_settlement_balances(reconciliation) }

    # Clear all caches between runs
    reconciliation.reload
    ActiveRecord::Base.connection.clear_query_cache

    # -- Run optimized implementation --
    optimized = measure_all("Optimized (batch)") { reconciliation.settlement_balances }

    # -----------------------------------------------------------------------
    # Assertions
    # -----------------------------------------------------------------------

    # Correctness: both must produce identical balances.
    expect(optimized[:result]).to eq(naive[:result]),
      "Optimized and naive implementations produced different balances!\n" \
      "Diff: #{(naive[:result].keys | optimized[:result].keys).select { |k| naive[:result][k] != optimized[:result][k] }.map { |k| "resident #{k}: naive=#{naive[:result][k]} opt=#{optimized[:result][k]}" }.join(', ')}"

    # Performance: optimized must use dramatically fewer queries.
    expect(optimized[:query_count]).to be < (naive[:query_count] / 10),
      "Expected at least 10x query reduction. Naive: #{naive[:query_count]}, Optimized: #{optimized[:query_count]}"

    # -----------------------------------------------------------------------
    # Report
    # -----------------------------------------------------------------------

    query_speedup = naive[:query_count].to_f / optimized[:query_count]
    time_speedup = naive[:wall_time] / [optimized[:wall_time], 0.0001].max
    alloc_ratio = naive[:allocations].to_f / [optimized[:allocations], 1].max
    naive_cpu = naive[:cpu_user] + naive[:cpu_system]
    opt_cpu = optimized[:cpu_user] + optimized[:cpu_system]
    cpu_speedup = naive_cpu / [opt_cpu, 0.0001].max

    puts "\n"
    puts "=" * 72
    puts "  SETTLEMENT BALANCES BENCHMARK"
    puts "  Dataset: #{residents.size} residents, #{meals.size} meals, " \
         "#{total_bills} bills, #{total_mrs} attendees, #{total_guests} guests"
    puts "  Note: Goldiloader is active — naive query count reflects batched meal loads"
    puts "=" * 72
    puts ""
    puts format("  %-24s %18s %18s %10s", "", "Naive (N+1)", "Optimized", "Speedup")
    puts "  " + "-" * 70
    puts format("  %-24s %17.3fs %17.3fs %9.0fx", "Wall clock time",
                naive[:wall_time], optimized[:wall_time], time_speedup)
    puts format("  %-24s %18d %18d %9.0fx", "SQL queries",
                naive[:query_count], optimized[:query_count], query_speedup)
    puts format("  %-24s %18s %18s %9.0fx", "Objects allocated",
                naive[:allocations].to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse,
                optimized[:allocations].to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse,
                alloc_ratio)
    puts format("  %-24s %17.3fs %17.3fs %9.0fx", "CPU time (user+sys)",
                naive_cpu, opt_cpu, cpu_speedup)
    puts ""
    puts "  Correctness: PASS (both implementations produce identical balances)"
    puts "=" * 72
    puts ""
  end
end
