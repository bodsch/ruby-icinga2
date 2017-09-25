
# frozen_string_literal: true

module Icinga2

  # namespace for version information
  module Version

    # major part of version
    MAJOR = 0
    # minor part of version
    MINOR = 8
    # tiny part of version
    TINY  = 98
    # patch part
    PATCH = 2

  end

  # Current version of gem.
  VERSION = [Version::MAJOR, Version::MINOR, Version::TINY, Version::PATCH].compact * '.'

end
