# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ResidentMailer do
  let(:community) { create(:community, name: "Swan's Way") }
  let(:unit) { create(:unit, community: community) }
  let(:resident) do
    create(:resident, community: community, unit: unit, name: 'Sarah Chen', email: 'sarah@example.com')
  end

  describe '#password_reset_email' do
    before { resident.update!(reset_password_token: 'abc123token') }

    let(:mail) { described_class.password_reset_email(resident) }

    it 'sends to the resident email' do
      expect(mail.to).to eq(['sarah@example.com'])
    end

    it 'has the correct subject' do
      expect(mail.subject).to eq('Reset your password')
    end

    it 'includes the reset token URL in the body' do
      expect(mail.body.encoded).to include('abc123token')
    end

    it 'greets the resident by name' do
      expect(mail.body.encoded).to include('Sarah Chen')
    end
  end

  describe '#rotation_signup_email' do
    let(:rotation) { create(:rotation, community: community) }
    let(:open_dates) { [Date.new(2026, 4, 1), Date.new(2026, 4, 3)] }
    let(:mail) { described_class.rotation_signup_email(resident, rotation, open_dates, community) }

    it 'sends to the resident email' do
      expect(mail.to).to eq(['sarah@example.com'])
    end

    it 'has the correct subject' do
      expect(mail.subject).to eq('Sign up to Cook')
    end
  end

  describe '#new_rotation_email' do
    let(:rotation) { create(:rotation, community: community) }
    let(:mail) { described_class.new_rotation_email(resident, rotation, community) }

    it 'sends to the resident email' do
      expect(mail.to).to eq(['sarah@example.com'])
    end

    it 'has the correct subject' do
      expect(mail.subject).to eq('New Rotation Posted')
    end

    it 'includes the community name' do
      expect(mail.body.encoded).to include('Swan')
    end
  end
end
