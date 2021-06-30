# frozen_string_literal: true

require "test_helper"

class MailerTest < ActionMailer::TestCase
  test "pass given block to #mail call" do
    class TestMailer < Devise::Mailer
      def confirmation_instructions(record, token, opts = {})
        @token = token
        devise_mail(record, :confirmation_instructions, opts) do |format|
          format.html(content_transfer_encoding: "7bit")
        end
      end
    end

    mail = TestMailer.confirmation_instructions(create_user, "confirmation-token")

    assert mail.content_transfer_encoding, "7bit"
  end

  test "emails multi-part if mailer_formats contains multiple formats" do
    begin
      Devise.mailer_formats = [:html, :text]
      mail = Devise::Mailer.email_changed(create_user)
      assert mail.multipart?
    ensure
      Devise.mailer_formats = [:html]
    end
  end
end
