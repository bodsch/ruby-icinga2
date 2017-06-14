# Icinga2 - Users


## add User

    var =  {
      :name => 'foo',
      :display_name => 'FOO',
      :email => 'foo@bar.com',
      :pager => '0000',
      :groups => ['icingaadmins']
    }

    add_user var

return `Hash`

## delete User

    delete_user { :name => $USERNAME }

return `Hash`

## list User

### named User

    users { :name => $USERNAME }

return `Hash`

### all Users

    users

return `Hash`

## check, if User exists

    exists_user? $USERNAME

return `true` or `false`
