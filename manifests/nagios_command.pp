#
# Replacement for the internal nagios_command type
#

define nagios::nagios_command (
  $commands,
  $target   = '/tmp/rawr.cfg',
  $ensure   = 'file',
  $group    = 'root',
  $mode     = '0644',
  $owner    = 'root',
) {

  if ($ensure !~ /file|present|absent/) { fail("Ensure value must be one of: file, present, or absent.  Not '${ensure}'.") }
  if ($target !~ /[.]cfg$/) { fail("Target file '${target}' must end in .cfg, this is a requirements of all object configuration files.") }

  file {
    $target:
    ensure  => $ensure,
    owner   => $owner,
    group   => $group,
    mode    => $mode,
    content => template('nagios/nagios_commands.cfg.erb');
  }
}
