# Icinga2 - Services


## add
    services = {
      'service-heap-mem' => {
        'display_name'  => 'Tomcat - Heap Memory',
        'check_command' => 'tomcat-heap-memory',
      }
    }

    i.add_services( 'foo-bar.lan', services )

## -

    unhandled_services


## list

### named
    services( 'foo-bar.lan' )

### all
    services()

## delete
**not yet implemented**



## check
    exists_service?

##
    service_objects( params = {} )


##
    count_services_with_problems

##
    list_services_with_problems( max_items = 5 )

##
    update_host( hash, host )

##
    service_severity( service )
