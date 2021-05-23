# frozen_string_literal: true

if defined?(ActionMailer)
  class Devise::Mailer < Devise.parent_mailer.constantize
    include Devise::Mailers::Helpers

    def confirmation_instructions(record, token, opts = {}, &block)
      @token = token
      devise_mail(record, :confirmation_instructions, opts, &block)
    end

    def reset_password_instructions(record, token, opts = {}, &block)
      @token = token
      devise_mail(record, :reset_password_instructions, opts, &block)
    end

    def unlock_instructions(record, token, opts = {}, &block)
      @token = token
      devise_mail(record, :unlock_instructions, opts, &block)
    end

    def email_changed(record, opts = {}, &block)
      devise_mail(record, :email_changed, opts, &block)
    end

    def password_change(record, opts = {}, &block)
      devise_mail(record, :password_change, opts, &block)
    end
  end
end
