require 'rails_helper'

RSpec.describe MailInterceptor do
  around do |example|
    original = ENV['MAIL_INTERCEPT_TO']
    ENV['MAIL_INTERCEPT_TO'] = 'intercepted@example.com'
    example.run
  ensure
    ENV['MAIL_INTERCEPT_TO'] = original
  end

  describe '.delivering_email' do
    let(:message) do
      Mail::Message.new(
        to: 'resident@example.com',
        cc: 'cc@example.com',
        bcc: 'bcc@example.com',
        subject: 'Reset your password'
      )
    end

    before do
      MailInterceptor.delivering_email(message)
    end

    it 'redirects the recipient to MAIL_INTERCEPT_TO' do
      expect(message.to).to eq(['intercepted@example.com'])
    end

    it 'prepends the original recipient to the subject' do
      expect(message.subject).to eq('[To: resident@example.com] Reset your password')
    end

    it 'clears cc' do
      expect(message.cc).to be_nil
    end

    it 'clears bcc' do
      expect(message.bcc).to be_nil
    end
  end

  describe '.delivering_email with multiple recipients' do
    let(:message) do
      Mail::Message.new(
        to: ['alice@example.com', 'bob@example.com'],
        subject: 'New Rotation Posted'
      )
    end

    before do
      MailInterceptor.delivering_email(message)
    end

    it 'includes all original recipients in the subject' do
      expect(message.subject).to eq('[To: alice@example.com, bob@example.com] New Rotation Posted')
    end

    it 'redirects to the single intercepted address' do
      expect(message.to).to eq(['intercepted@example.com'])
    end
  end
end
