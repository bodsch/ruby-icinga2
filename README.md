# ruby-icinga2

Small Class for the Icinga2 API



## usage

create an instance and get information about the Icinga2 Server

    i = Icinga2.new( 'localhost', 5665, 'root', 'icinga' )
    puts( i.applicationData() )


get Information about all monitored hosts

    puts i.listHost()


get Information about a monitored host

    puts i.listHost( 'foo-bar.lan' )


delete a Host

    i.deleteHost( 'foo-bar.lan' )


add a host

    vars= {
      'aws' => false
    }
    i.addHost( 'foo-bar.lan', vars )


add services to one host

    services = {
      'service-heap-mem' => {
        'display_name' => 'Tomcat - Heap Memory',
        'check_command' => 'tomcat-heap-memory',
      }
    }

    i.addServices( 'foo-bar.lan', services )



# requirements

    gem install rest-client --no-rdoc --no-ri
    gem install json  --no-rdoc --no-ri


