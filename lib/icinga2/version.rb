
# frozen_string_literal: true

module Icinga2

  #
  #
  #
  module Version

    MAJOR = 0
    MINOR = 6
    TINY  = 1

  end

  VERSION = [Version::MAJOR, Version::MINOR, Version::TINY].compact * '.'

end
