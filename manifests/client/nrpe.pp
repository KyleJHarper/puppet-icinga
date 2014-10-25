#
# Handles the configuration of nrpe related items.  The package itself is
# installed by the icinga::client::packages class.
#

class icinga::client::nrpe () {
  # Use hiera_hash here to *actually* work right.
  $commands = hiera_hash('icinga::client::nrpe::commands', {})
  validate_hash($commands)

  # -- File defaults
  File {
    owner => $icinga::client::effective_owner,
    group => $icinga::client::effective_group,
    mode  => '0644',
  }

  # -- Basic NRPE Configuration files
  file {
    $icinga::client::nrpe_config_file:
    ensure  => $icinga::client::ensure_file,
    content => template('icinga/etc/nagios/nrpe.cfg.erb'),
    notify  => Service[$icinga::client::nrpe_service],
    require => Package[$icinga::client::nrpe_package];

    $icinga::client::nrpe_config_directory:
    ensure  => $icinga::client::ensure_directory,
    force   => true,
    purge   => true,
    recurse => true;
  }
  create_resources(icinga::client::nrpe_command, $commands)

  # -- Nagios Checks Files (Programs and Scripts)
  file {
    $icinga::client::nagios_custom_checks_directory:
    ensure  => $icinga::client::ensure_directory,
    force   => true,
    purge   => true,
    recurse => true,
    mode    => '0755',
    source  => 'puppet:///modules/icinga/usr/local/lib/nagios/plugins';

    $icinga::client::nagios_primary_checks_directory:
    ensure  => $icinga::client::ensure_directory,
    mode    => '0755',
    force   => true,
    recurse => true,
    purge   => false;
  }

  # -- NRPE Requires sudo if not running as root and/or for certain checks.
  #    If sudo is provided by another system, user should simply set $use_sudo to false.
  if ($icinga::client::use_sudo == 'true') and ($icinga::client::ensure_file =~ /(present|file)/){ $ensure_sudo_file = 'file'   }
  else                                                                                           { $ensure_sudo_file = 'absent' }
  file {
    $icinga::client::sudoers_d_file:
    ensure  => $ensure_sudo_file,
    owner   => 'root',
    group   => 'root',
    mode    => '0440',
    content => template('icinga/etc/sudoers.d/nagios.erb');
  }

  # -- NRPE Service
  if $icinga::client::ensure_package =~ /(installed|latest|present)/ {
    service {
      $icinga::client::nrpe_service:
      ensure     => $icinga::client::ensure_service,
      enable     => true,
      hasrestart => true,
      hasstatus  => false,
      pattern    => 'nrpe',
      require    => [ File[$icinga::client::nrpe_config_file], Package[$icinga::client::nrpe_package] ];
    }
  }

}
