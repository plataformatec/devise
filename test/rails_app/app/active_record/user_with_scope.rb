# frozen_string_literal: true

require 'shared_user_with_scope'

class UserWithScope < ActiveRecord::Base
  self.table_name = 'users'
  include Shim
  include SharedUserWithScope
end

