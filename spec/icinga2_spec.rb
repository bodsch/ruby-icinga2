
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

  # subject {  }

  describe ' Informations' do

    it 'application_data()' do
      expect(@icinga2.application_data).to be_a(Hash)
    end
    it 'cib_data()' do
      expect(@icinga2.cib_data).to be_a(Hash)
    end
    it 'api_listener()' do
      expect(@icinga2.api_listener).to be_a(Hash)
    end
    it 'version' do
      expect(@icinga2.version).to be_a(String)
    end
    it 'revision' do
      expect(@icinga2.revision).to be_a(String)
    end
  end

  describe ' Module Host' do
    # i.existsHost?( 'icinga2-master' ) ? 'true' : 'false'
    it 'exists_host?()' do
      expect(@icinga2.exists_host?('icinga2')).to be_a(TrueClass)
    end

    it 'count of all hosts' do
      expect(@icinga2.hosts_all).to be_a(Integer)
    end
  end

end
