# Icinga2 - Notifications


## enable host notifications
    enable_host_notification( host )

**example**
    @icinga.enable_host_notification('icinga')

## disable host notifications
    disable_host_notification( host )

**example**
    @icinga.disable_host_notification('icinga')

## enable service notifications
    enable_service_notification( host )

**example**
    @icinga.enable_service_notification('icinga')

## disable service notifications
    disable_service_notification( host )

**example**
    @icinga.disable_service_notification('icinga')

## enable hostgroup notifications
    enable_hostgroup_notification( params )

**example**
    @icinga.enable_hostgroup_notification(host: 'icinga2', host_group: 'linux-servers')

## disable hostgroup notifications
    disable_hostgroup_notification( params )

**example**
    @icinga.disable_hostgroup_notification(host: 'icinga2', host_group: 'linux-servers')

## all notifications
    notifications

**example**
    @icinga.notifications


## **protected** function for host notifications
    host_notification( params = {} )

## **protected** function for hostgroup notifications
    hostgroup_notification( params = {} )

## **protected** function for service notifications
    service_notification( params = {} )
