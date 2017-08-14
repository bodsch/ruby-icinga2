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

  describe 'Module Statistics' do
    it 'average' do
      @icinga2.cib_data
      latency, execution_time = @icinga2.average_statistics
      expect(latency).to be_a(String)
      expect(execution_time).to be_a(String)
    end
    it 'interval' do
      @icinga2.cib_data
      h_act_checks, h_pas_checks, s_act_checks, s_pas_checks = @icinga2.interval_statistics
      expect(h_act_checks).to be_a(Float)
      expect(h_pas_checks).to be_a(Float)
      expect(s_act_checks).to be_a(Float)
      expect(s_pas_checks).to be_a(Float)
    end
    it 'service' do
      @icinga2.cib_data
      ok, warn, crit, unkn, pending, in_downtime, ack = @icinga2.service_statistics
      expect(ok).to be_a(Fixnum)
      expect(warn).to be_a(Fixnum)
      expect(crit).to be_a(Fixnum)
      expect(unkn).to be_a(Fixnum)
      expect(pending).to be_a(Fixnum)
      expect(in_downtime).to be_a(Fixnum)
      expect(ack).to be_a(Fixnum)
    end
    it 'host' do
      @icinga2.cib_data
      up, down, pending, unreachable, in_downtime, ack = @icinga2.host_statistics
      expect(up).to be_a(Fixnum)
      expect(down).to be_a(Fixnum)
      expect(pending).to be_a(Fixnum)
      expect(unreachable).to be_a(Fixnum)
      expect(in_downtime).to be_a(Fixnum)
      expect(ack).to be_a(Fixnum)
    end
    it 'work queue' do
      r = @icinga2.work_queue_statistics
      expect(r).to be_a(Hash)
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
      handled, down = @icinga2.hosts_adjusted
      expect(handled).to be_a(Fixnum)
      expect(down).to be_a(Fixnum)
    end
    it 'count_hosts_with_problems' do
      expect(@icinga2.count_hosts_with_problems).to be_a(Integer)
    end
    it 'list_hosts_with_problems 5' do
      h = @icinga2.list_hosts_with_problems
      expect(h).to be_a(Hash)
      expect(h.count).to be == 5
    end
    it 'list_hosts_with_problems 15' do
      h = @icinga2.list_hosts_with_problems(15)
      expect(h).to be_a(Hash)
      expect(h.count).to be == 15
    end
    it 'count all hosts' do
      @icinga2.host_objects
      h = @icinga2.hosts_all
      expect(h).to be_a(Integer)
      expect(h).to be >= 1
    end

  end

  describe 'Module Hostgroups' do

    it 'list hostgroup \'linux-servers\'' do
      h = @icinga2.hostgroups(host_group: 'linux-servers')
      expect(h).to be_a(Array)
      expect(h.count).to be == 1
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
    it "exists service check 'hdb' for host '#{'c1-mysql-1'}'" do
      expect(@icinga2.exists_service?( host: 'c1-mysql-1', service: 'hdb' )).to be_falsey
    end
    it 'count of all services with default parameters' do
      c = @icinga2.service_objects
      expect(c).to be_a(Array)
      expect(c.count).to be >= 1
    end
    it 'count of all services with \'attr\' and \'joins\' as parameter' do
      c = @icinga2.service_objects( attrs: ['name', 'state'], joins: ['host.name','host.state'] )
      expect(c).to be_a(Array)
      expect(c.count).to be >= 1
    end
    it 'adjusted' do
      @icinga2.cib_data
      @icinga2.service_objects
      warning, critical, unknown = @icinga2.services_adjusted
      expect(warning).to be_a(Fixnum)
      expect(critical).to be_a(Fixnum)
      expect(unknown).to be_a(Fixnum)
    end
    it 'count of services with problems' do
      expect(@icinga2.count_services_with_problems).to be_a(Integer)
    end
    it 'count of services with problems' do
      expect(@icinga2.count_services_with_problems).to be_a(Integer)
    end
    it 'list_services_with_problems 5' do
      h = @icinga2.list_services_with_problems
      expect(h).to be_a(Array)
      expect(h.count).to be <= 5
    end
    it 'list_services_with_problems 15' do
      h = @icinga2.list_services_with_problems(15)
      expect(h).to be_a(Array)
      expect(h.count).to be <= 15
    end
    it 'count of all services' do
      @icinga2.cib_data
      @icinga2.service_objects
      expect(@icinga2.services_all).to be_a(Integer)
    end
    it 'count of all services with problems (critical, warning, unknown state)' do
      @icinga2.cib_data
      @icinga2.service_objects
      expect(@icinga2.services_problems).to be_a(Integer)
    end
    it 'count of services with critical state' do
      @icinga2.cib_data
      @icinga2.service_objects
      expect(@icinga2.services_critical).to be_a(Integer)
    end
    it 'count of services with warning state' do
      @icinga2.cib_data
      @icinga2.service_objects
      expect(@icinga2.services_warning).to be_a(Integer)
    end
    it 'count of services with unknown state' do
      @icinga2.cib_data
      @icinga2.service_objects
      expect(@icinga2.services_unknown).to be_a(Integer)
    end
    it 'count of handled (acknowledged or downtimed) services with critical state' do
      @icinga2.cib_data
      @icinga2.service_objects
      expect(@icinga2.services_handled_critical).to be_a(Integer)
    end
    it 'count of handled (acknowledged or downtimed) services with warning state' do
      @icinga2.cib_data
      @icinga2.service_objects
      expect(@icinga2.services_handled_warning).to be_a(Integer)
    end
    it 'count of handled (acknowledged or downtimed) services with unknown state' do
      @icinga2.cib_data
      @icinga2.service_objects
      expect(@icinga2.services_handled_unknown).to be_a(Integer)
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
