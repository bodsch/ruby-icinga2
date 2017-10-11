# Icinga2 - Usergroups


## <a name="add-usergroup"></a>*add_usergroup( params )*

Creates an Icinga2 Usergroup.

`params` are an `Hash` with following Parameters:

| Parameter              | Type    | Example    | Description
| :--------------------  | :-----: | :-----     | :-----------
| `user_group`           | String  | `foo`      | Usergroup they will be created
| `display_name`         | String  | `User Foo` | the displayed Name

The result are an `Hash`

### Example
    @icinga.add_usergroup(user_group: 'foo', display_name: 'FOO')


## <a name="delete-usergroup"></a>*delete_usergroup( params )*

Delete a Usergroup.

`params` are an `Hash` with following Parameters:

| Parameter              | Type    | Example | Description
| :--------------------  | :-----: | :-----  | :-----------
| `user_group`           | String  | `foo`   | Usergroup they will be deleted

The result are an `Hash`

### Example
    @icinga.delete_usergroup(user_group: 'foo')


## <a name="list-usergroups"></a>*usergroups* or *usergroups( params )*

returns all or a named usergroup.

the optional `params` is an `Hash` with following Parameters:

| Parameter              | Type    | Example | Description
| :--------------------  | :-----: | :-----  | :-----------
| `user_group`           | String  | `foo`   | Usergroup they will be listed

The result are an `Hash`


### list all usergroups
    usergroups

#### Example
    @icinga.usergroups


### list named usergroup
    usergroups( params )

#### Example
    @icinga.usergroups(user_group: 'icingaadmins')



## <a name="usergroup-exists"></a>*exists_usergroup?( user_group )*

check if the Usergroup exists

`params` is an `String` with the Usergroupname.

The result are an `Boolean`

### Example

    @icinga.exists_usergroup?('icingaadmins')
