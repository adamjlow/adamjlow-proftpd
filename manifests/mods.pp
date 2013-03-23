#
#
#
define proftpd::mods ( $ensure = 'present' ) {
  $modsdir      = $proftpd::params::modsdir
  $mod_name     = "mod_$name"
  $mod_packages = $proftpd::params::mod_packages
  $mod_package  = $mod_packages[$name]

  if $mod_package {
    package { $mod_package:
      ensure  => present,
      require => Package['proftpd-server'],
    }
  }


  case $ensure {
    'present' : {
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
    'default': {
      notice 'Unknown ensure: do nothing'
    }
  }
}
