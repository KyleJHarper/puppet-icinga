#
# Installs the packages necessary for the nagios client to run.  This includes mostly nrpe and plugins.
# Core configuration files for the packages are also configured here.
#

class icinga::client::packages () {

  # Realize the packages
  package {
    $extra_packages:
    ensure => $ensure_package;

    $plugin_packages:
    ensure => $ensure_package;

    $nrpe_package:
    ensure => $ensure_package;
  }

}
