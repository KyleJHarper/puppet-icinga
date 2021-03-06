#
# This class sets up several configuration files for the packages we've installed.
#
# This will also install the databases for idoutils and icinga-web if they aren't found.
#   1. The primary icinga (idoutils) DB
#   2. The icinga-web database
#   3. The inGraph database is installed by the setup script in another class
#

class icinga::server::config (
  $ICINGACFG                                   = '/etc/icinga/icinga.cfg',
  $CGICFG                                      = '/etc/icinga/cgi.cfg',
  $NICENESS                                    = '5',
  $IDO2DB                                      = 'yes',
  $TMPDIR                                      = '/tmp',
  $accept_passive_host_checks                  = '1',
  $accept_passive_service_checks               = '1',
  $additional_freshness_latency                = '15',
  $admin_email                                 = 'root@localhost',
  $admin_pager                                 = 'pageroot@localhost',
  $allow_empty_hostgroup_assignment            = '',
  $auto_reschedule_checks                      = '0',
  $auto_rescheduling_interval                  = '30',
  $auto_rescheduling_window                    = '180',
  $broker_module                               = '/usr/lib/icinga/idomod.so config_file=/etc/icinga/idomod.cfg',
  $cached_host_check_horizon                   = '15',
  $cached_service_check_horizon                = '15',
  $cfg_dirs                                    = ['/etc/icinga/modules', '/etc/icinga/objects', '/etc/nagios-plugins/config'],
  $cfg_files                                   = '/etc/icinga/commands.cfg',
  $check_external_commands                     = '1',
  $check_for_orphaned_hosts                    = '1',
  $check_for_orphaned_services                 = '1',
  $check_host_freshness                        = '0',
  $check_result_path                           = '/var/lib/icinga/spool/checkresults',
  $check_result_reaper_frequency               = '10',
  $check_service_freshness                     = '1',
  $child_processes_fork_twice                  = '',
  $command_check_interval                      = '-1',
  $command_file                                = '/var/lib/icinga/rw/icinga.cmd',
  $daemon_dumps_core                           = '0',
  $date_format                                 = 'iso8601',
  $debug_file                                  = '/var/log/icinga/icinga.debug',
  $debug_level                                 = '0',
  $debug_verbosity                             = '2',
  $dump_retained_host_service_states_to_neb    = '0',
  $enable_embedded_perl                        = '1',
  $enable_environment_macros                   = '1',
  $enable_event_handlers                       = '1',
  $enable_flap_detection                       = '1',
  $enable_notifications                        = '1',
  $enable_predictive_host_dependency_checks    = '1',
  $enable_predictive_service_dependency_checks = '1',
  $enable_state_based_escalation_ranges        = '',
  $event_broker_options                        = '-1',
  $event_handler_timeout                       = '30',
  $event_profiling_enabled                     = '0',
  $execute_host_checks                         = '1',
  $execute_service_checks                      = '1',
  $external_command_buffer_slots               = '4096',
  $free_child_process_memory                   = '',
  $global_host_event_handler                   = '',
  $global_service_event_handler                = '',
  $high_host_flap_threshold                    = '20.0',
  $high_service_flap_threshold                 = '20.0',
  $host_check_timeout                          = '30',
  $host_freshness_check_interval               = '60',
  $host_inter_check_delay_method               = 's',
  $host_perfdata_command                       = '',
  $host_perfdata_file_mode                     = 'a',
  $host_perfdata_file_processing_command       = 'process-host-perfdata-file',
  $host_perfdata_file_processing_interval      = '30',
  $host_perfdata_file_template                 = 'DATATYPE::HOSTPERFDATA\tTIMET::$TIMET$\tHOSTNAME::$HOSTNAME$\tHOSTPERFDATA::$HOSTPERFDATA$\tHOSTCHECKCOMMAND::$HOSTCHECKCOMMAND$\tHOSTSTATE::$HOSTSTATE$\tHOSTSTATETYPE::$HOSTSTATETYPE$',
  $host_perfdata_file                          = '/var/cache/icinga/perfdata/host-perfdata.out',
  $host_perfdata_process_empty_results         = '',
  $icinga_group                                = $icinga::server::effective_group,
  $icinga_user                                 = $icinga::server::effective_owner,
  $illegal_macro_output_chars                  = '`~$&|"<>',
  $illegal_object_name_chars                   = '`~!$%^&*|"<>?,()=:',
  $interval_length                             = '60',
  $keep_unknown_macros                         = '0',
  $lock_file                                   = '/var/run/icinga/icinga.pid',
  $log_archive_path                            = '/var/log/icinga/archives',
  $log_current_states                          = '1',
  $log_event_handlers                          = '1',
  $log_external_commands                       = '1',
  $log_file                                    = '/var/log/icinga/icinga.log',
  $log_host_retries                            = '1',
  $log_initial_states                          = '0',
  $log_long_plugin_output                      = '0',
  $log_notifications                           = '1',
  $log_passive_checks                          = '1',
  $log_rotation_method                         = 'd',
  $log_service_retries                         = '1',
  $low_host_flap_threshold                     = '5.0',
  $low_service_flap_threshold                  = '5.0',
  $max_check_result_file_age                   = '3600',
  $max_check_result_list_items                 = '',
  $max_check_result_reaper_time                = '30',
  $max_concurrent_checks                       = '0',
  $max_debug_file_size                         = '100000000',
  $max_host_check_spread                       = '30',
  $max_service_check_spread                    = '30',
  $notification_timeout                        = '30',
  $object_cache_file                           = '/var/cache/icinga/objects.cache',
  $obsess_over_hosts                           = '0',
  $obsess_over_services                        = '0',
  $ochp_command                                = '',
  $ocsp_command                                = '',
  $ocsp_timeout                                = '5',
  $p1_file                                     = '/usr/lib/icinga/p1.pl',
  $passive_host_checks_are_soft                = '0',
  $perfdata_timeout                            = '5',
  $precached_object_file                       = '/var/cache/icinga/objects.precache',
  $process_performance_data                    = '1',
  $resource_file                               = '/etc/icinga/resource.cfg',
  $retained_contact_host_attribute_mask        = '0',
  $retained_contact_service_attribute_mask     = '0',
  $retained_host_attribute_mask                = '0',
  $retained_process_host_attribute_mask        = '0',
  $retained_process_service_attribute_mask     = '0',
  $retained_service_attribute_mask             = '0',
  $retain_state_information                    = '1',
  $retention_update_interval                   = '60',
  $service_check_timeout                       = '60',
  $service_check_timeout_state                 = 'u',
  $service_freshness_check_interval            = '60',
  $service_inter_check_delay_method            = 's',
  $service_interleave_factor                   = 's',
  $service_perfdata_command                    = '',
  $service_perfdata_file_mode                  = 'a',
  $service_perfdata_file_processing_command    = 'process-service-perfdata-file',
  $service_perfdata_file_processing_interval   = '30',
  $service_perfdata_file_template              = 'DATATYPE::SERVICEPERFDATA\tTIMET::$TIMET$\tHOSTNAME::$HOSTNAME$\tSERVICEDESC::$SERVICEDESC$\tSERVICEPERFDATA::$SERVICEPERFDATA$\tSERVICECHECKCOMMAND::$SERVICECHECKCOMMAND$\tHOSTSTATE::$HOSTSTATE$\tHOSTSTATETYPE::$HOSTSTATETYPE$\tSERVICESTATE::$SERVICESTATE$\tSERVICESTATETYPE::$SERVICESTATETYPE$',
  $service_perfdata_file                       = '/var/cache/icinga/perfdata/service-perfdata.out',
  $service_perfdata_process_empty_results      = '',
  $sleep_time                                  = '0.25',
  $soft_state_dependencies                     = '0',
  $stalking_event_handlers_for_hosts           = '0',
  $stalking_event_handlers_for_services        = '0',
  $stalking_notifications_for_hosts            = '0',
  $stalking_notifications_for_services         = '0',
  $state_retention_file                        = '/var/cache/icinga/retention.dat',
  $status_file                                 = '/var/lib/icinga/status.dat',
  $status_update_interval                      = '10',
  $sync_retention_file                         = '',
  $syslog_local_facility                       = '5',
  $temp_file                                   = '/var/cache/icinga/icinga.tmp',
  $temp_path                                   = '/tmp',
  $time_change_threshold                       = '',
  $translate_passive_host_checks               = '0',
  $use_aggressive_host_checking                = '0',
  $use_daemon_log                              = '1',
  $use_embedded_perl_implicitly                = '1',
  $use_large_installation_tweaks               = '0',
  $use_regexp_matching                         = '0',
  $use_retained_program_state                  = '1',
  $use_retained_scheduling_info                = '1',
  $use_syslog                                  = '1',
  $use_syslog_local_facility                   = '0',
  $use_timezone                                = '',
  $use_true_regexp_matching                    = '0',

){

  $failsauce_icinga     = template('icinga/failsauce_icinga.erb')
  $command_file_dirname = inline_template('<%= File.dirname(@command_file) %>')
  File {
    owner => $icinga::server::effective_owner,
    group => $icinga::server::effective_group,
    mode  => '0644',
  }

  file {
    '/usr/local/bin/install_icinga_databases.sh':
    ensure  => $icinga::server::ensure_file,
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    content => template('icinga/usr/local/bin/install_icinga_databases.sh.erb');

    '/etc/default/icinga':
    ensure  => $icinga::server::ensure_file,
    content => template('icinga/etc/default/icinga.erb'),
    notify  => Service[$icinga::server::icinga_service, $icinga::server::ido2db_service];

    '/etc/icinga/icinga.cfg':
    ensure  => $icinga::server::ensure_file,
    content => template('icinga/etc/icinga/icinga.cfg.erb'),
    notify  => Service[$icinga::server::icinga_service];

#    '/etc/icinga/commands.cfg':
#    ensure  => file,
#    mode    => '0644',
#    source  => 'puppet:///modules/icinga/etc/icinga/commands.cfg',
#    notify  => Service[$icinga::server::icinga_service];
#
#    '/etc/icinga/objects':
#    ensure  => directory,
#    recurse => true,
#    owner   => 'root',
#    group   => 'root',
#    mode    => '0644',
#    source  => 'puppet:///modules/icinga/etc/icinga/objects';

    $command_file_dirname:
    ensure => $icinga::server::ensure_directory,
    mode   => '0770';
  }

  exec {
    'Run-DB-Installer':
    command => '/usr/local/bin/install_icinga_databases.sh',
    unless  => '/usr/local/bin/install_icinga_databases.sh db_check';
  }

}
