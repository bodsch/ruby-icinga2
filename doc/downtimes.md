# Icinga2 - Downtimes


<<<<<<< Updated upstream
## add
    add_downtime()

## list
    downtimes()
=======
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


## <a name="list-downtimes"></a>list all downtimes
    downtimes

### Example
    @icinga.downtimes
>>>>>>> Stashed changes
