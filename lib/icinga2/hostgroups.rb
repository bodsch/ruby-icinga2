# encoding: UTF-8
# frozen_string_literal: false

#
#
#
module Icinga2
  #
  #
  #
  module Hostgroups
    #
    #
    #
    def add_hostgroup(params = {})
      name = params.dig(:name)
      display_name = params.dig(:display_name)
      if name.nil?
        return {
          status: 404,
          message: 'no name for the hostgroup'
        }
      end
      result = Network.put(url: format('%s/v1/objects/hostgroups/%s', @icingaApiUrlBase, name),
        headers: @headers,
        options: @options,
        payload: { 'attrs' => { 'display_name' => display_name } })
      JSON.pretty_generate(result)
    end

    #
    #
    #
    def delete_hostgroup(params = {})
      name = params.dig(:name)
      if name.nil?
        return {
          status: 404,
          message: 'no name for the hostgroup'
        }
      end
      result = Network.delete(host: name,
        url: format('%s/v1/objects/hostgroups/%s?cascade=1', @icingaApiUrlBase, name),
        headers: @headers,
        options: @options)
      JSON.pretty_generate(result)
    end

    #
    #
    #
    def hostgroups(params = {})
      name = params.dig(:name) || ''
      result = Network.get(host: name,
        url: format('%s/v1/objects/hostgroups/%s', @icingaApiUrlBase, name),
        headers: @headers,
        options: @options)
      result = JSON.pretty_generate(result) unless result.nil?
      result
    end

    #
    #
    #
    def exists_hostgroups?(name)
      result = list_hostgroups(name: name)
      result = JSON.parse(result) if result.is_a?(String)
      status = result.dig('status')
      if status.nil? && status == 200
        return true
      else
        return false
      end
    end
  end
end
