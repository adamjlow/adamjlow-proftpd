# Class: proftpd::params
#
#   The proftpd configuration settings.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class proftpd::params {

  $use_ipv6		= 'on'
  $ident_lookups	= 'off'
  $server_name		= ''
  $server_type		= 'standalone'
  $defer_welcome	= 'off'
  $multiline_rfc2228	= 'on'
  $default_server	= 'on'
  $show_symlinks	= 'on'
  $timeout_notransfer	= 600
  $timeout_stalled	= 600
  $timeout_idle		= 1200
  $display_login	= 'welcome.msg'
  $display_chdir	= '.message true'
  $list_options		= '-l'
  $deny_filter		= '\*.*/'
  $port			= 21
  $max_instances	= 30
  $user			= 'proftpd'
  $group		= 'nogroup'
  $umask		= '022 022'
  $allow_overwrite	= 'on'

  $sql_engine           = 'off'
  $sql_backend          = 'mysql'
  $sql_host		= 'dbhost'
  $sql_dbname           = 'dbname'
  $sql_username         = 'dbusername'
  $sql_password         = 'dbpassword'
  
  $tls_engine           = 'off'
  $tls_log              = '/var/log/proftpd/tls.log'
  $tls_protocol         = 'SSLv23'
  $tls_rsacertfile      = '/etc/ssl/certs/proftpd.crt'
  $tls_rsacertkey       = '/etc/ssl/private/proftpd.key'
  $tls_cacertfile       = '/etc/ssl/certs/CA.pem'
  $tls_options          = ''
  $tls_verifyclient     = 'off'
  $tls_required         = 'off'
  $tls_renegotiate      = 'required off'

  $ldap_engine          = 'off'
  $ldap_usetls          = 'on'
  $ldap_server          = 'ldap://ldap.example.com'
  $ldap_binddn          = '"cn=admin,dc=example,dc=com" "admin_password"'
  $ldap_users           = 'dc=users,dc=example,dc=com (uid=%u) (uidNumber=%u)'
  

  case $::operatingsystem {
    "Ubuntu": {
#     $service_provider = upstart << BREAKS
      $service_provider = undef
    }
    default: {
      $service_provider = undef
    }
  }

  case $::osfamily {

    'Debian': {
      $basedir              = '/etc/proftpd'
      $modsdir              = '/etc/proftpd/mods'
      $service_name         = 'proftpd'
      $server_package_name  = 'proftpd-basic'
      $socket               = '/var/run/proftpd/proftpd.sock'
      $pidfile              = '/run/proftpd.pid'
      $config_file          = '/etc/proftpd/proftpd.conf'
      $transfer_log         = '/var/log/proftpd/xferlog'
      $system_log           = '/var/log/proftpd/proftpd.log'
      $mod_packages         = {
        'autohost' => 'proftpd-mod-autohost',
        'case'     => 'proftpd-mod-case',
        'clamav'   => 'proftpd-mod-clamav',
        'dnsbl'    => 'proftpd-mod-dnsbl',
        'fsync'    => 'proftpd-mod-fsync',
        'geoip'    => 'proftpd-mod-geoip',
        'ldap'     => 'proftpd-mod-ldap',
        'msg'      => 'proftpd-mod-msg',
        'mysql'    => 'proftpd-mod-mysql',
        'odbc'     => 'proftpd-mod-odbc',
        'pgsql'    => 'proftpd-mod-pgsql',
        'sqlite'   => 'proftpd-mod-sqlite',
        'tar'      => 'proftpd-mod-tar',
        'vroot'    => 'proftpd-mod-vroot',

      }
    }

    default: {
      case $::operatingsystem {
        'Amazon': {
          $basedir               = '/usr'
          $datadir               = '/var/lib/mysql'
          $service_name          = 'mysqld'
          $client_package_name   = 'mysql'
          $server_package_name   = 'mysql-server'
          $socket                = '/var/lib/mysql/mysql.sock'
          $config_file           = '/etc/my.cnf'
          $log_error             = '/var/log/mysqld.log'
          $ruby_package_name     = 'ruby-mysql'
          $ruby_package_provider = 'gem'
          $python_package_name   = 'MySQL-python'
          $java_package_name     = 'mysql-connector-java'
          $root_group            = 'root'
          $ssl_ca                = '/etc/mysql/cacert.pem'
          $ssl_cert              = '/etc/mysql/server-cert.pem'
          $ssl_key               = '/etc/mysql/server-key.pem'
        }

        default: {
          fail("Unsupported osfamily: ${::osfamily} operatingsystem: ${::operatingsystem}, module ${module_name}")
        }
      }
    }
  }

}
