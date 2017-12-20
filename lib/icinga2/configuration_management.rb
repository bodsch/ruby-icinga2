
# frozen_string_literal: true

module Icinga2

  # namespace for config packages
  #
  # The main idea behind configuration management is to allow external applications creating configuration packages and stages based on configuration files and directory trees.
  #
  # This replaces any additional SSH connection and whatnot to dump configuration files to Icinga 2 directly.
  #
  # In case you are pushing a new configuration stage to a package, Icinga 2 will validate the configuration asynchronously and populate a status log which can be fetched in a separated request.
  #
  # original API Documentation: https://www.icinga.com/docs/icinga2/latest/doc/12-icinga2-api/#configuration-management
  #
  module ConfigurationManagement

    # create a new empty configuration package.
    #
    # Package names starting with an underscore are reserved for internal packages and can not be used.
    #
    # @param [String] name the name for the new package.
    #
    # @example
    #    create_config_package('cfg-package')
    #
    # @return [Hash]
    #
    def create_config_package(name)

      raise ArgumentError.new(format('wrong type. \'name\' must be an String, given \'%s\'', name.class.to_s)) unless( name.is_a?(String) )
      raise ArgumentError.new('missing \'name\'') if( name.size.zero? )

      return { 'code' => 404, 'name' => name, 'status' => 'Package names starting with an underscore are reserved for internal packages and can not be used.'  } if( name.initial == '_' )

      post(
        url: format( '%s/config/packages/%s', @icinga_api_url_base, name ),
        headers: @headers,
        options: @options
      )
    end

    # Configuration files in packages are managed in stages.
    # Stages provide a way to maintain multiple configuration versions for a package.
    #
    # @param [Hash] params
    # @option params [String] package name of the package
    # @option params [String] name name for the package
    # @option params [Bool] cluser (false) package for an satellite
    # @option params [Bool] reload (true) reload icinga2 after upload
    # @option params [String] vars
    #
    # @example
    #    params = {
    #      package: 'cfg-package',
    #      name: 'host1',
    #      cluster: false,
    #      vars:  'object Host "cmdb-host" { chec_command = "dummy" }',
    #      reload: false
    #    }
    #    upload_config_package(params)
    #
    # @return [Hash]
    #
    def upload_config_package(params)

      raise ArgumentError.new(format('wrong type. \'params\' must be an Hash, given \'%s\'', params.class.to_s)) unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing params') if( params.size.zero? )

      package = validate( params, required: true, var: 'package', type: String )
      name    = validate( params, required: true, var: 'name', type: String )
      cluster = validate( params, required: false, var: 'cluster', type: Boolean ) || false
      vars    = validate( params, required: false, var: 'vars', type: String )
      reload  = validate( params, required: false, var: 'reload', type: Boolean ) || true
      name    = name.gsub('.conf','')

      return { 'code' => 404, 'status' => format('no package \'%s\' exists', package) } unless(package_exists?(package))

      path = 'conf.d'
      path = 'zones.d/satellite' if(cluster)
      file = format( '%s/%s.conf', path, name )

      payload = {
        'files' => {
          file.to_s => vars
        },
        'reload' => reload
      }

      post(
        url: format( '%s/config/stages/%s', @icinga_api_url_base, package ),
        headers: @headers,
        options: @options,
        payload: payload
      )
    end

    # A list of packages.
    #
    # @example
    #    list_config_packages
    #
    # @return [Hash]
    #
    def list_config_packages

      get(
        url: format( '%s/config/packages', @icinga_api_url_base ),
        headers: @headers,
        options: @options
      )
    end

    # A list of packages and their stages.
    #
    # @param [Hash] params
    # @option params [String] package
    # @option params [String] stage
    #
    # @example
    #    params = {
    #      package: 'cfg-package',
    #      stage: 'example.localdomain-1441625839-0'
    #    }
    #    list_config_stages(params)
    #
    # @return [Hash]
    #
    def list_config_stages(params)

      raise ArgumentError.new(format('wrong type. \'params\' must be an Hash, given \'%s\'', params.class.to_s)) unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing params') if( params.size.zero? )

      package = validate( params, required: true, var: 'package', type: String )
      stage   = validate( params, required: true, var: 'stage', type: String )

      get(
        url: format( '%s/config/stages/%s/%s', @icinga_api_url_base, package, stage ),
        headers: @headers,
        options: @options
      )
    end


    # fetched the whole config package and return them as a String.
    #
    # @param [Hash] params
    # @option params [String] package
    # @option params [String] stage
    # @option params [Bool] cluser (false) package for an satellite
    # @option params [String] name
    #
    # @example
    #    params = {
    #      package: 'cfg-package',
    #      stage: 'example.localdomain-1441625839-0',
    #      name: 'host1',
    #      cluster: false
    #    }
    #    fetch_config_stages(params)
    #
    # @return [String]
    #
    def fetch_config_stages(params)

      raise ArgumentError.new(format('wrong type. \'params\' must be an Hash, given \'%s\'', params.class.to_s)) unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing params') if( params.size.zero? )

      package = validate( params, required: true, var: 'package', type: String )
      stage   = validate( params, required: true, var: 'stage', type: String )
      name    = validate( params, required: true, var: 'name', type: String )
      cluster = validate( params, required: false, var: 'cluster', type: Boolean ) || false
      name    = name.gsub('.conf','')

      return { 'code' => 404, 'status' => format('no package \'%s\' exists', package) } unless(package_exists?(package))

      path = 'conf.d'
      path = 'zones.d/satellite' if(cluster)
      file = format( '%s/%s/%s/%s.conf', package, stage, path, name )

      get(
        url: format( '%s/config/files/%s', @icinga_api_url_base, file ),
        headers: {},
        options: @options
      )
    end

    # fetch the startup.log from the named packe / stage combination to see possible errors.
    #
    # @param [Hash] params
    # @option params [String] package
    # @option params [String] stage
    # @option params [Bool] cluser (false) package for an satellite
    #
    # @example
    #    params = {
    #      package: 'cfg-package',
    #      stage: 'example.localdomain-1441625839-0',
    #      cluster: false
    #    }
    #    package_stage_errors(params)
    #
    # @return [String]
    #
    def package_stage_errors(params)

      raise ArgumentError.new(format('wrong type. \'params\' must be an Hash, given \'%s\'', params.class.to_s)) unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing params') if( params.size.zero? )

      package = validate( params, required: true, var: 'package', type: String )
      stage   = validate( params, required: true, var: 'stage', type: String )
      cluster = validate( params, required: false, var: 'cluster', type: Boolean ) || false

      return { 'code' => 404, 'status' => format('no package \'%s\' exists', package) } unless(package_exists?(package))

      file = format( '%s/%s/startup.log', package, stage )

      get(
        url: format( '%s/config/files/%s', @icinga_api_url_base, file ),
        headers: {},
        options: @options
      )
    end

    # Deleting Configuration Package Stage
    #
    # @param [Hash] params
    # @option params [String] package
    # @option params [String] stage
    #
    # @example
    #    params = {
    #      package: 'cfg-package',
    #      stage: 'example.localdomain-1441625839-0',
    #      cluster: false
    #    }
    #    remove_config_stage(params)
    #
    # @return [Hash]
    #
    def remove_config_stage(params)

      raise ArgumentError.new(format('wrong type. \'params\' must be an Hash, given \'%s\'', params.class.to_s)) unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing params') if( params.size.zero? )

      package = validate( params, required: true, var: 'package', type: String )
      stage   = validate( params, required: true, var: 'stage', type: String )

      return { 'code' => 404, 'name' => package, 'status' => 'Package names starting with an underscore are reserved for internal packages and can not be used.'  } if( package.initial == '_' )
      return { 'code' => 404, 'status' => format('no package \'%s\' exists', name) } unless(package_exists?(package))

      delete(
        url: format( '%s/config/stages/%s/%s', @icinga_api_url_base, package, stage ),
        headers: @headers,
        options: @options
      )
    end

    # Deleting Configuration Package
    #
    # @param [String] name the name for the package.
    #
    # @example
    #    remove_config_package('cfg-package')
    #
    # @return [Hash]
    #
    def remove_config_package(name)

      raise ArgumentError.new(format('wrong type. \'name\' must be an String, given \'%s\'', name.class.to_s)) unless( name.is_a?(String) )
      raise ArgumentError.new('missing \'name\'') if( name.size.zero? )

      return { 'code' => 404, 'name' => name, 'status' => 'Package names starting with an underscore are reserved for internal packages and can not be used.'  } if( name.initial == '_' )
      return { 'code' => 404, 'status' => format('no package \'%s\' exists', name) } unless(package_exists?(name))

      delete(
        url: format( '%s/config/packages/%s', @icinga_api_url_base, name ),
        headers: @headers,
        options: @options
      )
    end

    # check if a package exists
    #
    # @param [String] name the name for the package.
    #
    # @example
    #    package_exists?('cfg-package')
    #
    # @return [Bool]
    #
    def package_exists?(name)

      raise ArgumentError.new(format('wrong type. \'name\' must be an String, given \'%s\'', name.class.to_s)) unless( name.is_a?(String) )
      raise ArgumentError.new('missing \'name\'') if( name.size.zero? )

      current_packages = list_config_packages

      return { 'code' => 404, 'status' => 'error to get packages' } if( current_packages.nil? && current_packages.dig('code') != 200 )

      current_packages = current_packages.dig('results')

      data = current_packages.select { |k,v| k['name'] == name }
      data = data.first if( data )

      return false unless(data)

      true
    end

  end
end
