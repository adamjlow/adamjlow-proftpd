#
#
#
define proftpd::mods {
  $modsdir      = $proftpd::params::modsdir
  $mod_name     = "mod_$name"
  $mod_packages = $proftpd::params::mod_packages
  $mod_package  = $mod_packages[$name]

  $config_modules = $proftpd::config::modules
  $params_modules = $proftpd::params::modules

  $config_value = $proftpd::config::modules[$name]
  $params_value = $proftpd::params::modules[$name]

  if (has_key($config_modules, $name) and $config_value == 'false') {
    $enable_module = false
  } elsif (has_key($params_modules, $name) and $params_value != 'false') {
    $enable_module = true
  } elsif $params_value == 'false' {
    $enable_module = false
  } elsif $config_value {
    $enable_module = true
  } else {
    notice("Unknown module ${name}")
  }

  case $name {
    'sql','sql_passwd': {
      if $proftpd::config::sql_engine == 'on' {
        $ensure = 'present'
      } else {
        $ensure = 'absent'
      }
    }

    'mysql','pgsql','sqlite','odbc': {
      $sql_enable = ($proftpd::config::sql_engine == 'on' and
        $proftpd::config::sql_backend == $name)
      if $sql_enable or $enable_module {
        $ensure = 'present'
        if $name == 'mysql' {
          file {"$proftpd::config::basedir/proftpd.sql":
            content => template('proftpd/proftpd.sql.erb'),
          }
        }
      } else {
        $ensure = 'absent'
      }
    }

    'tls': {
      if ($proftpd::config::tls_engine == 'on' or $enable_module) {
        $ensure = 'present'
      } else {
        $ensure = 'absent'
      }
    }

    'tls_memcache': {
      #Crutch. There is no module mod_tls_memcache.c in
      #official repo Ubuntu 12.04. Please check on our dist.

      if (($::lsbdistrelease != '12.04' and $::lsbdistrelease != '14.04') or $enable_module ) {
        $ensure = 'present'
      } else {
        $ensure = 'absent'
      }
    }

    default: {
        if $proftpd::config::modules[$name] != 'false' {
          $ensure = 'present'
        } else {
          $ensure = 'absent'
        }
    }
  }

  if $mod_package {
    package { $mod_package:
      ensure  => $ensure,
      require => Package['proftpd-server'],
    }
  }

  case $ensure {
    'present' : {
      notice("present module ${mod_name}")
      exec { "/bin/ln -s $modsdir-available/$mod_name.load $modsdir-enabled/$mod_name.load":
        unless  => "/bin/readlink -e $modsdir-enabled/$mod_name.load",
        onlyif  => "/bin/readlink -e $modsdir-available/$mod_name.load",
        notify  => Exec['proftpd-reload'],
        require => Package['proftpd-server'],
      }
      exec { "/bin/ln -s $modsdir-available/$mod_name.conf $modsdir-enabled/$mod_name.conf":
        unless  => "/bin/readlink -e $modsdir-enabled/$mod_name.conf",
        onlyif  => "/bin/readlink -e $modsdir-available/$mod_name.conf",
        notify  => Exec['proftpd-reload'],
        require => Package['proftpd-server'],
      }
    }
    'absent': {
      notice("absent module ${mod_name}")
      exec { "/bin/rm $modsdir-enabled/$mod_name.load":
        onlyif  => "/bin/readlink -e $modsdir-enabled/$mod_name.load",
        notify  => Exec['proftpd-reload'],
        require => Package['proftpd-server'],
      }
      exec { "/bin/rm $modsdir-enabled/$mod_name.conf":
        onlyif  => "/bin/readlink -e $modsdir-enabled/$mod_name.conf",
        notify  => Exec['proftpd-reload'],
        require => Package['proftpd-server'],
      }
    }
    default: {
      notice "Unknown ensure: $ensure. Do nothing."
    }
  }
}
