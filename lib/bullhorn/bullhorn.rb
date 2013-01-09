require 'savon'
require 'open-uri'
require 'net/https'

require 'bullhorn/util'
require 'bullhorn/client'
require 'bullhorn/categories'
require 'bullhorn/jobs'
require 'bullhorn/files'
require 'bullhorn/candidates'

module Bullhorn

  Savon.configure do |config|

    # TODO Add logger based on environment
    # The default log level used by Savon is :debug.
    config.log_level = :debug

    # In a Rails application you might want Savon to use the Rails logger.
    #config.logger = Rails.logger

    # The XML logged by Savon can be formatted for debugging purposes.
    # Unfortunately, this feature comes with a performance and is not
    # recommended for production environments.
    config.pretty_print_xml = true

  end
end
