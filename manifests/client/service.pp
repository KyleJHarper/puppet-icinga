#
# Simple class to create the exported nagios service resource.  This is created as a define because it will be called
# many times (hopefully) for a single server.  The class icinga::client::checks will call this define many times and
# build the basic checks.  You can, of course, call this from other places in a manifest (such as another module).
#
# Note:  I pull ensure_nagios_service from icinga::client so I can include it in the input validation I do within
#        that class.  This means you can override this value in hiera at either level, which is fine. All other
#        variables are specific to this nagios Type so it makes sense to put them here, not in the params pattern.
#
# Attributes:  All options and their default values are taken from the icinga documentation located here:
#              http://docs.icinga.org/latest/en/objectdefinitions.html#service
#              (Validation of these attributes is based on the documentation as well.)


define icinga::client::service (
  $check_command,
  $ensure                       = $icinga::client::ensure_nagios_service,
  $action_url                   = undef,
  $active_checks_enabled        = undef,
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
  $host_name                    = $::hostname,
  $hostgroup_name               = undef,
  $icon_image                   = undef,
  $icon_image_alt               = undef,
  $initial_state                = undef,
  $is_volatile                  = undef,
  $low_flap_threshold           = undef,
  $max_check_attempts           = undef,
  $notes                        = undef,
  $notes_url                    = undef,
  $notification_interval        = undef,
  $notification_options         = undef,
  $notification_period          = undef,
  $notifications_enabled        = undef,
  $obsess_over_service          = undef,
  $passive_checks_enabled       = undef,
  $process_perf_data            = undef,
  $retain_nonstatus_information = undef,
  $retain_status_information    = undef,
  $retry_interval               = undef,
  $service_description          = $name,
  $servicegroups                = $title,
  $stalking_options             = undef,
  $tags                         = [],
  $target                       = "${icinga::client::objects_directory}/${::hostname}_services.cfg",
  $use                          = 'generic-service',
) {
  # Call a template to perform validation in accordance with icinga docs (see link above).
  $failsauce_nagios_service = template('icinga/failsauce_nagios_service.erb')
  $failsauce_servicegroups  = template('icinga/failsauce_servicegroups.erb')

  # Export the virtual host
  @@nagios_service {
    "${::hostname}_${title}":
    ensure                       => $icinga::client::service::ensure,
    action_url                   => $icinga::client::service::action_url,
    active_checks_enabled        => $icinga::client::service::active_checks_enabled,
    check_command                => $icinga::client::service::check_command,
    check_freshness              => $icinga::client::service::check_freshness,
    check_interval               => $icinga::client::service::check_interval,
    check_period                 => $icinga::client::service::check_period,
    contact_groups               => $icinga::client::service::contact_groups,
    contacts                     => $icinga::client::service::contacts,
    display_name                 => $icinga::client::service::display_name,
    event_handler                => $icinga::client::service::event_handler,
    event_handler_enabled        => $icinga::client::service::event_handler_enabled,
    failure_prediction_enabled   => $icinga::client::service::failure_prediction_enabled,
    first_notification_delay     => $icinga::client::service::first_notification_delay,
    flap_detection_enabled       => $icinga::client::service::flap_detection_enabled,
    flap_detection_options       => $icinga::client::service::flap_detection_options,
    freshness_threshold          => $icinga::client::service::freshness_threshold,
    high_flap_threshold          => $icinga::client::service::high_flap_threshold,
    host_name                    => $icinga::client::service::host_name,
    hostgroup_name               => $icinga::client::service::hostgroup_name,
    icon_image                   => $icinga::client::service::icon_image,
    icon_image_alt               => $icinga::client::service::icon_image_alt,
    initial_state                => $icinga::client::service::initial_state,
    is_volatile                  => $icinga::client::service::is_volatile,
    low_flap_threshold           => $icinga::client::service::low_flap_threshold,
    max_check_attempts           => $icinga::client::service::max_check_attempts,
    notes                        => $icinga::client::service::notes,
    notes_url                    => $icinga::client::service::notes_url,
    notification_interval        => $icinga::client::service::notification_interval,
    notification_options         => $icinga::client::service::notification_options,
    notification_period          => $icinga::client::service::notification_period,
    notifications_enabled        => $icinga::client::service::notifications_enabled,
    obsess_over_service          => $icinga::client::service::obsess_over_service,
    passive_checks_enabled       => $icinga::client::service::passive_checks_enabled,
    process_perf_data            => $icinga::client::service::process_perf_data,
    retain_nonstatus_information => $icinga::client::service::retain_nonstatus_information,
    retain_status_information    => $icinga::client::service::retain_status_information,
    retry_interval               => $icinga::client::service::retry_interval,
    service_description          => $icinga::client::service::service_description,
    servicegroups                => $icinga::client::service::servicegroups,
    stalking_options             => $icinga::client::service::stalking_options,
    tag                          => $icinga::client::service::tags,
    target                       => $icinga::client::service::target,
    use                          => $icinga::client::service::use,
  }

}

