# ruby-icinga2

Small Ruby Class for the Icinga2 API


## Requirements

    gem install rest-client --no-rdoc --no-ri
    gem install json --no-rdoc --no-ri

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
    puts i.application_data()


## Status

supports the following API Calls:

  - [Users](doc/status.md)
    * application_data
    * cib_data
    * api_listener

  - [Users](doc/users.md)
    * add_user( params = {} )
    * delete_user( params = {} )
    * users( params = {} )
    * exists_user?( name )

  - [Usergroups](doc/usergroups.md)
    * add_usergroup( params = {} )
    * delete_usergroup( params = {} )
    * usergroups( params = {} )
    * exists_usergroup?( name )

  - [Hosts](doc/hosts.md)
    * add_host( params = {} )
    * delete_host( params = {} )
    * hosts( params = {} )
    * exists_host?( name )
    * host_objects( params = {} )
    * host_problems
    * list_hosts_with_problems( max_items = 5 )
    * host_severity( host )

  - [Hostgroups](doc/hostgroups.md)
    * add_hostgroup(params = {})
    * delete_hostgroup(params = {})
    * hostgroups(params = {})
    * exists_hostgroup?(name)

  - [Services](doc/services.md)
    * add_services( host, services = {} )
    * unhandled_services( params = {} )
    * services( params = {} )
    * exists_service?( params = {} )
    * service_objects( params = {} )
    * count_services_with_problems
    * list_services_with_problems( max_items = 5 )
    * update_host( hash, host )
    * service_severity( service )

  - [Servicegroups](doc/servicegroups.md)
    * add_servicegroup( params = {} )
    * delete_servicegroup( params = {} )
    * servicegroups( params = {} )
    * exists_servicegroup?( name )

  - [Downtimes](doc/downtimes.md)
    * add_downtime( params = {} )
    * downtimes( params = {} )

  - [Notifications](doc/notifications.md)
    * enable_host_notification( host )
    * disable_host_notification( host )
    * enable_service_notification( params = {} )
    * disable_service_notification( host )
    * enable_hostgroup_notification( group )
    * disable_hostgroup_notification( group )
    * notifications( params = {} )
    * host_notification( params = {} )
    * hostgroup_notification( params = {} )
    * service_notification( params = {} )


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

## test via CLI

    #$ export ICINGA_HOST=localhost ; export ICINGA_API_USER=root ; export ICINGA_API_PASSWORD=icinga
    #$ irb
    2.3.0 :001 > require 'icinga2'
     => true
    2.3.0 :002 > config = { :icinga => { :host => 'localhost', :api => { :user => 'root', :pass => 'icinga' } } }
     => {:icinga=>{:host=>"localhost", :api=>{:user=>"root", :pass=>"icinga"}}}
    2.3.0 :003 > i = Icinga2::Client.new( config )

## test via example
    #$ export ICINGA_HOST=localhost ; export ICINGA_API_USER=root ; export ICINGA_API_PASSWORD=icinga
    #$ ruby examples/test.rb



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request




