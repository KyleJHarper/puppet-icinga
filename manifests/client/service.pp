#
# Defines a service to be exported for a host, which will be collected by the icinga master(s) later.
#

define icinga::client::service (
  $command = false,
  $group = false,
  $ensure = 'present',
) {

  @@nagios_service { "${::hostname}_${name}":
    ensure              => $icinga::client::ensure_nagios_service,
    check_command       => $command,
    host_name           => $::hostname,
    servicegroups       => $group,
    service_description => $name,
    use                 => $icinga::client::service_template,
    target              => "${icinga::client::objects_directory}/${::hostname}_services.cfg";
  }

}

