#
# This will generate the files in /etc/nagios/nrpe.d.  This should probably do manualy hiera
# lookups with the merge_all or whatever, so that everyone can get base checks made available
# with common.yaml, and then extend with <their_node>.yaml.
#
# This needs (and is) cleaned up by the caller (icinga::nagios::config)
#

define icinga::client::nrpe_command (
  $command_text,
){

  # -- Write the config (cfg) file for the command
  file {
    "${icinga::client::nrpe_config_directory}/${name}.cfg":
    ensure  => $icinga::client::ensure_file,
    owner   => $icinga::client::effective_owner,
    group   => $icinga::client::effective_group,
    mode    => '0644',
    content => template('icinga/etc/nagios/nrpe.d/command.cfg.erb'),
    notify  => Service[$icinga::client::nrpe_service],
    require => [ File[$icinga::client::nrpe_config_directory], Package[$icinga::client::nrpe_package] ];
  }

}

