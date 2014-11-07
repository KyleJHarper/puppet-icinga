#
# Configures IDO mod and IDO2DB.
#

class icinga::server::ido_config (
  $debug_file                         = '/var/log/icinga/ido2db.debug',
  $debug_level                        = '0',
  $debug_readable_timestamp           = '0',
  $debug_verbosity                    = '2',
  $housekeeping_thread_startup_delay  = '300',
  $lock_file                          = '/var/run/icinga/ido2db.pid',
  $max_acknowledgements_age           = '44640',
  $max_contactnotificationmethods_age = '44640',
  $max_contactnotifications_age       = '44640',
  $max_debug_file_size                = '100000000',
  $max_downtimehistory_age            = '44640',
  $max_externalcommands_age           = '10080',
  $max_eventhandlers_age              = '10080',
  $max_hostchecks_age                 = '1440',
  $max_logentries_age                 = '44640',
  $max_notifications_age              = '44640',
  $max_servicechecks_age              = '1440',
  $max_systemcommands_age             = '1440',
  $oci_errors_to_syslog               = '1',
  $oracle_trace_level                 = '0',
  $socket_name                        = '/var/lib/icinga/ido.sock',
  $socket_perm                        = '0755',
  $socket_type                        = 'unix',
  $tcp_port                           = '5668',
  $trim_db_interval                   = '3600',
  $use_ssl                            = '0',

){

  File {
    owner => $icinga::server::effective_owner,
    group => $icinga::server::effective_group,
    mode  => '0644',
  }

  file {
    '/etc/icinga/ido2db.cfg':
    ensure  => $icinga::server::ensure_file,
    mode    => '0600',
    content => template('icinga/etc/icinga/ido2db.cfg.erb'),
    notify  => Service[$icinga::server::ido2db_service];

    # Add idomod config file here
  }

}
