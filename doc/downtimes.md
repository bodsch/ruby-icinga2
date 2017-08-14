# Icinga2 - Downtimes


## Add a downtime
    add_downtime( params )

**example**

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


## List all downtimes
    downtimes

**example**
    @icinga.downtimes
