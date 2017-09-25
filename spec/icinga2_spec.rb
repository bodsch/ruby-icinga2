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
        host: ENV.fetch( 'ICINGA_HOST', 'localhost' ),
        api: {
          port: 5665,
          user: 'root',
          password: 'icinga'
        }
      }
    }

    @test_host = 'icinga2-default'
    @icinga2   = Icinga2::Client.new( config )
  end

  describe 'Available' do

    it 'available' do
      expect(@icinga2.available?).to be_truthy
    end
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
      v = @icinga2.version
      expect(v).to be_a(Hash)
      expect(v.count).to be == 2
      expect(v.dig(:version)).to be_a(String)
      expect(v.dig(:revision)).to be_a(String)
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

  describe 'Module Statistics' do

    it 'average' do
      @icinga2.cib_data
      latency, execution_time = @icinga2.average_statistics.values
      expect(latency).to be_a(Float)
      expect(execution_time).to be_a(Float)
    end

    it 'interval' do
      @icinga2.cib_data
      i = @icinga2.interval_statistics
      expect(i).to be_a(Hash)
      expect(i.count).to be == 4
      expect(i.dig(:hosts_active_checks)).to be_a(Float)
      expect(i.dig(:hosts_passive_checks)).to be_a(Float)
      expect(i.dig(:services_active_checks)).to be_a(Float)
      expect(i.dig(:services_passive_checks)).to be_a(Float)
    end

    it 'service' do
      @icinga2.cib_data
      s = @icinga2.service_statistics
      expect(s).to be_a(Hash)
      expect(s.count).to be == 7
      expect(s.dig(:ok)).to be_a(Integer)
      expect(s.dig(:warning)).to be_a(Integer)
      expect(s.dig(:critical)).to be_a(Integer)
      expect(s.dig(:unknown)).to be_a(Integer)
      expect(s.dig(:pending)).to be_a(Integer)
      expect(s.dig(:in_downtime)).to be_a(Integer)
      expect(s.dig(:acknowledged)).to be_a(Integer)
    end

    it 'host' do
      @icinga2.cib_data
      s = @icinga2.host_statistics
      expect(s).to be_a(Hash)
      expect(s.count).to be == 6
      expect(s.dig(:up)).to be_a(Integer)
      expect(s.dig(:down)).to be_a(Integer)
      expect(s.dig(:pending)).to be_a(Integer)
      expect(s.dig(:unreachable)).to be_a(Integer)
      expect(s.dig(:in_downtime)).to be_a(Integer)
      expect(s.dig(:acknowledged)).to be_a(Integer)
    end

    it 'work queue' do
      r = @icinga2.work_queue_statistics
      expect(r).to be_a(Hash)
      expect(r.count).to be >= 1
      r.each do |_k,v|
        expect(v).to be_a(Float)
      end
#      puts r.value
    end
  end

  describe 'Module Host' do

    it "list host 'c1-mysql-1'" do
      h = @icinga2.hosts(host: 'c1-mysql-1')
      expect(h).to be_a(Array)
      expect(h.count).to be == 1
    end

    it 'list all hosts' do
      h = @icinga2.hosts
      expect(h).to be_a(Array)
      expect(h.count).to be >= 1
    end

    it "exists host 'c1-mysql-1'" do
      expect(@icinga2.exists_host?('c1-mysql-1')).to be_truthy
    end

    it 'exists_host \'test\'' do
      expect(@icinga2.exists_host?('test')).to be_falsey
    end

    it 'count of all hosts' do
      @icinga2.host_objects
      c = @icinga2.hosts_all
      expect(c).to be_a(Integer)
      expect(c).to be >= 1
    end

    it 'adjusted' do
      @icinga2.cib_data
      @icinga2.host_objects
      a = @icinga2.hosts_adjusted
      expect(a).to be_a(Hash)
      expect(a.count).to be == 2
      expect(a.dig(:handled_problems)).to be_a(Integer)
      expect(a.dig(:down_adjusted)).to be_a(Integer)
    end

    it 'count_hosts_with_problems' do
      expect(@icinga2.count_hosts_with_problems).to be_a(Integer)
    end

    it 'list_hosts_with_problems 5' do
      h = @icinga2.list_hosts_with_problems
      expect(h).to be_a(Hash)
      expect(h.count).to be <= 5
    end

    it 'list_hosts_with_problems 15' do
      h = @icinga2.list_hosts_with_problems(15)
      expect(h).to be_a(Hash)
      expect(h.count).to be <= 15
    end

    it 'count all hosts' do
      @icinga2.host_objects
      h = @icinga2.hosts_all
      expect(h).to be_a(Integer)
      expect(h).to be >= 1
    end

    it 'data with host problems' do
      @icinga2.host_objects
      h = @icinga2.host_problems
      expect(h).to be_a(Hash)
      expect(h.count).to be == 4
      expect(h.dig(:all)).to be_a(Integer)
      expect(h.dig(:down)).to be_a(Integer)
      expect(h.dig(:critical)).to be_a(Integer)
      expect(h.dig(:unknown)).to be_a(Integer)
    end
  end

  describe 'Module Hostgroups' do

    it 'list hostgroup \'linux-servers\'' do
      h = @icinga2.hostgroups(host_group: 'linux-servers')
      name = h.first.dig('attrs','__name')
      expect(h).to be_a(Array)
      expect(h.count).to be == 1
      expect(name).to be == 'linux-servers'
    end

    it 'list all hostgroups' do
      h = @icinga2.hostgroups
      expect(h).to be_a(Array)
      expect(h.count).to be >= 1
    end

    it 'exists hostgroup \'linux-servers\'' do
      expect(@icinga2.exists_hostgroup?('linux-servers')).to be_truthy
    end

    it 'exists hostgroup \'test\'' do
      expect(@icinga2.exists_hostgroup?('test')).to be_falsey
    end
  end

  describe 'Module Services' do

    it "list services 'ping4' for host 'c1-mysql-1'" do
      h = @icinga2.services( host: 'c1-mysql-1', service: 'ping4' )
      expect(h).to be_a(Array)
      expect(h.count).to be == 1
    end

    it 'list all services' do
      h = @icinga2.services
      expect(h).to be_a(Array)
      expect(h.count).to be >= 1
    end

    it "exists service check 'ssh' for host 'c1-mysql-1'" do
      expect(@icinga2.exists_service?( host: 'c1-mysql-1', service: 'ssh' )).to be_truthy
    end

    it "exists service check 'hdb' for host 'c1-mysql-1'" do
      expect(@icinga2.exists_service?( host: 'c1-mysql-1', service: 'hdb' )).to be_falsey
    end

    it 'count of all services with default parameters' do
      c = @icinga2.service_objects
      expect(c).to be_a(Array)
      expect(c.count).to be >= 1
    end

    it 'count of all services with \'attr\' and \'joins\' as parameter' do
      c = @icinga2.service_objects( attrs: %w[name state], joins: ['host.name','host.state'] )
      expect(c).to be_a(Array)
      expect(c.count).to be >= 1
    end

    it 'adjusted' do
      @icinga2.cib_data
      @icinga2.service_objects
      a = @icinga2.services_adjusted
      expect(a).to be_a(Hash)
      expect(a.count).to be == 3
      expect(a.dig(:warning)).to be_a(Integer)
      expect(a.dig(:critical)).to be_a(Integer)
      expect(a.dig(:unknown)).to be_a(Integer)
    end

    it 'count of services with problems' do
      expect(@icinga2.count_services_with_problems).to be_a(Integer)
    end

    it 'count of services with problems' do
      expect(@icinga2.count_services_with_problems).to be_a(Integer)
    end

    it 'list_services_with_problems 5' do
      h = @icinga2.list_services_with_problems
      expect(h).to be_a(Hash)
      expect(h.count).to be == 2
      expect(h.dig(:services_with_problems)).to be_a(Array)
      expect(h.dig(:services_with_problems).count).to be <= 5
      expect(h.dig(:services_with_problems_and_severity)).to be_a(Hash)
      expect(h.dig(:services_with_problems_and_severity).count).to be <= 5
    end

    it 'list_services_with_problems 15' do
      h = @icinga2.list_services_with_problems(15)
      expect(h).to be_a(Hash)
      expect(h.count).to be == 2
      expect(h.dig(:services_with_problems)).to be_a(Array)
      expect(h.dig(:services_with_problems).count).to be <= 15
      expect(h.dig(:services_with_problems_and_severity)).to be_a(Hash)
      expect(h.dig(:services_with_problems_and_severity).count).to be <= 15
    end

    it 'count of all services' do
      @icinga2.cib_data
      @icinga2.service_objects
      expect(@icinga2.services_all).to be_a(Integer)
    end

    it 'services with problems' do
      @icinga2.cib_data
      @icinga2.service_objects
      a = @icinga2.service_problems
      expect(a).to be_a(Hash)
      expect(a.count).to be == 7
      expect(a.dig(:ok)).to be_a(Integer)
      expect(a.dig(:warning)).to be_a(Integer)
      expect(a.dig(:critical)).to be_a(Integer)
      expect(a.dig(:unknown)).to be_a(Integer)
      expect(a.dig(:pending)).to be_a(Integer)
      expect(a.dig(:in_downtime)).to be_a(Integer)
      expect(a.dig(:acknowledged)).to be_a(Integer)
    end


    it 'data with handled (acknowledged or downtimed) service problems' do
      @icinga2.cib_data
      @icinga2.service_objects
      s = @icinga2.service_problems_handled
      expect(s).to be_a(Hash)
      expect(s.count).to be == 4
      expect(s.dig(:all)).to be_a(Integer)
      expect(s.dig(:critical)).to be_a(Integer)
      expect(s.dig(:warning)).to be_a(Integer)
      expect(s.dig(:unknown)).to be_a(Integer)
    end

    it 'list all unhandled service' do
      s = @icinga2.unhandled_services
      expect(s).to be_a(Array)
      expect(s.count).to be >= 0
    end

    it 'add service \'new_http\' to host \'c1-mysql-1\'' do
      data = {
        host: 'c1-mysql-1',
        service_name: 'new_http',
        vars: {
          attrs: {
            check_command: 'http',
            check_interval: 10,
            retry_interval: 30,
            vars: {
              http_address: '127.0.0.1',
              http_url: '/access/index',
              http_port: 80
            }
          }
        }
      }

      s = @icinga2.add_services( data )
      status_code = s[:status]
      expect(s).to be_a(Hash)
      expect(status_code).to be_a(Integer)

      if(status_code != 200)
        expect(s[:message]).to be_a(String)
      else
        expect(status_code).to be == 200
      end
    end

    it 'modify service \'new_http\'' do

      data = {
        service_name: 'new_http',
        vars: {
          attrs: {
            check_interval: 60,
            retry_interval: 10,
            vars: {
              http_url: '/access/login',
              http_address: '10.41.80.63'
            }
          }
        }
      }
      s = @icinga2.modify_service( data )

      status_code = s[:status]
      expect(s).to be_a(Hash)
      expect(status_code).to be_a(Integer)
      expect(status_code).to be == 200
    end

    it 'delete service \'new_http\' from \'c1-mysql-1\'' do

      s = @icinga2.delete_service(
        host: 'c1-mysql-1',
        service_name: 'new_http',
        cascade: true
      )
      status_code = s[:status]
      expect(s).to be_a(Hash)
      expect(status_code).to be_a(Integer)
      expect(status_code).to be == 200
    end

  end

  describe 'Module Servicegroups' do

    it 'list all servicegroups' do
      h = @icinga2.servicegroups
      expect(h).to be_a(Array)
      expect(h.count).to be >= 1
    end

    it 'list servicegroup \'disk\'' do
      h = @icinga2.servicegroups(service_group: 'disk')
      expect(h).to be_a(Array)
      expect(h.count).to be == 1
    end

    it 'exists servicegroup \'disk\'' do
      expect(@icinga2.exists_servicegroup?('disk')).to be_truthy
    end

    it 'exists servicegroup \'test\'' do
      expect(@icinga2.exists_servicegroup?('test')).to be_falsey
    end

  end

  describe 'Module Notification' do

    it "enable notification for host 'c1-mysql-1'" do
      h = @icinga2.enable_host_notification( 'c1-mysql-1' )
      status_code = h[:status]
      expect(h).to be_a(Hash)
      expect(status_code).to be == 200
    end

    it "enable notification for host 'c1-mysql-1' and all services" do
      h = @icinga2.enable_service_notification( 'c1-mysql-1' )
      status_code = h[:status]
      expect(h).to be_a(Hash)
      expect(status_code).to be == 200
    end

    it 'list notifications' do
      h = @icinga2.notifications
      expect(h).to be_a(Array)
      expect(h.count).to be_a(Integer)
    end
  end

  describe 'Module Downtimes' do

    it "add downtime 'test'" do
      h = @icinga2.add_downtime( name: 'test', type: 'service', host: 'c1-mysql-1', comment: 'test downtime', author: 'icingaadmin', start_time: Time.now.to_i, end_time: Time.now.to_i + 20 )
      status_code = h[:status]
      expect(h).to be_a(Hash)
      expect(status_code).to be == 200
    end

    it 'list downtimes' do
      h = @icinga2.downtimes
      expect(h).to be_a(Array)
      expect(h.count).to be >= 1
    end
  end

end
