
# frozen_string_literal: true
module Icinga2

  module Version

    MAJOR = 0
    MINOR = 5
    TINY  = 2

  end

  VERSION = [Version::MAJOR, Version::MINOR, Version::TINY].compact * '.'

end

