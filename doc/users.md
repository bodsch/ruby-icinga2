# Icinga2 - Users

## <a name="add-user"></a>*add_user( params )*

creates an Icinga2 User.

`params` are an `Hash` with following Parameters:

| Parameter              | Type    | Example                  | Description
| :--------------------  | :-----: | :-----                   | :-----------
| `user_name`            | String  | `foo`                    | User they will be created
| `display_name`         | String  | `User Foo`               | the displayed Name
| `email`                | String  | `foo@bar.tld`            | the Email for this Users
| `pager`                | String  | `+49 000 000000`         | an optional Pager Number
| `enable_notifications` | Bool    | `true`                   | enable notifications for this user (default: **false**)
| `groups`               | Array   | `['icingaadmins','dba']` | a hash with (existing!) groups

The result are an `Hash`

### Example

    params =  {
      user_name: 'foo',
      display_name: 'FOO',
      email: 'foo@bar.com',
      pager: '0000',
      groups: ['icingaadmins']
    }
    puts @icinga.add_user( params )
    {"code"=>200, "name"=>nil, "status"=>"Object was created"}


## <a name="delete-user"></a>*delete_user( params )*

delete an Icinga2 User.

`params` is an `Hash` with following Parameters:

| Parameter              | Type    | Example | Description
| :--------------------  | :-----: | :-----  | :-----------
| `user_name`            | String  | `foo`   | User they will be deleted

The result are an `Hash`

### Example

    puts @icinga.delete_user(user_name: 'foo')
    {"code"=>200, "name"=>"foo", "status"=>"Object was deleted."}


## <a name="list-users"></a>*users* or *users( params )*

returns all or a named user.

the optional `params` is an `Hash` with following Parameters:

| Parameter              | Type    | Example | Description
| :--------------------  | :-----: | :-----  | :-----------
| `user_name`            | String  | `foo`   | User they will be listed

The result are an `Hash`

### list all users
    users

#### Example
    @icinga.users
    {"attrs"=>{"__name"=>"icingaadmin", "active"=>true, "display_name"=>"Icinga 2 Admin", "email"=>"icinga@localhost", "enable_notifications"=>true, "groups"=>["icingaadmins"], "ha_mode"=>0.0, "last_notification"=>0.0, "name"=>"icingaadmin", "original_attributes"=>nil, "package"=>"_etc", "pager"=>"", "paused"=>false, "period"=>"", "source_location"=>{"first_column"=>1.0, "first_line"=>6.0, "last_column"=>25.0, "last_line"=>6.0, "path"=>"/etc/icinga2/conf.d/users.conf"}, "states"=>nil, "templates"=>["icingaadmin", "generic-user"], "type"=>"User", "types"=>nil, "vars"=>nil, "version"=>0.0, "zone"=>""}, "joins"=>{}, "meta"=>{}, "name"=>"icingaadmin", "type"=>"User"}

### list named user
    users( params )

#### Example
    @icinga.users(user_name: 'foo')
    {"attrs"=>{"__name"=>"foo", "active"=>true, "display_name"=>"FOO", "email"=>"foo@bar.com", "enable_notifications"=>false, "groups"=>["icingaadmins"], "ha_mode"=>0.0, "last_notification"=>0.0, "name"=>"foo", "original_attributes"=>nil, "package"=>"_api", "pager"=>"0000", "paused"=>false, "period"=>"", "source_location"=>{"first_column"=>0.0, "first_line"=>1.0, "last_column"=>16.0, "last_line"=>1.0, "path"=>"/var/lib/icinga2/api/packages/_api/icinga2-master.matrix.lan-1507365860-1/conf.d/users/foo.conf"}, "states"=>nil, "templates"=>["foo"], "type"=>"User", "types"=>nil, "vars"=>nil, "version"=>1507609817.587105, "zone"=>"icinga2-master.matrix.lan"}, "joins"=>{}, "meta"=>{}, "name"=>"foo", "type"=>"User"}



## <a name="user-exists"></a>*exists_user?( params )*

check if an User exists.

`params` is an `String` with the Username.

The result are an `Boolean`

### Example

    puts @icinga.exists_user?('icingaadmin')
    true
