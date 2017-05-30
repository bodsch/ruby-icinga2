
To add hostgroup :

curl -k -s -u icingaadmin:icinga 'https://localhost:5665/v1/objects/hostgroups/testgrp' \
    -X PUT -d '{ "attrs": { "name" : "testgrp" ,"display_name" : "testgrp" , "state_loaded" :true }}'

To add host :

curl -k -s -u icingaadmin:icinga 'https://localhost:5665/v1/objects/hosts/8.8.8.8' \
    -X PUT -d '{ "templates": [ "generic-host" ], "attrs": { "address": "8.8.8.8" , "groups" : [ "testgrp" ]} }'


https://localhost:5665/v1/objects/users
https://localhost:5665/v1/objects/usergroups


https://localhost:5665/v1/objects/hostgroups
https://localhost:5665/v1/objects/servicegroups

https://localhost:5665/v1/objects/hosts
https://localhost:5665/v1/objects/services

https://localhost:5665/v1/objects/notifications

# get usergroups:
curl -k -s -u root:icinga -H 'Accept: application/json' -X GET 'https://localhost:5665/v1/objects/usergroups'

# add usergroup:
curl -k -s -u root:icinga -H 'Accept: application/json' -X PUT 'https://localhost:5665/v1/objects/usergroups/foo' --data '{ "attrs": {"display_name": "Foo Bar" } }'

# delete usergroup:
curl -k -s -u root:icinga -H 'Accept: application/json' -H 'X-HTTP-Method-Override: DELETE' -X POST 'https://localhost:5665/v1/objects/usergroups/foo'


# delete user:
curl -k -s -u root:icinga -H 'Accept: application/json' -H 'X-HTTP-Method-Override: DELETE' -X POST 'https://localhost:5665/v1/objects/users/foo'

# add user:
curl -k -s -u root:icinga -H 'Accept: application/json' -X PUT 'https://localhost:5665/v1/objects/users/foo' --data '{ "attrs": {"display_name": "Foo Bar", "email": "foo.bar@coremedia.com","enable_notifications": false, "groups": [ "coreme
dia" ] } }'


# enable notification für host:
curl -k -s -u root:icinga -H 'Accept: application/json' -X POST 'https://localhost:5665/v1/objects/hosts/api_dummy_host_1' --data '{ "attrs": { "enable_notifications": true } }'

# disable notification für host:
curl -k -s -u root:icinga -H 'Accept: application/json' -X POST 'https://localhost:5665/v1/objects/hosts/api_dummy_host_1' --data '{ "attrs": { "enable_notifications": false } }'

# enable notification für service x von host:
curl -k -s -u root:icinga -H 'Accept: application/json' -X POST 'https://localhost:5665/v1/objects/services' --data '{ "filter": "host.name==\"api_dummy_host_1\"", "attrs": { "enable_notifications": true } }'

# disable notification für service x von host:
curl -k -s -u root:icinga -H 'Accept: application/json' -X POST 'https://localhost:5665/v1/objects/services' --data '{ "filter": "host.name==\"api_dummy_host_1\"", "attrs": { "enable_notifications": false } }'

# enable notification für hostgroup:
curl -k -s -u root:icinga -H 'Accept: application/json' -X POST 'https://localhost:5665/v1/objects/services' --data '{ "filter": "\"api_dummy_hostgroup\" in host.groups", "attrs": { "enable_notifications": true } }'

# disable notification für hostgroup:
curl -k -s -u root:icinga -H 'Accept: application/json' -X POST 'https://localhost:5665/v1/objects/services' --data '{ "filter": "\"api_dummy_hostgroup\" in host.groups", "attrs": { "enable_notifications": false } }'


# get downtimes
curl -k -s -u root:icinga -H 'Accept: application/json' -X GET 'https://localhost:5665/v1/objects/downtimes'

# delete named downtime
curl -k -s -u root:icinga -H 'Accept: application/json' -H 'X-HTTP-Method-Override: DELETE' -X POST 'https://localhost:5665/v1/objects/downtimes/icinga2-master!load!icinga2-master-1496045418-0'


# schedule downtime for a host

# current_time=$(date +%s)
# 1449057010
# current_time_add_30_second=$(date +%s --date="+30 seconds")
# 1449057040
curl -k -s -u root:icinga -H 'Accept: application/json' -X POST 'https://localhost:5665/v1/actions/schedule-downtime' \
  --data '{ "type": "Host", "filter": "host.name==\"api_dummy_host_1\"", "start_time": 1449057685, "end_time": 1449057715, "author": "api_user", "comment": "api_comment", "fixed": true, "duration": 30 }'

# schedule downtime for all services of a host - change the timestamps accordingly
curl -k -s -u root:icinga -H 'Accept: application/json' -X POST 'https://localhost:5665/v1/actions/schedule-downtime' \
  --data '{ "type": "Service", "filter": "host.name==\"api_dummy_host_1\"", "start_time": 1449064981, "end_time": 1449065129, "author": "api_user", "comment": "api_comment", "fixed": true, "duration": 30 }'


# schedule downtime for all hosts and services in a hostgroup - change the timestamps accordingly
curl -k -s -u root:icinga -H 'Accept: application/json' -X POST 'https://localhost:5665/v1/actions/schedule-downtime' \
  --data '{ "type": "Host", "filter": "\"api_dummy_hostgroup\" in host.groups", "start_time": 1449065680, "end_time": 1449065823, "author": "api_user", "comment": "api_comment", "duration": 120, "fixed": true, "duration": 30 }'

curl -k -s -u root:icinga -H 'Accept: application/json' -X POST 'https://localhost:5665/v1/actions/schedule-downtime' \
  --data '{ "type": "Service", "filter": "\"api_dummy_hostgroup\" in host.groups)", "start_time": 1449065680, "end_time": 1449065823, "author": "api_user", "comment": "api_comment", "duration": 120, "fixed": true, "duration": 30 }'











