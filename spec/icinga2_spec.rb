
# frozen_string_literal: true
require 'spec_helper'
require 'rspec'
require 'icinga2'

RSpec.configure do |config|
  config.mock_with :rspec
end

describe Icinga2 do

  before do

    config = {
      icinga: {
        host: '192.168.33.5',
        api: {
          port: 5665,
          user: 'root',
          password: 'icinga'
        },
        cluster: false,
        satellite: nil
      }
    }

    @icinga2  = Icinga2::Client.new( config )
  end

  describe 'Information' do
    it 'status_data' do
      expect(@icinga2.status_data).to be_a(Hash)
    end

    it 'application_data' do
      expect(@icinga2.application_data).to be_a(Hash)
    end

    it 'cib_data' do
      expect(@icinga2.cib_data).to be_a(Hash)
    end
    it 'api_listener' do
      expect(@icinga2.api_listener).to be_a(Hash)
    end

    it 'version' do
      @icinga2.application_data
      v, r = @icinga2.version
      expect(v).to be_a(String)
      expect(r).to be_a(String)
    end

    it 'node name' do
      @icinga2.application_data
      n = @icinga2.node_name
      expect(n).to be_a(String)
    end

    it 'start time' do
      @icinga2.application_data
      expect(@icinga2.start_time).to be_a(Time)
    end

    it 'uptime' do
      @icinga2.cib_data
      expect(@icinga2.uptime).to be_a(String)
    end


  end

  describe 'Module Host' do

    it 'exists_host?()' do
      expect(@icinga2.exists_host?('icinga2')).to be_a(TrueClass)
    end
    it 'exists_host?()' do
      expect(@icinga2.exists_host?('test')).to be_a(FalseClass)
    end
    it 'count of all hosts' do
      @icinga2.host_objects
      expect(@icinga2.hosts_all).to be_a(Integer)
    end
  end

end
