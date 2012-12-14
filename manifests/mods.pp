#
#
#

define proftpd::mods ( $ensure = 'present' ) {
   $proftpd_mods = '/etc/proftpd/mods'

      case $ensure {
         'present' : {
            exec { "/bin/ln -s $proftpd_mods-available/$name.load $proftpd_mods-enabled/$name.load":
		unless => "/bin/readlink -e $proftpd_mods-enabled/$name.load",
		notify => Exec["proftpd-restart"],
                require => Package['proftpd-server'],
            }
            exec { "/bin/ln -s $proftpd_mods-available/$name.conf $proftpd_mods-enabled/$name.conf":
                unless => "/bin/readlink -e $proftpd_mods-enabled/$name.conf",
                onlyif => "/bin/readlink -e $proftpd_mods-available/$name.conf",
                notify => Exec["proftpd-restart"],
                require => Package['proftpd-server'],
            }
         }
         'absent': {
            exec { "/bin/rm $proftpd_mods-enabled/$name.load":
		onlyif => "/bin/readlink -e $proftpd_mods-enabled/$name.load",
		notify => Exec["reload-apache"],
                require => Package['proftpd-server'],
            }
            exec { "/bin/rm $proftpd_mods-enabled/$name.conf":
                onlyif => "/bin/readlink -e $proftpd_mods-enabled/$name.conf",
                notify => Exec["reload-apache"],
                require => Package['proftpd-server'],
            }
         }
         default: { err ( "Unknown ensure value: '$ensure'" ) }
      }
   }

