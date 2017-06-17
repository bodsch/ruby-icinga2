
# frozen_string_literal: false

module Icinga2

  # namespache for tools
  module Tools

    # returns true for the last check
    # @private
    #
    # @param [Hash] object
    #
    # @return [Bool]
    #
    def object_has_been_checked?(object)
      object.dig('attrs', 'last_check').positive?
    end

  end
end
