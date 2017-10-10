# frozen_string_literal: true

require 'ruby_dig' if RUBY_VERSION < '2.3'

require 'rest-client'
require 'openssl'

require 'json'
require 'net/http'
require 'uri'

require_relative 'logging'
require_relative 'monkey_patches'
require_relative 'icinga2/client'

module Icinga2
end
