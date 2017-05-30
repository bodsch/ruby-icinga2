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

