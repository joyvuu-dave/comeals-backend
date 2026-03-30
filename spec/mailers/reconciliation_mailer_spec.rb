# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReconciliationMailer do
  let(:community) { create(:community, name: "Swan's Way") }
  let(:unit) { create(:unit, community: community) }
  let(:resident) do
    create(:resident, community: community, unit: unit, name: 'Sarah Chen', email: 'sarah@example.com')
  end

  describe '#reconciliation_notify_email' do
    let(:reconciliation) { create(:reconciliation, community: community) }
    let(:mail) { described_class.reconciliation_notify_email(resident, reconciliation) }

    it 'sends to the resident email' do
      expect(mail.to).to eq(['sarah@example.com'])
    end

    it 'has the correct subject' do
      expect(mail.subject).to eq("Meal Reconciliation #{reconciliation.id}")
    end

    it 'includes the community name' do
      expect(mail.body.encoded).to include('Swan')
    end

    it 'includes a link to view bills' do
      expect(mail.body.encoded).to include('bills')
      expect(mail.body.encoded).to include(reconciliation.id.to_s)
    end
  end

  describe '#common_house_collection_email' do
    let(:mail) { described_class.common_house_collection_email }

    it 'sends to the common house email' do
      expect(mail.to).to eq(['commonhouse@swansway.com'])
    end

    it 'has the correct subject' do
      expect(mail.subject).to eq('Reconciliation Balances')
    end

    it 'includes links to resident and unit balances' do
      expect(mail.body.encoded).to include('Residents')
      expect(mail.body.encoded).to include('Units')
    end
  end
end
