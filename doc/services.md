# Icinga2 - Services


## check
    existsService()

## add
    services = {
      'service-heap-mem' => {
        'display_name'  => 'Tomcat - Heap Memory',
        'check_command' => 'tomcat-heap-memory',
      }
    }

    i.addServices( 'foo-bar.lan', services )

## list

### named
    listServices( 'foo-bar.lan' )

### all
    listServices()

## delete
**not yet implemented**
