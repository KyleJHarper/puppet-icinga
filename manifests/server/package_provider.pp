#
# Simply configures a common 3rd party package provider.  This is required for systems
# like ubuntu which version-lock software, as Icinga is commonly update.  It could be
# done through params but I want declarations outside of it.
#

class icinga::server::package_provider() {

  case $::operatingsystem {
    'Ubuntu', 'Debian': {
      # Install PPAs from Alex Formorer, developer on Icinga.  Requires either:
      #   1. A file resource with a name of 'sources.list.d' manually declared or...
      #   2. Inclusion of the apt class, or another that makes that file resource, because apt::ppa needs it.
      apt::ppa {'ppa:formorer/icinga': }
      apt::ppa {'ppa:formorer/icinga-web': }
    }
  }
}
