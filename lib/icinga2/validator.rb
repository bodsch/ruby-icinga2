
class Hash
  def assert_required_keys(*keys)
    keys.flatten.each do |key|
      raise ArgumentError.new("Required key: #{key.inspect}") unless key?(key)
    end
  end

  def assert_valid_keys(params, *valid_keys)
    valid_keys.flatten!
    params.each_key do |k|
      unless valid_keys.include?(k)
        raise ArgumentError.new("Unknown key: #{k.inspect}. Valid keys are: #{valid_keys.map(&:inspect).join(', ')}")
      end
    end
  end
end


module Icinga2

  # namespace for validate options
  module Validator

    def validate_options!(params, options)
      options[:optional] ||= []
      options[:required] ||= []

      params = params.deep_symbolize_keys
      params.assert_required_keys(options[:required])
      params.assert_valid_keys(params, options[:required] + options[:optional])
    end
  end
end
