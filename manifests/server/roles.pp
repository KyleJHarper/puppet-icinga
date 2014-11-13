#
# Just creates the user(s) and group(s) for Icinga and associated.
#

class icinga::server::roles (
  $icinga_user         = $icinga::server::effective_owner,
  $icinga_user_uid     = undef,
  $icinga_group        = $icinga::server::effective_group,
  $icinga_group_gid    = undef,
  $icinga_extra_groups = [],
) {

  user {
    $icinga_user:
    ensure  => $icinga::server::ensure_role,
    gid     => $icinga_group,
    groups  => $icinga_extra_groups,
    uid     => $icinga_user_uid,
    require => Group[$icinga_group];
  }

  group {
    $icinga_group:
    ensure => $icinga::server::ensure_role,
    gid    => $icinga_group_gid;
  }
}
