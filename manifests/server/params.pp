#
# Holds the configuration variables for server classes and definitions.
#
# The default behavior is to auto-select everything with a case statement below.  However, for auto-loading
# we will allow the params values to be overridden in the called classes in case the user really wants to
# for whatever reason(s).
#

class icinga::server::params () {

  # Patterns for allowed values when processing ensurable attributes.
  $ensure_file_pattern      = 'file|present|absent'
  $ensure_directory_pattern = 'directory|absent'
  $ensure_package_pattern   = 'present|installed|latest|absent|purged|([0-9]+(\.[0-9]+)*)'
  $ensure_service_pattern   = 'stopped|running'
  $ensure_nagios_pattern    = 'present|absent'

  # Main Selection Block
  case $::operatingsystem {
    'Ubuntu': {
      $effective_owner = 'icinga'
      $effective_group = 'icinga'
      $objects_directory = '/etc/icinga/objects'
    }
    default: {
      notify{
        'Fallback':
        message => "Your operating system '${::operatingsystem}' is not supported.";
      }
    }
  }
}
