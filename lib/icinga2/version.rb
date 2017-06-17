
# frozen_string_literal: true

module Icinga2

  # namespace for version information
  module Version

    # major part of version
    MAJOR = 0
    # minor part of version
    MINOR = 6
    # tiny part of version
    TINY  = 2

  end

  # Current version of gem.
  VERSION = [Version::MAJOR, Version::MINOR, Version::TINY].compact * '.'

end
