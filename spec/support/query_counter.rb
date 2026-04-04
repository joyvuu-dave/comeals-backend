# frozen_string_literal: true

# Counts SQL queries executed during a block, excluding schema/cache queries.
# Extracted from spec/benchmarks/settlement_balances_benchmark_spec.rb for reuse.
#
# Usage in request specs (auto-included via rails_helper):
#   query_count = count_queries { get "/api/v1/..." }
#   expect(query_count).to be <= 15
#
# Usage in model/other specs (include manually):
#   include QueryCounter
module QueryCounter
  def count_queries(&)
    count = 0
    counter = lambda { |*, payload|
      count += 1 unless payload[:name] == 'SCHEMA' || payload[:cached]
    }
    ActiveSupport::Notifications.subscribed(counter, 'sql.active_record', &)
    count
  end
end
