
# frozen_string_literal: true

module Icinga2

  # namespace for User handling
  module Users

    # add a user
    #
    # @param [Hash] params
    # @option params [String] :name user to create
    # @option params [String] :display_name the displayed name
    # @option params [String] :email ('') the user email
    # @option params [String] :pager ('') optional a pager
    # @option params [Bool] :enable_notifications (false) enable notifications for this user
    # @option params [Array] :groups ([]) a hash with groups
    #
    # @example
    #   @icinga.add_user(name: 'foo', display_name: 'FOO', email: 'foo@bar.com', pager: '0000', groups: ['icingaadmins'])
    #
    # @return [Hash] result
    #
    def add_user( params = {} )

      name          = params.dig(:name)
      display_name  = params.dig(:display_name)
      email         = params.dig(:email)
      pager         = params.dig(:pager)
      notifications = params.dig(:enable_notifications) || false
      groups        = params.dig(:groups) || []

      if( name.nil? )
        return {
          status: 404,
          message: 'missing user name'
        }
      end

      unless( groups.is_a?( Array ) )
        return {
          status: 404,
          message: 'groups must be an array',
          data: params
        }
      end

      payload = {
        'attrs' => {
          'display_name'         => display_name,
          'email'                => email,
          'pager'                => pager,
          'enable_notifications' => notifications
        }
      }

      payload['attrs']['groups'] = groups unless  groups.empty?

      group_validate = []

      groups.each do |g|
        group_validate << g if  exists_usergroup?( g ) == false
      end

      if( group_validate.count != 0 )

        groups = group_validate.join(', ')

        return {
          status: 404,
          message: "these groups are not exists: #{groups}",
          data: params
        }
      end

      Network.put(         host: name,
        url: format( '%s/objects/users/%s', @icinga_api_url_base, name ),
        headers: @headers,
        options: @options,
        payload: payload )

      # result:
      #   {:status=>200, :name=>nil, :message=>"Object was created"}
    end

    # delete a user
    #
    # @param [Hash] params
    # @option params [String] :name user to delete
    #
    # @example
    #   @icinga.delete_user(name: 'foo')
    #
    # @return [Hash] result
    #
    def delete_user( params = {} )

      name = params.dig(:name)

      if( name.nil? )
        return {
          status: 404,
          message: 'missing user name'
        }
      end

      Network.delete(         host: name,
        url: format( '%s/objects/users/%s?cascade=1', @icinga_api_url_base, name ),
        headers: @headers,
        options: @options )

      # result:
      #   {:status=>200, :name=>"foo", :message=>"Object was deleted."}
    end

    # returns all users
    #
    # @param [Hash] params
    # @option params [String] :name ('') optional for a single user
    #
    # @example to get all users
    #    @icinga.users
    #
    # @example to get one user
    #    @icinga.users(name: 'icingaadmin')
    #
    # @return [Hash] returns a hash with all users
    #
    def users( params = {} )

      name = params.dig(:name)

      Network.get(         host: name,
        url: format( '%s/objects/users/%s', @icinga_api_url_base, name ),
        headers: @headers,
        options: @options )

      # result:
      #  - named user:
      #   {:status=>200, :data=>{"icingaadmin"=>{:name=>"icingaadmin", :display_name=>"Icinga 2 Admin", :type=>"User"}}}
      #  - all users:
      #   {:status=>200, :data=>{"icingaadmin"=>{:name=>"icingaadmin", :display_name=>"Icinga 2 Admin", :type=>"User"}, "foo"=>{:name=>"foo", :display_name=>"FOO", :type=>"User"}}}
    end

    # returns true if the user exists
    #
    # @param [String] name the name of the user
    #
    # @example
    #    @icinga.exists_user?('icingaadmin')
    #
    # @return [Bool] returns true if the user exists
    def exists_user?( name )

      result = users( name: name )
      result = JSON.parse( result ) if  result.is_a?( String )
      status = result.dig(:status)

      return true if  !status.nil? && status == 200
      false
    end

  end
end
