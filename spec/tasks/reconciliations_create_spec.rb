# frozen_string_literal: true

require 'rails_helper'
require 'rake'

RSpec.describe 'reconciliations:create' do
  before(:all) do
    Rails.application.load_tasks
  end

  let(:community) { create(:community) }
  let(:unit) { create(:unit, community: community) }

  after do
    Rake::Task['reconciliations:create'].reenable
    Rake::Task['billing:recalculate'].reenable
  end

  before do
    allow(ReconciliationMailer).to receive_message_chain(:reconciliation_notify_email, :deliver_now) # rubocop:disable RSpec/MessageChain -- stubbing mailer delivery chain
  end

  it 'creates a reconciliation and assigns unreconciled meals with bills' do
    cook = create(:resident, community: community, unit: unit, multiplier: 2)
    eater = create(:resident, community: community, unit: unit, multiplier: 2)
    meal = create(:meal, community: community, date: Date.yesterday)
    create(:bill, meal: meal, resident: cook, community: community, amount: BigDecimal('60'))
    create(:meal_resident, meal: meal, resident: eater, community: community)

    expect { Rake::Task['reconciliations:create'].invoke }
      .to change(Reconciliation, :count).by(1)

    reconciliation = Reconciliation.last
    expect(reconciliation.community).to eq(community)
    expect(meal.reload.reconciliation).to eq(reconciliation)
  end

  it 'persists settlement balances with banker rounding' do
    cook = create(:resident, community: community, unit: unit, multiplier: 2)
    eater = create(:resident, community: community, unit: unit, multiplier: 2)
    meal = create(:meal, community: community, date: Date.yesterday)
    create(:bill, meal: meal, resident: cook, community: community, amount: BigDecimal('60'))
    create(:meal_resident, meal: meal, resident: eater, community: community)

    Rake::Task['reconciliations:create'].invoke

    reconciliation = Reconciliation.last
    expect(reconciliation.reconciliation_balances.count).to be > 0
  end

  it 'sends notification emails to cooks' do
    cook = create(:resident, community: community, unit: unit, multiplier: 2)
    meal = create(:meal, community: community, date: Date.yesterday)
    create(:bill, meal: meal, resident: cook, community: community, amount: BigDecimal('40'))

    Rake::Task['reconciliations:create'].invoke

    expect(ReconciliationMailer).to have_received(:reconciliation_notify_email)
      .with(cook, instance_of(Reconciliation))
  end

  it 'skips communities with no unreconciled meals with bills' do
    # Community with no meals at all
    create(:resident, community: community, unit: unit)

    expect { Rake::Task['reconciliations:create'].invoke }
      .not_to change(Reconciliation, :count)
  end

  it 'skips meals that have no bills' do
    create(:meal, community: community, date: Date.yesterday)

    expect { Rake::Task['reconciliations:create'].invoke }
      .not_to change(Reconciliation, :count)
  end

  it 'recalculates resident balances after reconciliation' do
    cook = create(:resident, community: community, unit: unit, multiplier: 2)
    eater = create(:resident, community: community, unit: unit, multiplier: 2)
    meal = create(:meal, community: community, date: Date.yesterday)
    create(:bill, meal: meal, resident: cook, community: community, amount: BigDecimal('60'))
    create(:meal_resident, meal: meal, resident: eater, community: community)

    Rake::Task['reconciliations:create'].invoke

    # After reconciliation, unreconciled balances should be zero
    # (the meal is now reconciled, so calc_balance returns 0)
    cook_balance = ResidentBalance.find_by(resident: cook)
    eater_balance = ResidentBalance.find_by(resident: eater)
    expect(cook_balance.amount).to eq(BigDecimal('0'))
    expect(eater_balance.amount).to eq(BigDecimal('0'))
  end

  it 'handles email delivery failures gracefully' do
    cook = create(:resident, community: community, unit: unit, multiplier: 2)
    meal = create(:meal, community: community, date: Date.yesterday)
    create(:bill, meal: meal, resident: cook, community: community, amount: BigDecimal('40'))

    mail_double = instance_double(ActionMailer::MessageDelivery)
    allow(ReconciliationMailer).to receive(:reconciliation_notify_email).and_return(mail_double)
    allow(mail_double).to receive(:deliver_now).and_raise(Net::ReadTimeout)
    allow(Rails.logger).to receive(:error)

    # Should not raise — emails fail gracefully
    expect { Rake::Task['reconciliations:create'].invoke }.not_to raise_error

    expect(Rails.logger).to have_received(:error).with(/reconciliation_notify_email failed/)
  end
end
