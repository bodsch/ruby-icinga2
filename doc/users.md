# Icinga2 - Users


## add User
    add_user( params )

**example**
    params =  {
      user_name: 'foo',
      display_name: 'FOO',
      email: 'foo@bar.com',
      pager: '0000',
      groups: ['icingaadmins']
    }

    @icinga.add_user( params )


## delete User
    delete_user( params )

**example**
    @icinga.delete_user(user_name: 'foo')


## list

### named
    users( params )

**example**
    @icinga.users(user_name: 'icingaadmin')

### all
    users
**example**
    @icinga.users


## checks if the user exists

**example**
    @icinga.exists_user?('icingaadmin')
