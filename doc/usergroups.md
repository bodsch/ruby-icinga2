# Icinga2 - Usergroups


<<<<<<< Updated upstream
    add_usergroup

=======
## <a name="add-usergroup"></a>add a usergroup
    add_usergroup( params )

### Example
    @icinga.add_usergroup(user_group: 'foo', display_name: 'FOO')
>>>>>>> Stashed changes

    delete_usergroup

<<<<<<< Updated upstream

    usergroups


    exists_usergroup?



=======
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
>>>>>>> Stashed changes
