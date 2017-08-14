# Icinga2 - Hosts

## add a host
    add_host( params )

**example**
    param = {
      host: 'foo',
      fqdn: 'foo.bar.com',
      display_name: 'test node',
      max_check_attempts: 5,
      notes: 'test node'
    }
    @icinga.add_host(param)


## delete a host
    delete_host( params )

**example**
    @icinga.delete_host(host: 'foo')


## list

### list a named host
    hosts( params )

**example**
    @icinga.host(host: 'icinga2')

### list all hosts
    hosts

**example**
    @icinga.hosts


## returns true if the host exists
    exists_host?( host_name )

**example**
    @icinga.exists_host?('icinga2')


## get host objects
    host_objects( params )

**example**
    @icinga.host_objects(attrs: ['name', 'state'])


## returns adjusted hosts state
    hosts_adjusted

**example**
    @icinga.cib_data
    @icinga.host_objects
    warning, critical, unknown = @icinga.hosts_adjusted


## count of hosts with problems
    count_hosts_with_problems

**example**
    @icinga.count_hosts_with_problems


## a hash of hosts with problems
    list_hosts_with_problems( max_items )

**example**
    @icinga.list_hosts_with_problems
    @icinga.list_hosts_with_problems( 10 )


## a counter of all hosts
    hosts_all

**example**
    @icinga.host_objects
    @icinga.hosts_all


## a counter of all hosts with problems (down, warning, unknown state)
    hosts_problems

**example**
    @icinga.host_objects
    @icinga.hosts_problems


## a counter of hosts with critical state
    hosts_down

**example**
    @icinga.host_objects
    @icinga.hosts_down


## a counter of hosts with warning state
    hosts_critical

**example**
    @icinga.host_objects
    @icinga.hosts_critical


## a counter of hosts with unknown state
    hosts_unknown

**example**
    @icinga.host_objects
    @icinga.hosts_unknown


## calculate a host severity
    host_severity( params )

private function!
original code are from Icinga Web 2: ./modules/monitoring/library/Monitoring/Backend/Ido/Query/ServicestatusQuery.php

**example**
    host_severity( {'attrs' => { 'state' => 0.0, 'acknowledgement' => 0.0, 'downtime_depth' => 0.0 } } )
