# ruby-icinga2

An enhanced ruby gem to communicate with Icinga2 API

[![Gem Version](https://badge.fury.io/rb/icinga2.svg)](https://badge.fury.io/rb/icinga2)

[![Build Status](https://travis-ci.org/bodsch/ruby-icinga2.svg)][travis]
[![Gem Downloads](http://ruby-gem-downloads-badge.herokuapp.com/icinga2)][gem-downloads]
[![total Downloads](http://ruby-gem-downloads-badge.herokuapp.com/icinga2?type=total&metric=true&label=downloads-total)][gem-downloads]
[![Dependency Status](https://gemnasium.com/badges/github.com/bodsch/ruby-icinga2.svg)][gemnasium]


[travis]: https://travis-ci.org/bodsch/ruby-icinga2
[gem-downloads]: http://ruby-gem-downloads-badge.herokuapp.com/icinga2
[gemnasium]: https://gemnasium.com/github.com/bodsch/ruby-icinga2

## Requirements

* ruby version  => 2.0
* rest-client ~> 2.0
* json  ~> 2.1
* openssl ~> 2.0 (only with ruby >= 2.3)
* ruby_dig (only with ruby < 2.3)

## Install

    gem install icinga2

## Usage

create an instance

    require 'icinga2'

    config = {
      icinga: {
        host: icinga_host,
        api: {
          port: icinga_api_port,
          username: icinga_api_user,
          password: icinga_api_pass
        }
      }
    }

    @icinga = Icinga::Client.new( config )

### Use the examples

You can use the [Icinga Vagrant-Box](https://github.com/Icinga/icinga-vagrant) from the Icinga Team or
my own [Docker Container](https://hub.docker.com/r/bodsch/docker-icinga2/) as Datasource.

**Remember** Change the exported Environment Variables to your choosed Datasource!

you can find many examples under the directory `examples`:

    $ export ICINGA_HOST=localhost ; export ICINGA_API_USER=root ; export ICINGA_API_PASSWORD=icinga
    $ ruby examples/informations.rb
    $ ruby examples/statistics.rb
    $ ruby examples/users.rb

and so on.

### Test via CLI

    $ irb
    irb(main):001:0> require 'icinga2'
     => true
    irb(main):002:0> config = { icinga: { host: 'localhost', api: { username: 'root', password: 'icinga' } } }
     => {:icinga=>{:host=>"localhost", :api=>{:username=>"root", :password=>"icinga"}}}
    irb(main):003:0> i = Icinga2::Client.new( config )
    irb(main):004:0> i.available?
    => true
    irb(main):005:0>

## Create a own gem file

    $ gem build icinga2.gemspec
    Successfully built RubyGem
    Name: icinga2
    Version: 0.9.2.7
    File: icinga2-0.9.2.7.gem

## Install local gem

    $ gem install icinga2
    Successfully installed icinga2-0.9.2.7
    1 gem installed


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
    * [modify host](doc/hosts.md#modify-host)
    * [list hosts](doc/hosts.md#list-hosts)
    * [check if host exists](doc/hosts.md#host-exists)
    * [list host objects](doc/hosts.md#list-host-objects)
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
    * [add service](doc/services.md#add-service)
    * [delete service](doc/services.md#delete-service)
    * [list unhandled services](doc/services.md#unhandled-services)
    * [list services](doc/services.md#list-services)
    * [check if service exists](doc/services.md#service-exists)
    * [list service objects](doc/services.md#list-service-objects)
    * [count services with problems](doc/services.md#count-services-with-problems)
    * [list of services with problems](doc/services.md#list-services-with-problems)
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



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
