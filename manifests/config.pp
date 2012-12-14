# Class: proftpd::config
#
# Parameters:
#
#   [*port*]              - port to bind service.
#   [*service_name*]      - proftpd service name.
#   [*config_file*]       - proftpd.conf configuration file path.
#   [*socket*]            - proftpd socket.
#
# Actions:
#
# Requires:
#
#   class proftpd::server
#
# Usage:
#
#   class { 'proftpd::config':
#     server_name  => $::server_name,
#   }
#
class proftpd::config(
  $server_name    = $proftpd::params::server_name,
  $tls_engine     = $proftpd::params::tls_engine,
  $sql_engine     = $proftpd::params::sql_engine,
  $sql_host       = $proftpd::params::sql_host,
  $sql_dbname     = $proftpd::params::sql_dbname,
  $sql_username   = $proftpd::params::sql_username,
  $sql_password   = $proftpd::params::sql_password,
) inherits proftpd::params {

  File {
    owner  => 'root',
    group  => 'root',
    mode   => '0400',
    notify => Exec['proftpd-reload'],
  }

  file { $config_file:
    content => template('proftpd/proftpd.conf.erb'),
    mode    => '0644',
  }

  file { "$basedir/mods-available": ensure => 'directory' }
  file { "$basedir/mods-enabled": ensure => 'directory' }
  file { "$basedir/mods-available/mod_tls.conf":
    content => template('proftpd/mod_tls.conf.erb'),
    mode    => '0644',
  }
  file { "$basedir/mods-available/mod_ldap.conf":
    content => template('proftpd/mod_ldap.conf.erb'),
    mode    => '0644',
  }
  file { "$basedir/mods-available/mod_sql.conf":
    content => template('proftpd/mod_sql.conf.erb'),
    mode    => '0644',
  }

  # This kind of sucks, that I have to specify a difference resource for
  # reload.  the reason is that I need the service to be started before mods
  # to the config file which can cause a refresh
  exec { 'proftpd-reload':
    command     => "service ${service_name} reload",
    logoutput   => on_failure,
    refreshonly => true,
    path        => '/sbin/:/usr/sbin/:/usr/bin/:/bin/',
  }
  exec { 'proftpd-restart':
    command     => "service ${service_name} restart",
    logoutput   => on_failure,
    refreshonly => true,
    path        => '/sbin/:/usr/sbin/:/usr/bin/:/bin/',
  }

}
