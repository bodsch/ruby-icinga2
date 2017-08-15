# Icinga2 - Notifications


## <a name="enable-host-notification"></a>enable host notifications
    enable_host_notification( host )

### Example
    @icinga.enable_host_notification('icinga')


## <a name="disable-host-notification"></a>disable host notifications
    disable_host_notification( host )

### Example
    @icinga.disable_host_notification('icinga')


## <a name="enable-service-notification"></a>enable service notifications
    enable_service_notification( host )

### Example
    @icinga.enable_service_notification('icinga')


## <a name="disable-service-notification"></a>disable service notifications
    disable_service_notification( host )

### Example
    @icinga.disable_service_notification('icinga')


## <a name="enable-hostgroup-notification"></a>enable hostgroup notifications
    enable_hostgroup_notification( params )

### Example
    @icinga.enable_hostgroup_notification(host: 'icinga2', host_group: 'linux-servers')


## <a name="disable-hostgroup-notification"></a>disable hostgroup notifications
    disable_hostgroup_notification( params )

### Example
    @icinga.disable_hostgroup_notification(host: 'icinga2', host_group: 'linux-servers')


## <a name="list-notifications"></a>list all notifications
    notifications

### Example
    @icinga.notifications


## (protected) function for host notifications
    host_notification( params = {} )

## (protected) function for hostgroup notifications
    hostgroup_notification( params = {} )

## (protected) function for service notifications
    service_notification( params = {} )
