# Icinga2 - Hostgroups


## <a name="add-hostgroup"></a>add a hostgroup
    add_hostgroup( params )

### Example
    @icinga.add_hostgroup(host_group: 'foo', display_name: 'FOO')


## <a name="delete-hostgroup"></a>delete a hostgroup
    delete_hostgroup( params )

### Example
    @icinga.delete_hostgroup(host_group: 'foo')


## <a name="list-hostgroups"></a>list hostgroups

### list named hostgroup
    hostgroups( params )

#### Example
    @icinga.hostgroups(host_group: 'linux-servers')

### list all hostgroups
    hostgroups

### Example
    @icinga.hostgroups


## <a name="usergroup-exists"></a>check if the hostgroup exists
    exists_hostgroup?( hostgroup )

### Example
    @icinga.exists_hostgroup?('linux-servers')
