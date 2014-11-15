#
# Installs the required packages for the masters and the web interface.
#

class icinga::server::packages (
  $ensure_icinga_package       = $icinga::server::ensure_package,
  $ensure_icinga_web_package   = $icinga::server::ensure_package,
  $ensure_support_packages     = $icinga::server::ensure_package,
  $ensure_web_support_packages = $icinga::server::ensure_package,
  $ensure_db_packages          = $icinga::server::ensure_package,
  $package_directories         = ['/var/lib/icinga', '/var/cache/icinga', '/var/log/icinga', '/var/run/icinga'],
  $ignore_patterns             = '/var/lib/icinga/rw/*',
) {

  # Realize the packages
  ensure_resource('package', $icinga::server::icinga_package,       {'ensure' => $icinga::server::packages::ensure_icinga_package})
  ensure_resource('package', $icinga::server::icinga_web_package,   {'ensure' => $icinga::server::packages::ensure_icinga_web_package})
  ensure_resource('package', $icinga::server::support_packages,     {'ensure' => $icinga::server::packages::ensure_support_packages})
  ensure_resource('package', $icinga::server::web_support_packages, {'ensure' => $icinga::server::packages::ensure_web_support_packages})
  ensure_resource('package', $icinga::server::db_packages,          {'ensure' => $icinga::server::packages::ensure_db_packages})

  # Correct owner and group in case non-standard user(s) are configured. This serves as a catch-all for undefined resources.
 # file {
 #   $package_directories:
 #   ensure  => $icinga::server::ensure_directory,
 #   owner   => $icinga::server::effective_owner,
 #   group   => $icinga::server::effective_group,
 #   ignore  => $ignore_patterns,
 #   require => Package[$icinga::server::icinga_package, $icinga::server::icinga_web_package],
 #   recurse => true;
 # }

  # Correct a VERY bad chown inside of the upstart/init script.
  Exec {
    path => ['/bin/', '/usr/bin', '/sbin', '/usr/sbin'],
  }

  exec {
    'Fix chown calls in icinga init script':
    command => 'sed -i -r "s/(chown[ ]+)/#\1/" /etc/init.d/icinga',
    onlyif  => 'grep -P "[\s]+chown" /etc/init.d/icinga';

    'Fix chown calls in ido2db init script':
    command => 'sed -i -r "s/(chown[ ]+)/#\1/" /etc/init.d/ido2db',
    onlyif  => 'grep -P "[\s]+chown" /etc/init.d/ido2db';
  }
}
