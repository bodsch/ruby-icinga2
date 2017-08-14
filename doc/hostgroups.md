# Icinga2 - Hostgroups


## add
    add_hostgroup( params )

**example**
    @icinga.add_hostgroup(host_group: 'foo', display_name: 'FOO')


## delete
    delete_hostgroup( params )

**example**
    @icinga.delete_hostgroup(host_group: 'foo')


## list

### named
    hostgroups( params )

**example**
    @icinga.hostgroups(host_group: 'linux-servers')

### all
    hostgroups

**example**
    @icinga.hostgroups


## check if the hostgroup exists
    exists_hostgroup?( hostgroup )

**example**
    @icinga.exists_hostgroup?('linux-servers')
