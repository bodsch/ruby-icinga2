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
      result = Network.put({
        url: sprintf('%s/v1/objects/hostgroups/%s', @icingaApiUrlBase, name),
        headers: @headers,
        options: @options,
        payload: { 'attrs' => { 'display_name' => display_name } }
      })
      return JSON.pretty_generate(result)
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
      result = Network.delete({
        host: name,
        url: sprintf('%s/v1/objects/hostgroups/%s?cascade=1', @icingaApiUrlBase, name),
        headers: @headers,
        options: @options
      })
      return JSON.pretty_generate(result)
    end

    #
    #
    #
    def list_hostgroups(params = {})
      name = params.dig(:name) || ''
      result = Network.get({
        host: name,
        url: sprintf('%s/v1/objects/hostgroups/%s', @icingaApiUrlBase, name),
        headers: @headers,
        options: @options
      })
      if !result.nil?
        result = JSON.pretty_generate(result)
      end
      return result
    end

    #
    #
    #
    def exists_hostgroups?(name)
      result = list_hostgroups({ name: name })
      if result.is_a?(String)
        result = JSON.parse(result)
      end
      status = result.dig('status')
      if status.nil? && status == 200
        return true
      else
        return false
      end
    end
  end
end
