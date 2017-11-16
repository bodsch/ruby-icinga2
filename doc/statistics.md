# Icinga2 - Statistics


## <a name="stats-avg"></a>*average_statistics*

statistic data for latency and execution_time

The result are an `Hash`

### Example
    @icinga.cib_data
    latency, execution_time = @icinga.average_statistics.values

or

    h = @icinga.average_statistics
    latency = h.dig(:latency)

## <a name="stats-interval"></a>*interval_statistics*

statistic data for intervall data

The result are an `Hash`

### Example
    @icinga.cib_data
    hosts_active_checks, hosts_passive_checks, services_active_checks, services_passive_checks = @icinga.interval_statistics.values

or
    i = @icinga.interval_statistics
    hosts_active_checks = i.dig(:hosts_active_checks)


## <a name="stats-services"></a>*service_statistics*

statistic data for services

The result are an `Hash`

### Example
    @icinga.cib_data
    ok, warning, critical, unknown, pending, in_downtime, ack = @icinga.service_statistics.values

or
    s = @icinga.service_statistics
    critical = s.dig(:critical)

## <a name="stats-hosts"></a>*host_statistics*

statistic data for hosts

The result are an `Hash`

### Example
    @icinga.cib_data
    up, down, pending, unreachable, in_downtime, ack = @icinga.host_statistics.values

or

    h = @icinga.host_statistics
    pending = h.dig(:pending)


## <a name="stats-work-queue"></a>work_queue_statistics

queue statistics from the api

The result are an `Hash`

### Example
    @icinga.work_queue_statistics

