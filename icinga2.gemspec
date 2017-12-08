
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'icinga2/version'

Gem::Specification.new do |s|

  s.name        = 'icinga2'
  s.version     = Icinga2::VERSION
  s.date        = '2017-11-16'
  s.summary     = 'Icinga2 API'
  s.description = 'An enhanced ruby gem to communicate with Icinga2 API'
  s.authors     = ['Bodo Schulz']
  s.email       = 'bodo@boone-schulz.de'

  s.files       = Dir[
    'README.md',
    'LICENSE',
    'lib/**/*',
    'doc/*',
    'examples/*.rb'
  ]

  s.homepage    = 'https://github.com/bodsch/ruby-icinga2'
  s.license     = 'LGPL-2.1+'

  begin

    if( RUBY_VERSION >= '2.0' )
      s.required_ruby_version = '~> 2.0'
    elsif( RUBY_VERSION <= '2.1' )
      s.required_ruby_version = '~> 2.1'
    elsif( RUBY_VERSION <= '2.2' )
      s.required_ruby_version = '~> 2.2'
    elsif( RUBY_VERSION <= '2.3' )
      s.required_ruby_version = '~> 2.3'
    end

    s.add_dependency('ruby_dig', '~> 0') if  RUBY_VERSION < '2.3'

    s.add_dependency('openssl', '~> 2.0') if  RUBY_VERSION >= '2.3'
  rescue => e
    warn "#{$PROGRAM_NAME}: #{e}"
    exit!
  end

  s.add_dependency('json', '~> 2.1')
  s.add_dependency('rest-client', '~> 2.0')

  s.add_development_dependency('rake', '~> 0')
  s.add_development_dependency('rake-notes', '~> 0')
  s.add_development_dependency('rubocop', '~> 0.49.0')
  s.add_development_dependency('rubocop-checkstyle_formatter', '~> 0')
  s.add_development_dependency('rspec', '~> 0')
  s.add_development_dependency('rspec_junit_formatter', '~> 0')
  s.add_development_dependency('rspec-nc', '~> 0')
  s.add_development_dependency('guard', '~> 0')
  s.add_development_dependency('guard-rspec', '~> 0')
  s.add_development_dependency('pry', '~> 0')
  s.add_development_dependency('pry-remote', '~> 0')
  s.add_development_dependency('pry-nav', '~> 0')

end
