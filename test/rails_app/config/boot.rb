# frozen_string_literal: true

unless defined?(DEVISE_ORM)
  DEVISE_ORM = (ENV["DEVISE_ORM"] || :active_record).to_sym
end

module Devise
  module Test
    # Detection for minor differences between Rails versions in tests.

    def self.rails6_and_up?
      Rails::VERSION::MAJOR >= 6
    end

    def self.rails52_and_up?
      Rails::VERSION::MAJOR > 5 || rails52?
    end

    def self.rails52?
      Rails.version.start_with? '5.2'
    end

    def self.rails51?
      Rails.version.start_with? '5.1'
    end

    def self.rails5_and_up?
      Rails::VERSION::MAJOR >= 5
    end

    def self.rails5?
      Rails.version.start_with? '5'
    end
  end
end

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../../../Gemfile', __FILE__)
require 'bundler/setup' if File.exist?(ENV['BUNDLE_GEMFILE'])
