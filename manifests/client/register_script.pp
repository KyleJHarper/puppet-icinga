#
# This definition allows another area of a manifest (e.g. another module) to register
# a check (script/program) to be included in the custom_checks_directory lcoation.  This
# means any module can create a check script for the services it provides and that
# script can be sent to the icinga clients that include that class.  This prevents us
# from having to update the icinga module every time a new *thing* comes along that we
# want a check script for.
#
# For ease (aka laziness) you can specify a hahs of NRPE commands along with a script.
# These will, obviously, only apply to the nodes including that module which is a good
# thing.  The calling_module could also simply call the icinga::client::nrpe_command
# definition directly, but we'll be nice here.
#
# Content
# You MUST provide the contents of the file.  You can do this by using the template()
# or file() functions in the calling_module.  I recommend template(), as file() tends
# to be flaky.
#

define icinga::client::register_script (
  $content,
  $associated_nrpe_commands = {},
) {

  file {
    "${icinga::client::nagios_custom_checks_directory}/${title}":
    ensure  => $icinga::client::ensure_file,
    owner   => $icinga::client::effective_owner,
    group   => $icinga::client::effective_group,
    mode    => '0755',
    content => $content,
    require => File[$icinga::client::nagios_custom_checks_directory],
  }

  validate_hash($associated_nrpe_commands)
  create_resources('icinga::client::nrpe_command', $associated_nrpe_commands)

}
