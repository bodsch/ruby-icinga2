# Icinga2 - Services


## <a name="add-service"></a>add services
    add_services( params )

### Example
    services = {
      vars: {
        display_name: 'Tomcat - Heap Memory',
        check_command: 'tomcat-heap-memory'
      }
    }

    @icinga.add_services( host: 'icinga2', service_name: 'ping4', vars: services )

    @icinga.add_services(
      host: 'icinga2',
      service_name: 'ping4',
      vars: {
        attrs: {
          check_command: 'ping4',
          check_interval: 10,
          retry_interval: 30
        }
      }
    )


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
    delete_service( params )

#### Example
    @icinga.delete_service(host: 'foo', service_name: 'ping4')
<<<<<<< HEAD

    @icinga.delete_service(host: 'foo', service_name: 'new_ping4', cascade: true)
=======
>>>>>>> feature/reduce-double-code

    @icinga.delete_service(host: 'foo', service_name: 'new_ping4', cascade: true)


## <a name="unhandled-services"></a>list unhandled_services
    unhandled_services

<<<<<<< HEAD
## <a name="unhandled-services"></a>list unhandled_services
    unhandled_services

=======
>>>>>>> feature/reduce-double-code
#### Example
    @icinga.unhandled_services


## <a name="service-exists"></a>check if the service exists
    exists_service?( params )

### Example
    @icinga.exists_service?(host: 'icinga2', service: 'users' )


## <a name="list-service-objects"></a>list service objects
    service_objects( params )

### Example
    @icinga.service_objects(attrs: ['name', 'state'], joins: ['host.name','host.state'])


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


## <a name="count-all-services"></a>count all services
    services_all

### Example
    @icinga.service_objects
    @icinga.services_all


## <a name=""></a>(protected) calculate a service severity
    service_severity( params )

### Example
    service_severity( {'attrs' => { 'state' => 0.0, 'acknowledgement' => 0.0, 'downtime_depth' => 0.0 } } )



## <a name=""></a>(private) update host
    update_host( hash, host )

### Example
<<<<<<< HEAD
    service_severity( {'attrs' => { 'state' => 0.0, 'acknowledgement' => 0.0, 'downtime_depth' => 0.0 } } )



## <a name=""></a>(private) update host
    update_host( hash, host )

### Example
=======
>>>>>>> feature/reduce-double-code
    update_host( v, host_name )
