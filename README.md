# ruby-icinga2

Ruby Class for the Icinga2 API

## Requirements

 * ruby ~> 2.3
 * rest-client ~> 2.0
 * openssl ~> 2.0
 * json ~> 2.1


## Install

    gem install icinga2

## usage

create an instance and get information about the Icinga2 Server

    config = {
      :icinga => {
        :host      => icingaHost,
        :api       => {
          :port => icingaApiPort,
          :user => icingaApiUser,
          :pass => icingaApiPass
        },
        :cluster   => icingaCluster,
        :satellite => icingaSatellite,
      }
    }

    i = Icinga::Client.new( config )

## Status

supports the following API Calls:


  - [Users](doc/users.md)
    * add_user( params )
    * delete_user( params )
    * users( params = {} )
    * exists_user?( user_name )

  - [Usergroups](doc/usergroups.md)
    * add_usergroup( params)
    * delete_usergroup( params )
    * usergroups( params = {} )
    * exists_usergroup?( user_group )

  - [Hosts](doc/hosts.md)
    * add_host( params )
    * delete_host( params )
    * hosts( params = {} )
    * exists_host?( host_name )
    * host_objects( params = {} )
    * hosts_adjusted
    * count_hosts_with_problems
    * list_hosts_with_problems( max_items = 5 )
    * hosts_all
    * hosts_problems
    * hosts_down
    * hosts_critical
    * hosts_unknown
    * host_severity( params )

  - [Hostgroups](doc/hostgroups.md)
    * add_hostgroup( params )
    * delete_hostgroup( params )
    * hostgroups( params = {} )
    * exists_hostgroup?( host_group )

  - [Services](doc/services.md)
    * add_services( params = {} )
    * unhandled_services( params = {} )
    * services( params = {} )
    * exists_service?( params )
    * service_objects( params = {} )
    * services_adjusted
    * count_services_with_problems
    * list_services_with_problems( max_items = 5 )
    * update_host( hash, host )
    * services_all
    * services_problems
    * services_critical
    * services_warning
    * services_unknown
    * services_handled_critical
    * services_handled_warning
    * services_handled_unknown
    * services_handled_critical_problems
    * services_handled_warning_problems
    * services_handled_unknown_problems
    * service_severity( params )

  - [Servicegroups](doc/servicegroups.md)
    * add_servicegroup( params )
    * delete_servicegroup( params )
    * servicegroups( params = {} )
    * exists_servicegroup?( service_group )

  - [Downtimes](doc/downtimes.md)
    * add_downtime( params )
    * downtimes

  - [Notifications](doc/notifications.md)
    * enable_host_notification( host )
    * disable_host_notification( host )
    * enable_service_notification( host )
    * disable_service_notification( host )
    * enable_hostgroup_notification( params )
    * disable_hostgroup_notification( params )
    * notifications
    * host_notification( params = {} )
    * hostgroup_notification( params = {} )
    * service_notification( params = {} )

  - [Users](doc/statistics.md)
    * average_statistics
    * interval_statistics
    * service_statistics
    * host_statistics
    * work_queue_statistics


## create a own gem File

    #$ gem build icinga2.gemspec
    Successfully built RubyGem
    Name: icinga2
    Version: 0.6.0
    File: icinga2-0.6.0.gem

## install gem

    #$ gem install icinga2
    Successfully installed icinga2-0.6.0
    1 gem installed

## test via CLI against the Icinga2 Vagrant Box

    #$ irb
    2.3.0 :001 > require 'icinga2'
     => true
    2.3.0 :002 > config = { :icinga => { :host => '192.168.33.5', :api => { :user => 'root', :pass => 'icinga' } } }
     => {:icinga=>{:host=>"localhost", :api=>{:user=>"root", :pass=>"icinga"}}}
    2.3.0 :003 > i = Icinga2::Client.new( config )

## test via example
    #$ export ICINGA_HOST=192.168.33.5 ; export ICINGA_API_USER=root ; export ICINGA_API_PASSWORD=icinga
    #$ ruby examples/test.rb



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request




