#
# Holds the configuration variables for server classes and definitions.
#
# The default behavior is to auto-select everything with a case statement below.  However, for auto-loading
# we will allow the params values to be overridden in the called classes in case the user really wants to
# for whatever reason(s).
#

class icinga::server::params () {

  # Patterns for allowed values when processing ensurable attributes.
  $ensure_file_pattern      = 'file|present|absent'
  $ensure_directory_pattern = 'directory|absent'
  $ensure_package_pattern   = 'present|installed|latest|absent|purged|([0-9]+(\.[0-9]+)*)'
  $ensure_service_pattern   = 'stopped|running'
  $ensure_nagios_pattern    = 'present|absent'

  # Main Selection Block
  case $::operatingsystem {
    'Ubuntu': {
      $effective_owner           = 'icinga'
      $effective_group           = 'icinga'
      $objects_directory         = '/etc/icinga/objects'
      $icinga_package            = 'icinga'
      $icinga_web_package        = 'icinga-web'
      $support_packages          = ['icinga-idoutils', 'nagios-nrpe-plugin']
      $web_support_packages      = ['python-sqlalchemy', 'python-setuptools', 'php5-curl', 'python-mysqldb', 'python-pygresql', 'python-psycopg2', 'php5', 'php5-cli', 'php-pear', 'php5-xmlrpc', 'php5-xsl', 'php-soap', 'php5-gd', 'php5-ldap', 'php5-pgsql']
      $db_packages               = ['dbconfig-common', 'mysql-client-5.5', 'postgresql-client-8.4', 'libdbd-mysql', 'libdbd-pgsql']
      $ido2db_service            = 'ido2db'
      $icinga_service            = 'icinga'
      $ingraph_service           = 'ingraphd'
      $ingraph_collector_service = 'ingraph-collector'
    }
    default: {
      notify{
        'Fallback':
        message => "Your operating system '${::operatingsystem}' is not supported.";
      }
    }
  }
}
