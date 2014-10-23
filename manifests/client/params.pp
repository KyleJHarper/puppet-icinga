#
# Holds the configuration variables for client classes and definitions.
#
# The default behavior is to auto-select everything with a case statement below.  However, for auto-loading
# we will allow the params values to be overridden in the called classes in case the user really wants to
# for whatever reason(s).
#

class icinga::client::params () {

  # Base ensure attributes to help with clean up if the user wants to purge icinga::client
  $ensure_file               = 'file'
  $ensure_directory          = 'directory'
  $ensure_package            = 'installed'
  $ensure_service            = 'running'
  $ensure_nagios_host        = 'present'
  $ensure_nagios_hostextinfo = 'present'
  $ensure_nagios_service     = 'present'

  # Patterns for allowed values when processing ensurable attributes.
  $ensure_file_pattern         = 'file|present|absent'
  $ensure_directory_pattern    = 'directory|absent'
  $ensure_package_pattern      = 'present|installed|latest|absent|purged'
  $ensure_service_pattern      = 'stopped|running'
  $ensure_nagios_pattern       = 'present|absent'

  # Main Selection Block
  case $::operatingsystem {
    'Ubuntu': {
      $effective_owner = 'nagios'
      $effective_group = 'nagios'
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
