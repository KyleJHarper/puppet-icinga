#
# Just creates the user(s) and group(s) for Icinga and associated.  This will also setup
# the user for apache since we're auto-including the class.  It's the only way to get the
# user set up and get it added to the icinga group properly.  The current apache module
# doesn't allow that.
#
# The apache user will be added to the icinga group.  This is slight overkill but shouldn't
# present any major security risks.  It allows things like the rw directory and .dat files
# to be set to 'icinga' for group yet still have 'www-data' read it.
#

class icinga::server::roles (
  $icinga_user         = $icinga::server::effective_owner,
  $icinga_user_uid     = undef,
  $icinga_group        = $icinga::server::effective_group,
  $icinga_group_gid    = undef,
  $icinga_extra_groups = [],
  $apache_user_uid     = undef,
  $apache_group_gid    = undef,
) {

  user {
    $icinga_user:
    ensure  => $icinga::server::ensure_role,
    gid     => $icinga_group,
    groups  => $icinga_extra_groups,
    uid     => $icinga_user_uid,
    require => Group[$icinga_group];

    $apache::user:
    ensure  => $icinga::server::ensure_role,
    gid     => $apache::group,
    groups  => $icinga_group,
    uid     => $apache_user_uid,
    require => Group[$icinga_group, $apache::group];
  }

  group {
    $icinga_group:
    ensure => $icinga::server::ensure_role,
    gid    => $icinga_group_gid;

    $apache::group:
    ensure => $icinga::server::ensure_role,
    gid    => $apache_group_gid;
  }

}
