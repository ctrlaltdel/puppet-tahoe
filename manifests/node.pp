define tahoe::node (
  $directory,
  $type,
  $introducer_furl,
  $webport,
  $stats_gatherer_furl,
  $helper_furl,
  $storage,
  $helper,
  $ensure = present
  ) {

  case $type {
    client,introducer,stats-gatherer: {}
    default: { fail "unknown node type: ${type}" }
  }

  $tahoe_cfg = "${directory}/tahoe.cfg"
  $user = "tahoe-${name}"

  user { $user:
    ensure     => $ensure,
    home       => $directory,
  }

  case $ensure {
    present: {
      file { $directory:
        ensure => directory,
        owner  => $user,
        mode   => '0700',
      }
    }
    absent: {
        file { $directory:
          ensure => absent,
          force  => true,
        }
    }
    default: { fail 'unknown ensure value' }
  }

  file { "/etc/init.d/tahoe-${name}":
    ensure  => $ensure,
    content => template('tahoe/tahoe.init.erb'),
    mode    => '0755',
    require => $ensure ? {
      present => Exec["create ${type} ${name}"],
      absent  => [],
    },
  }

  $nickname = "${name}@${::fqdn}"

  #
  # Configuration
  #
  file { "${directory}/tahoe.cfg":
    ensure  => $ensure,
    content => template('tahoe/tahoe.cfg.erb'),
    notify  => Service["tahoe-${name}"],
    require => Exec["create ${type} ${name}"],
  }

  case $ensure {
    present: {

      exec { "create ${type} ${name}":
        command   => "tahoe create-${type} --basedir=${directory}",
        user      => $user,
        logoutput => on_failure,
        creates   => "${directory}/tahoe-${type}.tac",
        require   => [ File[$directory], Package['tahoe'] ],
        before    => Service["tahoe-${name}"],
      }

      #
      # Service
      #
      exec {"update-rc.d tahoe-${name} defaults":
        creates => "/etc/rc2.d/S20tahoe-${name}",
        require => [ File["/etc/init.d/tahoe-${name}"], Package['tahoe'] ],
      }

      service {"tahoe-${name}":
        ensure  => running,
        require => [ File["/etc/init.d/tahoe-${name}"], Package['tahoe'] ],
      }

    }

    absent: {
      exec {"update-rc.d -f tahoe-${name} remove":
        onlyif => "test -f /etc/rc2.d/S20tahoe-${name}",
      }
    }
    default: { fail 'unknown ensure value' }
  }
}
