#
# Simple class to create the exported nagios host resource.  Some people make this a define, but there's no reason for
# a single client to ever call this multiple times.  So it's simpler (and safer) to make it a class.
#

class icinga::client::host {
  # Hostgroups come from $default_hostgroups (params) and $defined_hostgroups (hiera).
  # You may define special logic here or inside the template file to generate the hostgroups string.
  # Obvivously, any custom variables you make here need to be referenced in the template for them to get applied.

  # Export the virtual host
  @@nagios_host {
    $name:
    ensure     => $icinga::client::ensure_host,
    alias      => $::hostname,
    address    => $::ipaddress,
    hostgroups => template('icinga/etc/icinga/objects/hostgroups.cfg.erb'),
    use        => $icinga::client::host_template,
    target     => "${icinga::client::objects_directory}/${::hostname}_host.cfg",
  }
}

