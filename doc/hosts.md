# Icinga2 - Hosts

## <a name="add-host"></a>add a host
    add_host( params )

### Example
    param = {
      host: 'foo',
      fqdn: 'foo.bar.com',
      display_name: 'test node',
      max_check_attempts: 5,
      notes: 'test node'
    }
    @icinga.add_host(param)


## <a name="delete-host"></a>delete a host
    delete_host( params )

### Example
    @icinga.delete_host(host: 'foo')


## <a name="list-hosts"></a>list hosts

### list a named host
    hosts( params )

#### Example
    @icinga.host(host: 'icinga2')

### list all hosts
    hosts

#### Example
    @icinga.hosts


## <a name="host-exists"></a>check if the host exists
    exists_host?( host_name )

### Example
    @icinga.exists_host?('icinga2')


## <a name="list-host-objects"></a>get host objects
    host_objects( params )

### Example
    @icinga.host_objects(attrs: ['name', 'state'])


## <a name="count-hosts-with-problems"></a>count of hosts with problems
    count_hosts_with_problems

### Example
    @icinga.count_hosts_with_problems


## <a name="list-hosts-with-problems"></a>a hash of hosts with problems
    list_hosts_with_problems( max_items )

### Example
    @icinga.list_hosts_with_problems
    @icinga.list_hosts_with_problems( 10 )


## <a name="count-all-hosts"></a>count of all hosts
    hosts_all

### Example
    @icinga.hosts_all


## <a name="count-host-problems"></a>count all hosts with problems (down, warning, unknown state)
    host_problems

### Example
    all, down, critical, unknown, handled, adjusted = @icinga.host_problems.values

or

    p = @icinga.host_problems
    down = h.dig(:down)


## <a name="host-severity"></a>(protected) calculate a host severity
    host_severity( params )

original code are from [Icinga Web2](/modules/monitoring/library/Monitoring/Backend/Ido/Query/ServicestatusQuery.php)

### Example
    host_severity( {'attrs' => { 'state' => 0.0, 'acknowledgement' => 0.0, 'downtime_depth' => 0.0 } } )
