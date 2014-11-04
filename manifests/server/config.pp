#
# This will install the databases for idoutils and icinga-web if they aren't found.
#   1. The primary icinga (idoutils) DB
#   2. The icinga-web database
#   3. The inGraph database is installed by the setup script in another class
#
# This class is PURPOSELY WEAK.  This class and the installer script(s) associated
# will always favor failing early over unintentionally nuking a working DB.
#
# The remaining resources are obvious for configuring the database-related pieces of
# the packages installed.  Ordering is handled by chains in icinga::server
#

class icinga::server::config (
  $icinga_db_name,
  $icinga_web_db_name,
  $db_username,
  $db_password,
  $db_host,
  $db_type = 'postgres',
  $db_port = '5432',
){

  # The following installs the databases only if they don't exist.  They will look in
  # the default locations and fail otherwise.
  file {
    '/usr/local/bin/install_icinga_databases.sh':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    before  => Exec['Run-DB-Installer'],
    content => template('icinga/usr/local/bin/install_icinga_databases.sh.erb');
  }

  exec {
    'Run-DB-Installer':
    path      => ['/bin', '/usr/bin', '/sbin', '/usr/sbin', '/usr/local/bin'],
    command   => '/usr/local/bin/install_icinga_databases.sh',
    subscribe => Package[$icinga::server::icinga_package, $icinga::server::icinga_web_package],
    unless    => '/usr/local/bin/install_icinga_databases.sh db_check';
  }

}
