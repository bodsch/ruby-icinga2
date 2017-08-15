# Icinga2 - Statistics


## <a name="stats-avg"></a>statistic data for latency and execution_time
    average_statistics

### Example
    @icinga.cib_data
    latenca, execution_time = @icinga.average_statistics


## <a name="stats-interval"></a>statistic data for intervall data
    interval_statistics

### Example
    @icinga.cib_data
    hosts_active_checks, hosts_passive_checks, services_active_checks, services_passive_checks = @icinga.interval_statistics


## <a name="stats-services"></a>statistic data for services
    service_statistics

### Example
    @icinga.cib_data
    ok, warning, nil, nil, pending, nil, nil = @icinga.service_statistics


## <a name="stats-hosts"></a>statistic data for hosts
    host_statistics

### Example
    @icinga.cib_data
    up, down, pending, unreachable, in_downtime, ack = @icinga.host_statistics


## <a name="stats-work-queue"></a>queue statistics from the api
    work_queue_statistics

### Example
    @icinga.work_queue_statistics

