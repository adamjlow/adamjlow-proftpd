# Class: proftpd::server
#
# manages the installation of the proftpd server.  manages the package, service,
# my.cnf
#
# Parameters:
#   [*package_name*] - name of package
#   [*service_name*] - name of service
#   [*config_hash*]  - hash of config parameters that need to be set.
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class proftpd::server (
  $package_name     = $proftpd::params::server_package_name,
  $package_ensure   = 'present',
  $service_name     = $proftpd::params::service_name,
  $config_hash      = {},
  $enabled          = true
) inherits proftpd::params {

  Class['proftpd::server'] -> Class['proftpd::config']

  $config_class = {}
  $config_class['proftpd::config'] = $config_hash

  create_resources( 'class', $config_class )

  package { 'proftpd-server':
    name   => $package_name,
    ensure => $package_ensure,
  }

  if $enabled {
    $service_ensure = 'running'
  } else {
    $service_ensure = 'stopped'
  }

  service { 'proftpd':
    name     => $service_name,
    ensure   => $service_ensure,
    enable   => $enabled,
    require  => Package['proftpd-server'],
  }

}
