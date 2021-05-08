# frozen_string_literal: true

module SharedUserWithScope
  extend ActiveSupport::Concern

  included do
    devise :database_authenticatable, :lockable, :recoverable,
           :registerable, :rememberable, :timeoutable,
           :trackable, :validatable, email_scope: [:username]
  end
end
