#
# Container class for the client-side setup of Icinga, which is actually nagios and nrpe.
#

class icinga::client (
  $ensure_file                     = $icinga::client::params::ensure_file,
  $ensure_directory                = $icinga::client::params::ensure_directory,
  $ensure_package                  = $icinga::client::params::ensure_package,
  $ensure_service                  = $icinga::client::params::ensure_service,
  $ensure_host                     = $icinga::client::params::ensure_host,
  $effective_owner                 = $icinga::client::params::effective_owner,
  $effective_group                 = $icinga::client::params::effective_group,
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
  $host_template                   = $icinga::client::params::host_template,
  $objects_directory               = $icinga::client::params::objects_directory,

) inherits icinga::client::params {

  # The following has to be done outside param.pp pattern, and outside data bindings above because we NEED hiera_hash.
  $defined_checks     = hiera_hash('icinga::client::defined_checks', {})
  $defined_hostgroups = hiera_array('icinga::client::defined_hostgroups', [])

  # Sanity checks for failsauce.
  if ($icinga::client::ensure_file      !~ /(file|present|absent)/)                    { fail("The ensure_file variable must be one of file|present|absent, not '${icinga::client::ensure_file}'.") }
  if ($icinga::client::ensure_directory !~ /(directory|absent)/)                       { fail("The ensure_directory variable must be one of directory|absent, not '${icinga::client::ensure_directory}'.") }
  if ($icinga::client::ensure_package   !~ /(present|installed|latest|absent|purged)/) { fail("The ensure_package variable must be one of present|installed|latest|absent|purged, not '${icinga::client::ensure_package}'.") }
  if ($icinga::client::ensure_service   !~ /(stopped|running)/)                        { fail("The ensure_service variable must be one of stopped|running, not '${icinga::client::ensure_service}'.") }
  if ($icinga::client::ensure_host      !~ /(present|absent)/)                         { fail("The ensure_host variable must be one of present|absent, not '${icinga::client::ensure_host}'.") }
  validate_hash($defined_checks)
  validate_array($defined_hostgroups)

  # Chain items for dependency management
  Class['icinga::client']->
  class { 'icinga::client::packages': }->
  class { 'icinga::client::nrpe': }->
#  class { 'icinga::client::checks': }->
  class { 'icinga::client::host': }
#  icinga::client::hostextinfo { $::hostname: }

}
