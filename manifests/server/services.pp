#
# This manages the services (daemons), NOT service checks.
#

class icinga::server::services(
  $ensure_icinga_service            = $icinga::server::ensure_service,
  $ensure_ido2db_service            = $icinga::server::ensure_service,
  $ensure_ingraphd_service          = $icinga::server::ensure_service,
  $ensure_ingraph_collector_service = $icinga::server::ensure_service
){

  service {
    $icinga::server::icinga_service:
    ensure => $ensure_icinga_service;

    $icinga::server::ido2db_service:
    ensure => $ensure_ido2db_service;

    #$icinga::server::ingraphd_service:
    #ensure => $ensure_ingraphd_service;

    #$icinga::server::ingraph_collector_service:
    #ensure => $ensure_ingraph_collector_service;
  }
}
