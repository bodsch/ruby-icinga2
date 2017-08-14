# Icinga2 - Statistics


## statistic data for latency and execution_time
    average_statistics

**example**
    @icinga.cib_data
    latenca, execution_time = @icinga.average_statistics


## statistic data for intervall data
    interval_statistics

**example**
    @icinga.cib_data
    hosts_active_checks, hosts_passive_checks, services_active_checks, services_passive_checks = @icinga.interval_statistics


## statistic data for services
    service_statistics

**example**
    @icinga.cib_data
    ok, warning, nil, nil, pending, nil, nil = @icinga.service_statistics


## statistic data for hosts
    host_statistics

**example**
    @icinga.cib_data
    up, down, pending, unreachable, in_downtime, ack = @icinga.host_statistics


## queue statistics from the api
    work_queue_statistics

**example**
    @icinga.work_queue_statistics

