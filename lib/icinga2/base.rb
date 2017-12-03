module Icinga2

  # namespace for service handling
  module Base
    def validate_options!(params, options)
      options[:optional] ||= []
      options[:required] ||= []

        params = params.deep_symbolize_keys
      assert_required_keys(params, options[:required])
      params.assert_valid_keys(params, options[:required] + options[:optional])
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

  def assert_required_keys(params, *keys)
    keys.flatten.each do |key|
      raise ArgumentError.new("Required key: #{key.inspect}") unless params.key?(key)
    end
  end
end
