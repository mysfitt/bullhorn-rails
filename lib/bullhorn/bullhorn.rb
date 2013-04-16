require 'savon'
require 'open-uri'
require 'net/https'

require 'bullhorn/util'
require 'bullhorn/client'
require 'bullhorn/categories'
require 'bullhorn/jobs'
require 'bullhorn/jobsubmission'
require 'bullhorn/files'
require 'bullhorn/candidates'
require 'bullhorn/api'

module Bullhorn

  Savon.configure do |config|
    rails_env = "development"
    ENV["RAILS_ENV"] ||= Rails.env if defined?(Rails)
    rails_env = ENV["RAILS_ENV"] if ENV["RAILS_ENV"]
    if rails_env == "development"
      # log at debug level only in development.
      # The default log level used by Savon is :debug.
      config.log_level = :debug
      # In a Rails application you might want Savon to use the Rails logger.
      config.logger = Rails.logger

      # The XML logged by Savon can be formatted for debugging purposes.
      # Unfortunately, this feature comes with a performance and is not
      # recommended for production environments.
      config.pretty_print_xml = true
    else
      # be quiet(ish) in production
      config.log_level = :info
    end
  end
end
