# Icinga2 - Services


## <a name="add-service"></a>*add_services( params )*

Add a Service to Icinga2

`params` is an `Hash` with following Parameters:

| Parameter                | Type    | Example           | Description
| :--------------------    | :-----: | :-----            | :-----------
| `host_name`              | String  | `foo`             | existing Host for these Service
| `name`                   | String  | `ping4`           | Service Name they will be create
| `display_name`           | String  | `ping4 check`     | displayed Name
| `templates`              | Array   | `['own-service']` | (optional) a Array of templates (default: `['generic-service']`)
| `check_command`          | String  | `ping4`           | The Check Command to execute (**Importand** This Check-Comand must be exists! Otherwise an error will occur)
| `check_interval`         | Integer | `10`              | The check Interval
| `retry_interval`         | Integer | `30`              | The retry Interval
| `notes`                  | String  | ``                |
| `notes_url`              | String  | ``                |
| `action_url`             | String  | ``                |
| `check_period`           | String  | ``                |
| `check_timeout`          | Integer | ``                |
| `command_endpoint`       | String  | ``                |
| `enable_active_checks`   | Bool    | ``                |
| `enable_event_handler`   | Bool    | ``                |
| `enable_flapping`        | Bool    | ``                |
| `enable_notifications`   | Bool    | ``                |
| `enable_passive_checks`  | Bool    | ``                |
| `enable_perfdata`        | Bool    | ``                |
| `event_command`          | String  | ``                |
| `flapping_threshold_high`| Integer | ``                |
| `flapping_threshold_low` | Integer | ``                |
| `flapping_threshold`     | Integer | ``                |
| `icon_image_alt`         | String  | ``                |
| `icon_image`             | String  | ``                |
| `max_check_attempts`     | Integer | ``                |
| `volatile`               | Bool    | ``                |
| `vars`                   | Hash    | (see below)       | optional config params for the `check_command`

The result are an `Hash`

### Example

    @icinga.add_services(
      host_name: 'foo',
      name: 'ping4',
      check_command: 'ping4',
      check_interval: 10,
      retry_interval: 30
    )

or

    @icinga.add_service(
      host_name: 'foo',
      name: 'http',
      check_command: 'http',
      check_interval: 10,
      retry_interval: 30,
      vars: {
        http_address: '127.0.0.1',
        http_url: '/access/index',
        http_port: 80
      }
    )



## <a name="delete-service"></a>*delete_service( params )*

Delete an Service From Icinga2

`params` is an `Hash` with following Parameters:

| Parameter              | Type    | Example           | Description
| :--------------------  | :-----: | :-----            | :-----------
| `host`                 | String  | `foo`             | existing Host for these Service
| `name`                 | String  | `ping4`           | Service Name they will be deleted
| `cascade`              | Bool    | `true`            | delete service also when other objects depend on it (default: `false`)


The result are an `Hash`

#### Example

    @icinga.delete_service(host_name: 'foo', name: 'ping4')

or

    @icinga.delete_service(host_name: 'foo', name: 'new_ping4', cascade: true)


## <a name="modify-service"></a>*modify_service( params )*

Modify an Service.

`params` is an `Hash` with following Parameters:

| Parameter              | Type    | Example           | Description
| :--------------------  | :-----: | :-----            | :-----------
| `name`                 | String  | `ping4`           | Service Name they will be deleted
| `templates`            | Array   | `['own-service']` | (optional) a Array of templates (default: `['generic-service']`)
| `vars`                 | Hash    | (see below)       | Hash with custom options (see `add_services()`)

The result are an `Hash`

#### Example

    @icinga.modify_service(
      name: 'http2',
      check_interval: 60,
      retry_interval: 10,
      vars: {
        http_url: '/access/login'     ,
        http_address: '10.41.80.63'
      }
    )


## <a name="unhandled-services"></a>*unhandled_services*

return all unhandled services

The result are an `Hash`

#### Example
    @icinga.unhandled_services


## <a name="list-services"></a>*services* or *services( params )*

returns all or a named service

the optional `params` is an `Hash` with following Parameters:

| Parameter              | Type    | Example | Description
| :--------------------  | :-----: | :-----  | :-----------
| `host`                 | String  | `foo`   | Hostname
| `service`              | String  | `ping4` | service to list

The result are an `Hash`

### list all services
    services

#### Example
    @icinga.services


### list named service
    services( params )

#### Example
    @icinga.services( host_name: 'icinga2', service: 'ping4' )


## <a name="service-exists"></a>*exists_service?( params )*

check if the service exists

the optional `params` is an `Hash` with following Parameters:

| Parameter              | Type    | Example | Description
| :--------------------  | :-----: | :-----  | :-----------
| `host`                 | String  | `foo`   | Hostname
| `service`              | String  | `ping4` | servicename

The result are an `Hash`

### Example
    @icinga.exists_service?( host_name: 'icinga2', service: 'users' )


## <a name="list-service-objects"></a>*service_objects( params )*

list service objects

the optional `params` is an `Hash` with following Parameters:

| Parameter              | Type    | Example | Description
| :--------------------  | :-----: | :-----  | :-----------
| `attrs`                | Array   | `[]`    | Array of `attrs`
| `filter`               | Array   | `[]`    | Array of `filter`
| `joins`                | Array   | `[]`    | Array of `joins`

For more Examples for Quering Objects read the [Icinga2 Documentation](https://www.icinga.com/docs/icinga2/latest/doc/12-icinga2-api/#querying-objects)

 - defaults for `attrs` are `['name', 'state', 'acknowledgement', 'downtime_depth', 'last_check']`
 - defaults for `filter` are `[]`
 - defaults for `joins` are `['host.name','host.state','host.acknowledgement','host.downtime_depth','host.last_check']`

The result are an `Array`

### Example
    @icinga.service_objects(
      attrs: ['name', 'state'],
      joins: ['host.name','host.state']
    )


## <a name="services-adjusted"></a>*services_adjusted*

returns adjusted service state

The result are an `Hash`

### Example

    warning, critical, unknown = @icinga.services_adjusted.values

or

    s = @icinga.services_adjusted
    unknown = s.dig(:unknown)


## <a name="count-services-with-problems"></a>*count_services_with_problems*

count services with problems

The result are an `Integer`

### Example
    @icinga.count_services_with_problems


## <a name="list-services-with-problems"></a>*list_services_with_problems( max_items )*

list of services with problems

The result are an `Hash`

### Example

    problems, problems_and_severity = @icinga.list_services_with_problems(10).values

or

    l = @icinga.list_services_with_problems(10)
    problems_and_severity = l.dig(:services_with_problems_and_severity)


## <a name="services-all"></a>*services_all*

count all services

The result are an `Integer`

### Example

    @icinga.services_all


## <a name="service-problems"></a>*service_problems*

returns data with service problems

The result are an `Hash`

### Example

    all, warning, critical, unknown, pending, in_downtime, acknowledged, adjusted_warning, adjusted_critical, adjusted_unknown = @icinga.service_problems.values

or

    p = @icinga.service_problems
    warning = p.dig(:warning)


## <a name=""></a>*service_severity( params )* (protected)

calculate a service severity
(taken from the IcingaWeb2 Code)

The result are an `Integer`

### Example
    service_severity( {'attrs' => { 'state' => 0.0, 'acknowledgement' => 0.0, 'downtime_depth' => 0.0 } } )



## <a name=""></a>*update_host( hash, host )* (private)

update host

The result are an `Hash`

### Example
    service_severity( {'attrs' => { 'state' => 0.0, 'acknowledgement' => 0.0, 'downtime_depth' => 0.0 } } )

