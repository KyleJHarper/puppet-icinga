#
# Container class for the client-side setup of Icinga, which is actually nagios and nrpe.
#
# It helps tremendously to remember that there are only two (2) Types that need to be called
# from the 'client' in a Nagios setup:  host and services.
# Everything else is information the server keeps track of.  It would be nice to have the
# client classes (i.e. this) read in the server values, such as servicegroups, to help do
# more validation; but it's not.  Furthermore, Icinga has good debugging and failures are
# logged and easy to trace from those logs.
#

class icinga::client (
  # -- These don't change between distributions; no use of params.
  $ensure_file                     = 'file',
  $ensure_directory                = 'directory',
  $ensure_package                  = 'installed',
  $ensure_service                  = 'running',
  $ensure_role                     = 'present',
  $ensure_nagios_host              = 'present',
  $ensure_nagios_service           = 'present',
  $effective_owner                 = 'nagios',
  $effective_group                 = 'nagios',
  # -- These are provided by params which change between distributions.
  $extra_packages                  = $icinga::client::params::extra_packages,
  $nrpe_package                    = $icinga::client::params::nrpe_package,
  $plugin_packages                 = $icinga::client::params::plugin_packages,
  $nrpe_config_file                = $icinga::client::params::nrpe_config_file,
  $nrpe_config_directory           = $icinga::client::params::nrpe_config_directory,
  $nrpe_service                    = $icinga::client::params::nrpe_service,
  $nagios_primary_checks_directory = $icinga::client::params::nagios_primary_checks_directory,
  $nagios_custom_checks_directory  = $icinga::client::params::nagios_custom_checks_directory,
  $sudoers_d_file                  = $icinga::client::params::sudoers_d_file,
  $use_sudo                        = $icinga::client::params::use_sudo,
  $default_hostgroups              = $icinga::client::params::default_hostgroups,
  $objects_directory               = $icinga::client::params::objects_directory,
) inherits ::icinga::client::params {

  # The following has to be done outside param.pp pattern, and outside data bindings above because we NEED hiera_hash.
  $defined_checks      = hiera_hash('icinga::client::defined_checks', {})
  $defined_hostgroups  = hiera_array('icinga::server::defined_hostgroups', [])
  $known_servicegroups = hiera_hash('icinga::server::servicegroups')
  $known_hostgroups    = hiera_hash('icinga::server::hostgroups')

  # Sanity checks for failsauce.  Template compilation failure will result in a fail() call for us.
  $failsauce = template('icinga/failsauce_client_ensures.erb')
  validate_hash($defined_checks, $known_servicegroups, $known_hostgroups)
  validate_array($defined_hostgroups)

  # Chain items for dependency management
  Class['icinga::client']->
  class { 'icinga::client::packages': }->
  class { 'icinga::client::nrpe': }->
  class { 'icinga::client::checks': }->
  class { 'icinga::client::host': }

  # The following nagios types *can* be used/exported, but are deprecated and shouldn't be used.
  # hostextinfo     => http://docs.icinga.org/latest/en/objectdefinitions.html#hostextinfo
  # serviceextinfo  => http://docs.icinga.org/latest/en/objectdefinitions.html#serviceextinfo
}
