#
# This class will perform a hiera_hash (merged lookup) for $checks.  This is so all checks can be setup
# and modified through hiera, if desired.  Obviously, other classes can make their own icinga::client::service
# calls to add checks.  For example, the 'apache2' module could call the aforementioned definition to force
# all nodes using that module to include the check.  I personally thing hiera is better because it (should)
# mirror your infrastructure's hierary.  However, with the above example you could also make all your modules
# force the checks for all nodes which include them, which might be useful in some environments.
# -- Power To The Admin
#
class icinga::client::checks () {
  create_resources(icinga::client::service, $checks)
}

