
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
        host: 'localhost',
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

    pending

    # i.applicationData()
    it 'applicationData()' do
#      pending
      assert_equal @icinga2.applicationData
    end
    # i.CIBData()
    it 'CIBData()' do
      pending
    end
    # i.apiListener()
    it 'apiListener()' do
    pending
    end
  end

  describe ' Module Host' do
    pending

    # i.existsHost?( 'icinga2-master' ) ? 'true' : 'false'
    it 'existsHost?()' do
      pending
    end

    # i.hostObjects()
    it 'hostObjects()' do
      pending
    end

    # i.hostProblems()
    it 'hostProblems()' do
      pending
    end

    # i.problemHosts()
    it 'problemHosts()' do
      pending
    end

  end

end
