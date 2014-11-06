#
# Simple class to create the exported nagios host resource.  Some people make this a define, but there's no reason for
# a single client to ever call this multiple times.  So it's simpler (and safer) to make it a class.
#
# Hostgroups come from $default_hostgroups (params) and $defined_hostgroups (hiera).
# You may define special logic here or inside the template file to generate the hostgroups string.
# Obvivously, any custom variables you make here need to be referenced in the template for them to get applied.
#
# Note:  I pull ensure_nagios_host from icinga::client so I can include it in the input validation I do within
#        that class.  This means you can override this value in hiera at either level, which is fine. All other
#        variables are specific to this nagios Type so it makes sense to put them here, not in the params pattern.
#
# Attributes:  All options and their default values are taken from the icinga documentation located here:
#              http://docs.icinga.org/latest/en/objectdefinitions.html#host
#              (Validation of these attributes is based on the documentation as well.)
#

class icinga::client::host (
  $ensure_nagios_host           = $icinga::client::ensure_nagios_host,
  $action_url                   = undef,
  $active_checks_enabled        = undef,
  $address                      = $::ipaddress,
  $alias                        = $::hostname,
  $check_command                = undef,
  $check_freshness              = undef,
  $check_interval               = undef,
  $check_period                 = undef,
  $contact_groups               = undef,
  $contacts                     = undef,
  $display_name                 = undef,
  $event_handler                = undef,
  $event_handler_enabled        = undef,
  $failure_prediction_enabled   = undef,
  $first_notification_delay     = undef,
  $flap_detection_enabled       = undef,
  $flap_detection_options       = undef,
  $freshness_threshold          = undef,
  $high_flap_threshold          = undef,
  $host_name                    = undef,
  $hostgroups                   = template('icinga/hostgroups.erb'),
  $icon_image                   = undef,
  $icon_image_alt               = undef,
  $initial_state                = undef,
  $low_flap_threshold           = undef,
  $max_check_attempts           = undef,
  $notes                        = undef,
  $notes_url                    = undef,
  $notification_interval        = undef,
  $notification_options         = undef,
  $notification_period          = undef,
  $notifications_enabled        = undef,
  $obsess_over_host             = undef,
  $parents                      = undef,
  $passive_checks_enabled       = undef,
  $process_perf_data            = undef,
  $retain_nonstatus_information = undef,
  $retain_status_information    = undef,
  $retry_interval               = undef,
  $stalking_options             = undef,
  $statusmap_image              = undef,
  $use                          = 'generic-host',
  $tags                         = [],
  $target                       = "${icinga::client::objects_directory}/${::hostname}_host.cfg",
){
  # Call a template to perform validation in accordance with icinga docs (see link above).
  $failsauce_nagios_host = template('icinga/failsauce_nagios_host.erb')
  $failsauce_hostgroups  = template('icinga/failsauce_hostgroups.erb')

  # Export the virtual host
  @@nagios_host {
    $::hostname:
    ensure                       => $icinga::client::host::ensure_nagios_host,
    action_url                   => $icinga::client::host::action_url,
    active_checks_enabled        => $icinga::client::host::active_checks_enabled,
    address                      => $icinga::client::host::address,
    alias                        => $icinga::client::host::alias,
    check_command                => $icinga::client::host::check_command,
    check_freshness              => $icinga::client::host::check_freshness,
    check_interval               => $icinga::client::host::check_interval,
    check_period                 => $icinga::client::host::check_period,
    contact_groups               => $icinga::client::host::contact_groups,
    contacts                     => $icinga::client::host::contacts,
    display_name                 => $icinga::client::host::display_name,
    event_handler                => $icinga::client::host::event_handler,
    event_handler_enabled        => $icinga::client::host::event_handler_enabled,
    failure_prediction_enabled   => $icinga::client::host::failure_prediction_enabled,
    first_notification_delay     => $icinga::client::host::first_notification_delay,
    flap_detection_enabled       => $icinga::client::host::flap_detection_enabled,
    flap_detection_options       => $icinga::client::host::flap_detection_options,
    freshness_threshold          => $icinga::client::host::freshness_threshold,
    high_flap_threshold          => $icinga::client::host::high_flap_threshold,
    host_name                    => $icinga::client::host::host_name,
    hostgroups                   => $icinga::client::host::hostgroups,
    icon_image                   => $icinga::client::host::icon_image,
    icon_image_alt               => $icinga::client::host::icon_image_alt,
    initial_state                => $icinga::client::host::initial_state,
    low_flap_threshold           => $icinga::client::host::low_flap_threshold,
    max_check_attempts           => $icinga::client::host::max_check_attempts,
    notes                        => $icinga::client::host::notes,
    notes_url                    => $icinga::client::host::notes_url,
    notification_interval        => $icinga::client::host::notification_interval,
    notification_options         => $icinga::client::host::notification_options,
    notification_period          => $icinga::client::host::notification_period,
    notifications_enabled        => $icinga::client::host::notifications_enabled,
    obsess_over_host             => $icinga::client::host::obsess_over_host,
    parents                      => $icinga::client::host::parents,
    passive_checks_enabled       => $icinga::client::host::passive_checks_enabled,
    process_perf_data            => $icinga::client::host::process_perf_data,
    retain_nonstatus_information => $icinga::client::host::retain_nonstatus_information,
    retain_status_information    => $icinga::client::host::retain_status_information,
    retry_interval               => $icinga::client::host::retry_interval,
    stalking_options             => $icinga::client::host::stalking_options,
    statusmap_image              => $icinga::client::host::statusmap_image,
    use                          => $icinga::client::host::use,
    tag                          => $icinga::client::host::tags,
    target                       => $icinga::client::host::target,
  }
}

