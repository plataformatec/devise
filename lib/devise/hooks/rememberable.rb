# frozen_string_literal: true

# This hook runs when a user logs in, if they set the `remember_me` param (eg. from a checkbox in the UI).
Warden::Manager.after_set_user except: :fetch do |record, warden, options|
  scope = options[:scope]
  if record.respond_to?(:remember_me) && options[:store] != false &&
     record.remember_me && warden.authenticated?(scope)

    Devise::Hooks::Proxy.new(warden).remember_me(record)
  end
end

# This hook runs when we retrieve a user from the session. If the user's remember session should be extended
# we do it here.
Warden::Manager.after_set_user only: :fetch do |record, warden, options|
  if record.respond_to?(:extend_remember_me?) && record.extend_remember_me? &&
      options[:store] != false && warden.authenticated?(options[:scope])

    Devise::Hooks::Proxy.new(warden).remember_me(record)
  end
end
