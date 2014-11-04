#
# Installs the required packages for the masters and the web interface.
#

class icinga::server::packages (
  $ensure_icinga_package       = $icinga::server::ensure_package,
  $ensure_icinga_web_package   = $icinga::server::ensure_package,
  $ensure_support_packages     = $icinga::server::ensure_package,
  $ensure_web_support_packages = $icinga::server::ensure_package,
  $ensure_db_packages          = $icinga::server::ensure_package,
) {

  # Realize the packages
  ensure_resource('package', $icinga::server::icinga_package,       {'ensure' => $icinga::server::packages::ensure_icinga_package})
  ensure_resource('package', $icinga::server::icinga_web_package,   {'ensure' => $icinga::server::packages::ensure_icinga_web_package})
  ensure_resource('package', $icinga::server::support_packages,     {'ensure' => $icinga::server::packages::ensure_support_packages})
  ensure_resource('package', $icinga::server::web_support_packages, {'ensure' => $icinga::server::packages::ensure_web_support_packages})
  ensure_resource('package', $icinga::server::db_packages,          {'ensure' => $icinga::server::packages::ensure_db_packages})

}
