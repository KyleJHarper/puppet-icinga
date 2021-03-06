#
# Installs the packages necessary for the nagios client to run.  This includes mostly nrpe and plugins.
# Core configuration files for the packages are also configured here.
#

class icinga::client::packages (
  $ensure_nrpe_package = $icinga::client::ensure_package,
) {

  # Realize the packages
  ensure_resource('package', $icinga::client::nrpe_package,    {'ensure' => $icinga::client::packages::ensure_nrpe_package })
  ensure_resource('package', $icinga::client::plugin_packages, {'ensure' => $icinga::client::ensure_package })
  ensure_resource('package', $icinga::client::extra_packages,  {'ensure' => $icinga::client::ensure_package })

}
