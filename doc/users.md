# Icinga2 - Users

## <a name="add-user"></a>add a user
    add_user( params )

### Example
    params =  {
      user_name: 'foo',
      display_name: 'FOO',
      email: 'foo@bar.com',
      pager: '0000',
      groups: ['icingaadmins']
    }
    @icinga.add_user( params )


## <a name="delete-user"></a>delete a user
    delete_user( params )

### Example
    @icinga.delete_user(user_name: 'foo')


## <a name="list-users"></a>list users
### list named user
    users( params )
#### Example
    @icinga.users(user_name: 'icingaadmin')

### list all users
    users
#### Example
    @icinga.users


## <a name="user-exists"></a>checks if the user exists

### Example
    @icinga.exists_user?('icingaadmin')
