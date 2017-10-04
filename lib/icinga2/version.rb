
# frozen_string_literal: true

module Icinga2

  # namespace for version information
  module Version

    # major part of version
    MAJOR = 0
    # minor part of version
    MINOR = 9
    # tiny part of version
    TINY  = 95
    # patch part
    PATCH = 5

  end

  # Current version of gem.
  VERSION = [Version::MAJOR, Version::MINOR, Version::TINY, Version::PATCH].compact * '.'

end
