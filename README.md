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
    puts i.applicationData()

## Status

supports the following API Calls:

  - [Users](doc/users.md)
    * addUser
    * deleteUser
    * listUsers
    * existsUser
  - [Usergroups](doc/usergroups.md)
    * addUsergroup
    * deleteUsergroup
    * listUsergroups
    * existsUsergroup
  - [Hosts](doc/hosts.md)
    * addHost
    * deleteHost
    * listHosts
    * existsHost
  - [Hostgroups](doc/hostgroups.md)
    * addHostgroup
    * deleteHostgroup
    * listHostgroups
    * existsHostgroup
  - [Services](doc/services.md)
    * addService
    * deleteService
    * listServices
    * existsService
  - [Servicegroups](doc/servicegroups.md)
    * addServicegroup
    * deleteServicegroup
    * listServicegroups
    * existsServicegroup
  - [Downtimes](doc/downtimes.md)
    * addDowntime
    * listDowntimes
  - [Notifications](doc/notifications.md)
    * enableHostNotification
    * disableHostNotification
    * enableServiceNotification
    * disableServiceNotification
    * enableHostgroupNotification
    * disableHostgroupNotification
    * listNotifications


## create a own gem File

    #$ gem build icinga2.gemspec
    Successfully built RubyGem
    Name: icinga2
    Version: 1.4.9
    File: icinga2-1.4.9.gem

## install gem

    #$ gem install ./icinga2-1.4.9.gem
    Successfully installed icinga2-1.4.9
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






