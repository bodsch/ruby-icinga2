# Icinga2 - Servicegroups


## add a servicegroup
    add_servicegroup( params )

**example**
    @icinga.add_servicegroup(service_group: 'foo', display_name: 'FOO')

## delete a servicegroup
    delete_servicegroup( params )

**example**
    @icinga.delete_servicegroup(service_group: 'foo')


## checks if the servicegroup exists
    exists_servicegroup?( service_group )

**example**
    @icinga.exists_servicegroup?('disk')


## list

### named
    servicegroups( params )

**example**
    @icinga.servicegroups(service_group: 'disk')

### all
    servicegroups

**example**
    @icinga.servicegroups

