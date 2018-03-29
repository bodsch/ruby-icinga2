
# class Hash
#   def assert_required_keys(*keys)
#     keys.flatten.each do |key|
#       raise ArgumentError.new("Required key: #{key.inspect}") unless key?(key)
#     end
#   end
#
#   def assert_valid_keys(params, *valid_keys)
#     valid_keys.flatten!
#     params.each_key do |k|
#       unless valid_keys.include?(k)
#         raise ArgumentError.new("Unknown key: #{k.inspect}. Valid keys are: #{valid_keys.map(&:inspect).join(', ')}")
#       end
#     end
#   end
# end


module Icinga2

  # namespace for validate options
  module Validator

#     def validate_options!(params, options)
#       options[:optional] ||= []
#       options[:required] ||= []
#
#       params = params.deep_symbolize_keys
#       params.assert_required_keys(options[:required])
#       params.assert_valid_keys(params, options[:required] + options[:optional])
#     end

    # function to validate function parameters
    #
    # @param [Hash] params
    # @param [Hash] options
    # @option options [Bool] requiered
    # @option options [String] vat
    # @option options [Object] type Ruby Object to check the valid type. e.g String, Ineger Hash, ...
    #
    # @example
    #    name = validate( params, required: true, var: 'name', type: String )
    #    vars = validate( params, required: false, var: 'vars', type: Hash )
    #
    # @return [Mixed] the variable from the parmas Hash or nil
    #
    def validate( params, options )
      required = options.dig(:required) || false
      var      = options.dig(:var)
      type     = options.dig(:type)

      params   = params.deep_symbolize_keys
      variable = params.dig(var.to_sym)

      clazz = Object.const_get(type.to_s)

      raise ArgumentError.new(format('\'%s\' is requiered and missing!', var)) if(variable.nil? && required == true )
      raise ArgumentError.new(format('wrong type. \'%s\' must be an %s, given \'%s\'', var, type, variable.class.to_s)) unless( variable.nil? || variable.is_a?(clazz) )

      variable
    end

  end
end
