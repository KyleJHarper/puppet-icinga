#
# This is a wrapper class to allow me to avoid using an Anchor inside of client.pp.
# This avoids an ugly anchor pattern and a dependency/ordering annoyance.
#
# If it wasn't clear, the purpose of this class is to load checks defined in hiera
# rather than discovered inside of modules.  This allows you to ensure some basic
# checks are applied to all nodes evenly, following the same infrastructure (hiera)
# you're already using.
#
# Of course, other modules can call the icinga::client::service definition to include
# module-specific checks which will all get exported irrespective of this class and vice
# versa.
#

class icinga::client::checks () {
  create_resources(icinga::client::service, $icinga::client::defined_checks)
}

