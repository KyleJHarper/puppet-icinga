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
    owner => $effective_owner,
    group => $effective_group,
    mode  => '0644',
  }

  # -- Configuration files
  file {
    $nrpe_config_file:
    ensure  => $ensure_file,
    content => template('icinga/etc/nagios/nrpe.cfg.erb'),
    notify  => Service[$nrpe_service],
    require => Package[$nrpe_package];

    $nrpe_config_directory:
    ensure  => $ensure_directory,
    purge   => true,
    recurse => true;

    $nagios_custom_checks_directory:
    ensure  => $ensure_directory,
    force   => true,
    purge   => true,
    recurse => true,
    mode    => '0755',
    source  => 'puppet:///modules/icinga/usr/local/lib/nagios/plugins';

    $nagios_primary_checks_directory:
    ensure  => $ensure_directory,
    mode    => '0755',
    recurse => true,
    purge   => false;
  }
  create_resources(icinga::client::nrpe_command, $commands)

  # -- NRPE Requires sudo if not running as root and/or for certain checks.
  #    If sudo is provided by another system, user should simply set $use_sudo to false.
  if $use_sudo {
    file {
      $sudoers_d_file:
      ensure  => $ensure_file,
      owner   => 'root',
      group   => 'root',
      mode    => '0440',
      content => template('icinga/etc/sudoers.d/nagios.erb');
    }
  }

  # -- NRPE Service
  if $ensure_package =~ /(installed|latest|present)/ {
    service {
      $nrpe_service:
      ensure     => $ensure_service,
      enable     => true,
      hasrestart => true,
      hasstatus  => false,
      pattern    => 'nrpe',
      require    => [ File[$nrpe_config_file], Package[$nrpe_package] ];
    }
  }

}
