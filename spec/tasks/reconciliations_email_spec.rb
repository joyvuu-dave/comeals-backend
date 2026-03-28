require 'rails_helper'
require 'rake'

RSpec.describe 'reconciliation email tasks' do
  before(:all) do
    Rails.application.load_tasks
  end

  let(:community) { FactoryBot.create(:community) }
  let(:unit) { FactoryBot.create(:unit, community: community) }

  describe 'reconciliations:send_cooking_slot_email' do
    after { Rake::Task['reconciliations:send_cooking_slot_email'].reenable }

    it 'sends notification emails to cooks from the latest reconciliation' do
      cook = FactoryBot.create(:resident, community: community, unit: unit, multiplier: 2)
      meal = FactoryBot.create(:meal, community: community, date: Date.yesterday)
      FactoryBot.create(:bill, meal: meal, resident: cook, community: community, amount: BigDecimal("40"))
      reconciliation = Reconciliation.create!(
        community: community, start_date: 1.year.ago.to_date, end_date: Date.today
      )

      mail_double = instance_double(ActionMailer::MessageDelivery)
      allow(ReconciliationMailer).to receive(:reconciliation_notify_email).and_return(mail_double)
      allow(mail_double).to receive(:deliver_now)

      Rake::Task['reconciliations:send_cooking_slot_email'].invoke

      expect(ReconciliationMailer).to have_received(:reconciliation_notify_email)
        .with(cook, reconciliation).at_least(:once)
    end

    it 'handles email delivery failures gracefully' do
      cook = FactoryBot.create(:resident, community: community, unit: unit, multiplier: 2)
      meal = FactoryBot.create(:meal, community: community, date: Date.yesterday)
      FactoryBot.create(:bill, meal: meal, resident: cook, community: community, amount: BigDecimal("40"))
      Reconciliation.create!(
        community: community, start_date: 1.year.ago.to_date, end_date: Date.today
      )

      mail_double = instance_double(ActionMailer::MessageDelivery)
      allow(ReconciliationMailer).to receive(:reconciliation_notify_email).and_return(mail_double)
      allow(mail_double).to receive(:deliver_now).and_raise(Net::ReadTimeout)
      allow(Rails.logger).to receive(:error)

      expect { Rake::Task['reconciliations:send_cooking_slot_email'].invoke }.not_to raise_error
      expect(Rails.logger).to have_received(:error).with(/reconciliation_notify_email failed/).at_least(:once)
    end
  end

  describe 'reconciliations:send_common_house_collection_email' do
    after { Rake::Task['reconciliations:send_common_house_collection_email'].reenable }

    it 'sends the common house collection email' do
      mail_double = instance_double(ActionMailer::MessageDelivery)
      allow(ReconciliationMailer).to receive(:common_house_collection_email).and_return(mail_double)
      allow(mail_double).to receive(:deliver_now)

      Rake::Task['reconciliations:send_common_house_collection_email'].invoke

      expect(ReconciliationMailer).to have_received(:common_house_collection_email).at_least(:once)
    end

    it 'handles email delivery failures gracefully' do
      mail_double = instance_double(ActionMailer::MessageDelivery)
      allow(ReconciliationMailer).to receive(:common_house_collection_email).and_return(mail_double)
      allow(mail_double).to receive(:deliver_now).and_raise(Net::SMTPAuthenticationError.new("auth failed"))
      allow(Rails.logger).to receive(:error)

      expect { Rake::Task['reconciliations:send_common_house_collection_email'].invoke }.not_to raise_error
      expect(Rails.logger).to have_received(:error).with(/common_house_collection_email failed/).at_least(:once)
    end
  end
end
