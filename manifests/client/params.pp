#
# Holds the configuration variables for client classes and definitions.
#
# The default behavior is to auto-select everything with a case statement below.  However, for auto-loading
# we will allow the params values to be overridden in the called classes in case the user really wants to
# for whatever reason(s).
#

class icinga::client::params () {

  # Base ensure attributes to help with clean up if the user wants to purge icinga::client
  $ensure_file      = 'file'
  $ensure_directory = 'directory'
  $ensure_package   = 'installed'
  $ensure_service   = 'running'

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
      $sudoers_d_file = '/etc/sudoers.d/nagios'
    }
    default: {
      notify{
        'Fallback':
        message => "Your operating system '${::operatingsystem}' is not supported.";
      }
    }
  }
}
