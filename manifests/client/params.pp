#
# Holds the configuration variables for client classes and definitions.
#
# The default behavior is to auto-select everything with a case statement below.  However, for auto-loading
# we will allow the params values to be overridden in the called classes in case the user really wants to
# for whatever reason(s).
#

class icinga::client::params () {

  # Patterns for allowed values when processing ensurable attributes.
  $ensure_file_pattern         = 'file|present|absent'
  $ensure_directory_pattern    = 'directory|absent'
  $ensure_package_pattern      = 'present|installed|latest|absent|purged|([0-9]+(\.[0-9]+)*)'
  $ensure_service_pattern      = 'stopped|running'
  $ensure_nagios_pattern       = 'present|absent'

  # Information from the server component, which is otherwise inaccessible for client-only manifests.  Mostly for validation purposes.
  $known_servicegroups = hiera_hash('icinga::server::servicegroups')
  $known_hostgroups    = hiera_hash('icinga::server::hostgroups')

  # Main Selection Block
  case $::operatingsystem {
    'Ubuntu': {
      $extra_packages = ['binutils']
      $nrpe_package = 'nagios-nrpe-server'
      $plugin_packages = ['nagios-plugins-basic', 'nagios-plugins-standard', 'libnagios-plugin-perl']
      $nagios_primary_checks_directory = '/usr/lib/nagios/plugins'
      $nagios_custom_checks_directory = '/usr/local/lib/nagios/plugins'
      $nrpe_config_file = '/etc/nagios/nrpe.cfg'
      $nrpe_config_directory = '/etc/nagios/nrpe.d'
      $nrpe_service = 'nagios-nrpe-server'
      $use_sudo = 'true'
      $sudoers_d_file = '/etc/sudoers.d/nagios'
      $default_hostgroups = "${::lsbdistcodename}, ${::environment}, ${::virtual}, ${::domain}, ${::operatingsystem}, ${::osfamily}"
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
