# Icinga2 - Servicegroups


<<<<<<< Updated upstream
## add
    add_servicegroup()


## delete
    delete_servicegroup()


## check
    exists_servicegroup?

## list

### named
    servicegroups()

### all
    servicegroups()
=======
## <a name="add-servicegroup"></a>add a servicegroup
    add_servicegroup( params )

### Example
    @icinga.add_servicegroup(service_group: 'foo', display_name: 'FOO')

## <a name="delete-servicegroup"></a>delete a servicegroup
    delete_servicegroup( params )

### Example
    @icinga.delete_servicegroup(service_group: 'foo')

## <a name="list-servicegroup"></a>list servicegroups

### list a named servicegroup
    servicegroups( params )

#### Example
    @icinga.servicegroups(service_group: 'disk')

### list all servicegroups
    servicegroups

#### Example
    @icinga.servicegroups
>>>>>>> Stashed changes


## <a name="servicegroup-exists"></a>checks if the servicegroup exists
    exists_servicegroup?( service_group )

### Example
    @icinga.exists_servicegroup?('disk')




