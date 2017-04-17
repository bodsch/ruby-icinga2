# ruby-icinga2

Small Ruby Class for the Icinga2 API


## usage

create an instance and get information about the Icinga2 Server

    config = {
      :icinga => {
        :host => 'icinga2',
        :api => {
          :port => 5665,
          :user => 'icinga',
          :pass => 'icinga'
        }
      }
    }

    i = Icinga::Client.new( config )
    puts( i.applicationData() )


get Information about all monitored hosts

    puts i.listHost()


get Information about a monitored host

    puts i.listHost( 'foo-bar.lan' )


delete a Host

    i.deleteHost( 'foo-bar.lan' )


add a host with custom vars

    vars = {
      'aws' => false
    }
    i.addHost( 'foo-bar.lan', vars )


add services to one host

    services = {
      'service-heap-mem' => {
        'display_name'  => 'Tomcat - Heap Memory',
        'check_command' => 'tomcat-heap-memory',
      }
    }

    i.addServices( 'foo-bar.lan', services )



# requirements

    gem install rest-client --no-rdoc --no-ri
    gem install json --no-rdoc --no-ri


