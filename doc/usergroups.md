# Icinga2 - Usergroups


## <a name="add-usergroup"></a>add a usergroup
    add_usergroup( params )

### Example
    @icinga.add_usergroup(user_group: 'foo', display_name: 'FOO')


## <a name="delete-usergroup"></a>delete a usergroup
    delete_usergroup( params )

### Example
    @icinga.delete_usergroup(user_group: 'foo')


## <a name="list-usergroups"></a>list usergroups

### list named usergroup
    usergroups( params )

#### Example
    @icinga.usergroups(user_group: 'icingaadmins')

### list all usergroups
    usergroups

#### Example
    @icinga.usergroups


## <a name="usergroup-exists"></a>check if the usergroup exists
    exists_usergroup?( user_group )

### Example
    @icinga.exists_usergroup?('icingaadmins')
