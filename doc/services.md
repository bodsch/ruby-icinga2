# Icinga2 - Services


## add services
    add_services( params )

**this function is not operable! need help, time and/or beer**

**example**
    services = {
      'service-heap-mem' => {
        'display_name'  => 'Tomcat - Heap Memory',
        'check_command' => 'tomcat-heap-memory',
      }
    }

    @icinga.add_services( 'foo-bar.lan', services )


## list services

### named
    services( params )

**example**
    @icinga.services( host: 'icinga2', service: 'ping4' )


### all
    services

**example**
    @icinga.services


## delete
**not yet implemented**



## check if the service exists
    exists_service?( params )

**example**
    @icinga.exists_service?(host: 'icinga2', service: 'users' )


## service objects
    service_objects( params )

**example**
    @icinga.service_objects(attrs: ['name', 'state'], joins: ['host.name','host.state'])


## returns adjusted service state
    services_adjusted

**example**
    @icinga.cib_data
    @icinga.service_objects
    warning, critical, unknown = @icinga.services_adjusted


## count of services with problems
    count_services_with_problems

**example**
    @icinga.count_services_with_problems


## list of services with problems
    list_services_with_problems( max_items )

**example**
    @icinga.list_services_with_problems
    @icinga.list_services_with_problems( 10 )


## update host
    update_host( hash, host )
**this function is not operable! need help, time and/or beer**

**example**


## counter of all services
    services_all

**example**
    @icinga.service_objects
    @icinga.services_all


## a counter of all services with problems (critical, warning, unknown state)
    services_problems

**example**
    @icinga.service_objects
    @icinga.services_problems


## a counter of services with critical state
    services_critical

**example**
    @icinga.service_objects
    @icinga.services_critical


## a counter of services with warning state
    services_warning

**example**
    @icinga.service_objects
    @icinga.services_warning


## a counter of services with unknown state
    services_unknown

**example**
    @icinga.service_objects
    @icinga.services_unknown


## a counter of handled (acknowledged or downtimed) services with critical state
    services_handled_critical

**example**
    @icinga.service_objects
    @icinga.services_handled_critical


## a counter of handled (acknowledged or downtimed) services with warning state
    services_handled_warning

**example**
    @icinga.service_objects
    @icinga.services_handled_warning


## a counter of handled (acknowledged or downtimed) services with unknown state
    services_handled_unknown

**example**
    @icinga.service_objects
    @icinga.services_handled_unknown



## **protected** calculate a service severity
    service_severity( params )

**example**
    service_severity( {'attrs' => { 'state' => 0.0, 'acknowledgement' => 0.0, 'downtime_depth' => 0.0 } } )
