#
# Container class for the client-side setup of Icinga, which is actually nagios and nrpe.
#

class icinga::client (
  $ensure_file                     = $icinga::client::params::ensure_file,
  $ensure_directory                = $icinga::client::params::ensure_directory,
  $ensure_package                  = $icinga::client::params::ensure_package,
  $ensure_service                  = $icinga::client::params::ensure_service,
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

) inherits icinga::client::params {

  # Chain items for dependency management
  Class['icinga::client']->
  class { 'icinga::client::packages': }->
  class { 'icinga::client::nrpe': }
  #class { 'icinga::client::basechecks': }->

}
