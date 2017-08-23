# ruby-icinga2

Ruby Class for the Icinga2 API




## Requirements

* ruby version  ~> 2.3
* rest-client ~> 2.0
* openssl ~> 2.0
* json  ~> 2.1

## install

    gem install icinga2

## usage

create an instance

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

    @icinga = Icinga::Client.new( config )

## Status

supports the following API Calls:

  - [Users](doc/users.md)
    * [add user](doc/users.md#add-user)
    * [delete user](doc/users.md#delete-dser)
    * [list users](doc/users.md#list-users)
    * [check if user exists](doc/users.md#user-exists)

  - [Usergroups](doc/usergroups.md)
    * [add usergroup](doc/usergroups.md#add-usergroup)
    * [delete usergroup](doc/usergroups.md#delete-usergroup)
    * [list usergroups](doc/usergroups.md#list-usergroups)
    * [check if usergroup exists](doc/usergroups.md#usergroup-exists)

  - [Hosts](doc/hosts.md)
    * [add host](doc/hosts.md#add-host)
    * [delete host](doc/hosts.md#delete-host)
    * [list hosts](doc/hosts.md#list-hosts)
    * [check if host exists](doc/hosts.md#host-exists)
    * [list host objects](doc/hosts.md#list-host-objects)
    * [adjusted hosts state](doc/hosts.md#hosts-adjusted)
    * [count of hosts with problems](doc/hosts.md#count-hosts-with-problems)
    * [list of hosts with problems](doc/hosts.md#list-hosts-with-problems)
    * [count of all hosts](doc/hosts.md#count-all-hosts)
    * [count hosts with problems](doc/hosts.md#count-host-problems)
    * calculate host severity (protected)

  - [Hostgroups](doc/hostgroups.md)
    * [add hostgroup](doc/hostgroups.md#add-usergroup)
    * [delete hostgroup](doc/hostgroups.md#delete-usergroup)
    * [list hostgroups](doc/hostgroups.md#list-usergroups)
    * [check if hostgroup exists](doc/hostgroups.md#usergroup-exists)

  - [Services](doc/services.md)
    * [add service](doc/services.md#add-service) (**this function is not operable yet!**)
    * [delete service](doc/services.md#delete-service) (**not yet implemented**)
    * [add service](doc/services.md#add-service) (**this function is not operable yet!**)
    * [list unhandled services](doc/services.md#unhandled-services) (**not yet implemented**)
    * [list services](doc/services.md#list-services)
    * [check if service exists](doc/services.md#service-exists)
    * [list service objects](doc/services.md#list-service-objects)
    * [adjusted service state](doc/services.md#services-adjusted)
    * [count services with problems](doc/services.md#count-services-with-problems)
    * [list of services with problems](doc/services.md#list-services-with-problems)
    * [update host](doc/services.md#update-host) (**this function is not operable yet!**)
    * [count of all services](doc/services.md#count-all-services)
    * [count all services with handled problems](doc/services.md#count-all-services-handled)
    * calculate service severity (protected)

  - [Servicegroups](doc/servicegroups.md)
    * [add servicegroup](doc/servicegroups.md#add-servicegroup)
    * [delete servicegroup](doc/servicegroups.md#delete-servicegroup)
    * [list servicegroups](doc/servicegroups.md#list-servicegroup)
    * [check if servicegroup exists](doc/servicegroups.md#servicegroup-exists)

  - [Downtimes](doc/downtimes.md)
    * [add downtime](doc/downtimes.md#add-downtime)
    * [list downtimes](doc/downtimes.md#list-downtimes)

  - [Notifications](doc/notifications.md)
    * [enable host notifications](doc/notifications.md#enable-host-notification)
    * [disable host notifications](doc/notifications.md#disable-host-notification)
    * [enable service notifications](doc/notifications.md#enable-service-notification)
    * [disable service notifications](doc/notifications.md#disable-service-notification)
    * [enable hostgroup notifications](doc/notifications.md#enable-hostgroup-notification)
    * [disable hostgroup notifications](doc/notifications.md#disable-hostgroup-notification)
    * [list all notifications](doc/notifications.md#list-notifications)
    * host notification (protected)
    * hostgroup notification (protected)
    * service notification (protected)

  - [Statistics](doc/statistics.md)
    * [statistic data for latence and execution time](doc/statistics.md#stats-avg)
    * [statistic data for interval data](doc/statistics.md#stats-interval)
    * [statistic data for services](doc/statistics.md#stats-services)
    * [statistic data for hosts](doc/statistics.md#stats-hosts)
    * [queue statistics from the api](doc/statistics.md#stats-work-queue)


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




