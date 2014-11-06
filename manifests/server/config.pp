#
# This class sets up several configuration files for the packages we've installed.
#
# This will also install the databases for idoutils and icinga-web if they aren't found.
#   1. The primary icinga (idoutils) DB
#   2. The icinga-web database
#   3. The inGraph database is installed by the setup script in another class
#

class icinga::server::config (
  $icinga_db_name,
  $icinga_web_db_name,
  $db_username,
  $db_password,
  $db_host,
  $db_type                                 = 'postgres',
  $db_port                                 = '5432',
  $ido__debug_file                         = '/var/log/icinga/ido2db.debug',
  $ido__debug_level                        = '0',
  $ido__debug_readable_timestamp           = '0',
  $ido__debug_verbosity                    = '2',
  $ido__housekeeping_thread_startup_delay  = '300',
  $ido__lock_file                          = '/var/run/icinga/ido2db.pid',
  $ido__max_acknowledgements_age           = '44640',
  $ido__max_contactnotificationmethods_age = '44640',
  $ido__max_contactnotifications_age       = '44640',
  $ido__max_debug_file_size                = '100000000',
  $ido__max_downtimehistory_age            = '44640',
  $ido__max_externalcommands_age           = '10080',
  $ido__max_eventhandlers_age              = '10080',
  $ido__max_hostchecks_age                 = '1440',
  $ido__max_logentries_age                 = '44640',
  $ido__max_notifications_age              = '44640',
  $ido__max_servicechecks_age              = '1440',
  $ido__max_systemcommands_age             = '1440',
  $ido__oci_errors_to_syslog               = '1',
  $ido__oracle_trace_level                 = '0',
  $ido__socket_name                        = '/var/lib/icinga/ido.sock',
  $ido__socket_perm                        = '0755',
  $ido__socket_type                        = 'unix',
  $ido__tcp_port                           = '5668',
  $ido__trim_db_interval                   = '3600',
  $ido__use_ssl                            = '0',
  $icinga__ICINGACFG                       = '/etc/icinga/icinga.cfg',
  $icinga__CGICFG                          = '/etc/icinga/cgi.cfg',
  $icinga__NICENESS                        = '5',
  $icinga__IDO2DB                          = 'yes',
  $icinga__TMPDIR                          = '/tmp',

){

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
    before  => Exec['Run-DB-Installer'],
    content => template('icinga/usr/local/bin/install_icinga_databases.sh.erb');

    '/etc/icinga/ido2db.cfg':
    ensure  => $icinga::server::ensure_file,
    mode    => '0600',
    content => template('icinga/etc/icinga/ido2db.cfg.erb'),
    notify  => Exec['Reload-ido2db'];

    '/etc/default/icinga':
    ensure  => $icinga::server::ensure_file,
    content => template('icinga/etc/default/icinga.erb'),
    notify  => Exec['Reload-icinga', 'Reload-ido2db'];

    '/etc/icinga/icinga.cfg':
    ensure  => $icinga::server::ensure_file,
    source  => template('icinga/etc/icinga/icinga.cfg.erb'),
    before  => File['/etc/default/icinga'],
    notify  => Exec['Reload-icinga'];

    '/etc/icinga/commands.cfg':
    ensure  => file,
    mode    => '0644',
    source  => 'puppet:///modules/icinga/etc/icinga/commands.cfg',
    notify  => Exec['Reload-icinga'];

    '/etc/icinga/objects':
    ensure  => directory,
    recurse => true,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/icinga/etc/icinga/objects';

  }

  Exec {
    path => ['/bin', '/usr/bin', '/sbin', '/usr/sbin', '/usr/local/bin'],
  }
  exec {
    'Run-DB-Installer':
    command   => '/usr/local/bin/install_icinga_databases.sh',
    subscribe => Package[$icinga::server::icinga_package, $icinga::server::icinga_web_package],
    unless    => '/usr/local/bin/install_icinga_databases.sh db_check';

    'Reload-ido2db':
    command     => '',
    refreshonly => true;
    'Reload-ido2db':
    command     => '/usr/sbin/service ido2db restart',
    refreshonly => true,
    subscribe   => [ File['/etc/icinga/ido2db.cfg'], File['/etc/default/icinga'] ];

    'Reload-icinga':
    command     => '/usr/sbin/service icinga restart',
    refreshonly => true,
    subscribe   => [ File['/etc/default/icinga'], File['/etc/icinga/icinga.cfg'] ];

    'Reload-apache':
    command     => '/usr/sbin/service apache2 restart',
    refreshonly => true,
    subscribe   => File['/etc/icinga-web/conf.d/databases.xml'];

    'Clear-cache':
    command     => '/usr/lib/icinga-web/bin/clearcache.sh',
    refreshonly => true,
    subscribe   => File['/etc/icinga-web/conf.d/databases.xml'];

    'fix-permissions':
    command     => '/bin/chmod -R go+r /etc/icinga/objects',
    refreshonly => true,
    notify      => Service['icinga'];

  }

}
