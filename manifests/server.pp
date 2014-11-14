#
# Handles building the server(s) for an Icinga master.
#

class icinga::server (
  # -- These don't change between distributions; no use of params.
  $icinga_db_name,
  $icinga_web_db_name,
  $db_username,
  $db_password,
  $db_host,
  $db_type                    = 'postgres',
  $db_port                    = '5432',
  $ensure_file                = 'file',
  $ensure_directory           = 'directory',
  $ensure_package             = 'installed',
  $ensure_service             = 'running',
  $ensure_role                = 'present',
  $ensure_nagios_hostgroup    = 'present',
  $ensure_nagios_servicegroup = 'present',
  $effective_owner            = 'icinga',
  $effective_group            = 'icinga',
  $purged_resources           = ['nagios_command', 'nagios_contact', 'nagios_contactgroup', 'nagios_host', 'nagios_hostgroup', 'nagios_service', 'nagios_servicegroup'],
  # -- These are provided by params which change between distributions.
  $icinga_package             = $icinga::server::params::icinga_package,
  $icinga_web_package         = $icinga::server::params::icinga_web_package,
  $support_packages           = $icinga::server::params::support_packages,
  $web_support_packages       = $icinga::server::params::web_support_packages,
  $objects_directory          = $icinga::server::params::objects_directory,
  $icinga_service             = $icinga::server::params::icinga_service,
  $ido2db_service             = $icinga::server::params::ido2db_service,
  $ingraphd_service           = $icinga::server::params::ingraphd_service,
  $ingraph_collector_service  = $icinga::server::params::ingraph_collector_service,
  $db_type                    = 'postgres',
  $db_port                    = '5432',

) inherits icinga::server::params {

  # The following has to be done outside param.pp pattern, and outside data bindings above because we NEED hiera_hash.
  $servicegroups = hiera_hash('icinga::server::servicegroups')
  $hostgroups    = hiera_hash('icinga::server::hostgroups')

  # Validation
  validate_hash($servicegroups, $hostgroups)
  $optimus_failsauce_prime = template('icinga/failsauce_server_ensures.erb')

  # Chain dependencies here
  Class['server']->
  class{'apache': purge_configs => false }->
  class{'icinga::server::roles': }->
  class{'icinga::server::package_provider': }->
  class{'icinga::server::packages': }->
  class{'icinga::server::ido_config': }->
  class{'icinga::server::config': }->
#  class{'icinga::server::ingraph': }
  class{'icinga::server::services': }

  # Use arrows to define the pattern of operations so we don't get race conditions.
  #class { 'icinga::server::ppa': }->
  #class { 'icinga::server::icinga_packages': }->
  #class { 'icinga::server::install': }->
  #class { 'icinga::server::icinga_web_packages': }->
  #class { 'icinga::server::ingraph_packages': }->
  #class { 'icinga::server::ingraph_install': }->
  #class { 'icinga::server::config': }->
  #class { 'icinga::server::services': }->
  #Class['icinga::server']

  # Include items after the pre-req classes have installed.
  #include icinga::nagios::command
  #include icinga::nagios::contact
  #include icinga::nagios::host
  #include icinga::nagios::service
  #include icinga::nagios::timeperiod
  #include icinga::nagios::downtime

  # Purge resources explicitly which are no longer tied to valid nodes since the last run.
  resources { $purged_resources: purge => true; }

}
