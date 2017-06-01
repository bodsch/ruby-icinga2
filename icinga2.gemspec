
Gem::Specification.new do |s|
  s.name        = 'icinga2'
  s.version     = '1.4.9'
  s.date        = '2017-06-01'
  s.summary     = 'Icinga2 API'
  s.description = 'Ruby Class for the Icinga2 API'
  s.authors     = ['Bodo Schulz']
  s.email       = 'bodo@boone-schulz.de'
  s.files       = [
    'lib/icinga2.rb',
    'lib/logging.rb',
    'lib/icinga2/converts.rb',
    'lib/icinga2/downtimes.rb',
    'lib/icinga2/hostgroups.rb',
    'lib/icinga2/hosts.rb',
    'lib/icinga2/network.rb',
    'lib/icinga2/notifications.rb',
    'lib/icinga2/servicegroups.rb',
    'lib/icinga2/services.rb',
    'lib/icinga2/status.rb',
    'lib/icinga2/tools.rb',
    'lib/icinga2/usergroups.rb',
    'lib/icinga2/users.rb',
    'lib/icinga2/version.rb',
    'examples/test.rb',
    'README.md',
    'LICENSE',
    'doc/downtimes.md',
    'doc/examples',
    'doc/hostgroups.md',
    'doc/hosts.md',
    'doc/notifications.md',
    'doc/servicegroups.md',
    'doc/services.md',
    'doc/usergroups.md',
    'doc/users.md'
  ]
  s.homepage    = 'https://github.com/bodsch/ruby-icinga2'
  s.license     = 'LGPL-2.1+'
end
