#
# Defines a service to be exported for a host, which will be collected by the icinga master(s) later.
#

define icinga::client::service (
  $command = false,
  $group = false,
  $ensure = 'present',
) {

  # Don't register the service if we're not interested in the node involved.  See common.yaml->icinga::exempt_servers.
  if !member(hiera(icinga::exempt_servers), $::hostname) {
    @@nagios_service { "${::hostname}_${name}":
      ensure              => $icinga::client::ensure_service,
      check_command       => $t_command,
      host_name           => $::hostname,
      servicegroups       => $t_group,
      service_description => $name,
      use                 => 'generic-service',
      target              => "/etc/icinga/objects/${::hostname}_services.cfg";
    }
  }

}

