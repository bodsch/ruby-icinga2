# Icinga2 - Downtimes


## <a name="add-downtime"></a>add a downtime
    add_downtime( params )

### Example

    param = {
      name: 'test',
      type: 'service',
      host: 'icinga2',
      comment: 'test downtime',
      author: 'icingaadmin',
      start_time: Time.now.to_i,
      end_time: Time.now.to_i + 20
    }
    @icinga.add_downtime( param )


## <a name="remove-downtime"></a>remove a downtime
    remove_downtime( params )

### Example

remove all downtimes from the user `icingaadmin` and the comment `test downtime`

```bash
param = {
  comment: 'test downtime',
  author: 'icingaadmin'
}
@icinga.remove_downtime(param)
```

remove a downtime from a host but not the services filtered by the author name.
This example uses filter variables explained in the
[advanced filters](https://github.com/Icinga/icinga2/blob/master/doc/12-icinga2-api.md#icinga2-api-advanced-filters)
chapter from the official API documentation.

```bash
param = {
  filter: '"host.name == filterHost && !service && downtime.author == filterAuthor"',
  filter_vars: { filterHost: 'c1-mysql-1', filterAuthor: 'icingaadmin' }
)
@icinga.remove_downtime(param)
```

remove a downtime for service `ping4` and host `c1-mysql-1`

```bash
param = {
  host_name: 'c1-mysql-1',
  service_name: 'ping4'
}
@icinga.remove_downtime(param)
```


## <a name="list-downtimes"></a>list all downtimes
    downtimes

### Example
    @icinga.downtimes
