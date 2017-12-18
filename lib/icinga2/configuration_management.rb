
# frozen_string_literal: true

module Icinga2

  # namespace for config packages
  #
  # The main idea behind configuration management is to allow external applications creating configuration packages and stages based on configuration files and directory trees.
  # This replaces any additional SSH connection and whatnot to dump configuration files to Icinga 2 directly.
  # In case you are pushing a new configuration stage to a package, Icinga 2 will validate the configuration asynchronously and populate a status log which can be fetched in a separated request.
  #
  module ConfigurationManagement

    # Send a POST request to a new config package called example-cmdb in this example. This will create a new empty configuration package.
    # https://www.icinga.com/docs/icinga2/latest/doc/12-icinga2-api/#creating-a-config-package
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

    #
    # https://www.icinga.com/docs/icinga2/latest/doc/12-icinga2-api/#uploading-configuration-for-a-config-package
    #
    #
    # @param [Hash] params
    # @option params [String] package name of the package
    # @option params [String] name name for the package
    # @option params [Bool] cluser (false) package for an satellite
    # @option params [Bool] reload (true) reload icinga2 after upload
    # @option params [String] vars
    #
    #
    #
    def upload_config_package(params)

      raise ArgumentError.new(format('wrong type. \'params\' must be an Hash, given \'%s\'', params.class.to_s)) unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing params') if( params.size.zero? )

      package = validate( params, required: true, var: 'package', type: String )
#       stage   = validate( params, required: true, var: 'stage', type: String )
      name    = validate( params, required: true, var: 'name', type: String )
      cluster = validate( params, required: false, var: 'cluster', type: Boolean ) || false
      vars    = validate( params, required: false, var: 'vars', type: String )
      reload  = validate( params, required: false, var: 'reload', type: Boolean ) || true

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

    #
    # https://www.icinga.com/docs/icinga2/latest/doc/12-icinga2-api/#list-configuration-packages-and-their-stages
    #
    # @return [Hash]
    # {"active-stage"=>"icinga2-master.matrix.lan-1513500648-0", "name"=>"_api", "stages"=>["icinga2-master.matrix.lan-1513500648-0"]}
    #
    def list_config_packages

      get(
        url: format( '%s/config/packages', @icinga_api_url_base ),
        headers: @headers,
        options: @options
      )
    end


    #
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


    #
    # https://www.icinga.com/docs/icinga2/latest/doc/12-icinga2-api/#fetch-configuration-package-stage-files
    def fetch_config_stages(params)

      raise ArgumentError.new(format('wrong type. \'params\' must be an Hash, given \'%s\'', params.class.to_s)) unless( params.is_a?(Hash) )
      raise ArgumentError.new('missing params') if( params.size.zero? )

      package = validate( params, required: true, var: 'package', type: String )
      stage   = validate( params, required: true, var: 'stage', type: String )
      name    = validate( params, required: true, var: 'name', type: String )
      cluster = validate( params, required: false, var: 'cluster', type: Boolean ) || false

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

    #
    # https://www.icinga.com/docs/icinga2/latest/doc/12-icinga2-api/#configuration-package-stage-errors
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
    # https://www.icinga.com/docs/icinga2/latest/doc/12-icinga2-api/#deleting-configuration-package-stage
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
    # https://www.icinga.com/docs/icinga2/latest/doc/12-icinga2-api/#deleting-configuration-package
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
