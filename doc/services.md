# Icinga2 - Services


## <a name="add-service"></a>add services
    add_services( params )

**this function is not operable! need help, time and/or beer**

### Example
    services = {
      'service-heap-mem' => {
        'display_name'  => 'Tomcat - Heap Memory',
        'check_command' => 'tomcat-heap-memory',
      }
    }

    @icinga.add_services( 'foo-bar.lan', services )


## <a name="list-services"></a>list services

### list named service
    services( params )

#### Example
    @icinga.services( host: 'icinga2', service: 'ping4' )

### list all services
    services

#### Example
    @icinga.services


## <a name="delete-service"></a>delete
**not yet implemented**

## <a name="unhandled-services"></a>list unhandled_services
**not yet implemented**




## <a name="service-exists"></a>check if the service exists
    exists_service?( params )

### Example
    @icinga.exists_service?(host: 'icinga2', service: 'users' )


## <a name="list-service-objects"></a>list service objects
    service_objects( params )

### Example
    @icinga.service_objects(attrs: ['name', 'state'], joins: ['host.name','host.state'])


## <a name="services-adjusted"></a>adjusted service state
    services_adjusted

### Example
    @icinga.cib_data
    @icinga.service_objects
    warning, critical, unknown = @icinga.services_adjusted.values

or
    s = @icinga.services_adjusted
    unknown = s.dig(:unknown)


## <a name="count-services-with-problems"></a>count services with problems
    count_services_with_problems

### Example
    @icinga.count_services_with_problems


## <a name="list-services-with-problems"></a>list of services with problems
    list_services_with_problems( max_items )

### Example
    @icinga.list_services_with_problems
    @icinga.list_services_with_problems(10)
    problems, problems_and_severity = @icinga.list_services_with_problems(10).values


## <a name="update-host"></a>update host
    update_host( hash, host )
**this function is not operable! need help, time and/or beer**

### Example


## <a name="count-all-services"></a>count all services
    services_all

### Example
    @icinga.service_objects
    @icinga.services_all


## <a name="count-all-services-handled"></a>count all services with handled problems
    service_problems_handled

### Example
    @icinga.cib_data
    @icinga.service_objects
    all, critical, warning, unknown = @icinga.service_problems_handled.values

or
    p = @icinga.service_problems_handled
    warning = p.dig(:warning)


## <a name=""></a>(protected) calculate a service severity
    service_severity( params )

### Example
    service_severity( {'attrs' => { 'state' => 0.0, 'acknowledgement' => 0.0, 'downtime_depth' => 0.0 } } )
