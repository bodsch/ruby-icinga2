
module Icinga

  module Version

    MAJOR = 1
    MINOR = 4
    TINY  = 4

  end

  VERSION = [Version::MAJOR, Version::MINOR, Version::TINY].compact * '.'

end

