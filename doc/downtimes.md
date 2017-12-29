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

    param = {
      downtime_name: 'test',
    }
    @icinga.remove_downtime( param )

## <a name="list-downtimes"></a>list all downtimes
    downtimes

### Example
    @icinga.downtimes
