# Icinga2 - Usergroups


## add a usergroup
    add_usergroup( params )

**example**
    @icinga.add_usergroup(user_group: 'foo', display_name: 'FOO')


## delete a usergroup
    delete_usergroup( params )

**example**
    @icinga.delete_usergroup(user_group: 'foo')


## list

### named
    usergroups( params )

**example**
    @icinga.usergroups(user_group: 'icingaadmins')

### all
    usergroups

**example**
    @icinga.usergroups


## check if the usergroup exists
    exists_usergroup?( user_group )

**example**
    @icinga.exists_usergroup?('icingaadmins')
