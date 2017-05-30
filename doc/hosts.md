# Icinga2 - Hosts

## check
    existsHost()

## add
    vars = {
      'aws' => false
    }

    addHost( 'foo-bar.lan', vars )

## list

### named
    listHosts( 'foo-bar.lan' )

### all
    listHosts()

## delete
    deleteHost( 'foo-bar.lan' )
