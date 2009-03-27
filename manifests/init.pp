class tahoe {
  case $operatingsystem {
    Debian: { include tahoe::debian }
    default:  { include tahoe::base }
  }
}

class tahoe::base {
  file {"/usr/share/augeas/lenses/tahoe.aug":
    ensure => present,
    source => "puppet:///tahoe/tahoe.aug",
  }
}

class tahoe::egg inherits tahoe::base {
  package{
    "python2.4":
      ensure => present;
    "python2.4-dev":
      ensure => present;
    "python-setuptools":
      ensure => present;
    "build-essential":
      ensure => present;
    "libcrypto++-dev":
      ensure => present;
    "python-twisted":
      ensure => present;
    "python-pyopenssl":
      ensure => present;
  }

  exec {"easy_install allmydata-tahoe":
    unless => "python -c 'import allmydata'",
  }
}

class tahoe::debian inherits tahoe::base {
  # BUG: Those packages are not authenticated

  case $lsbdistcodename {
    etch:  { $dist = "etch" }
    lenny: { $dist = "etch" }
  }

  apt::sources_list {"allmydata":
    ensure => present,
    content => "deb http://allmydata.org/debian/ ${dist} main tahoe
deb-src http://allmydata.org/debian/ ${dist} main tahoe",
  }

  package {"allmydata-tahoe":
    ensure => "1.3.0",
  }
}

define tahoe::introducer (
  $ensure = present,
  $directory,
  $webport = false
) {
  tahoe::node {$name:
    ensure    => $ensure,
    directory => $directory,
    type      => "introducer",
  }

  if $webport {
    augeas {"tahoe/${name}/webport":
      context   => "/files${directory}/tahoe.cfg",
      load_path => $directory,
      changes   => "set /node/web.port ${webport}",
    }
  }
}

define tahoe::storage (
  $ensure = present,
  $directory,
  $introducer_furl,
  $webport = false,
  $stats_gatherer_furl = false,
  $helper_furl = false
) {
  tahoe::client {$name:
    ensure          => $ensure,
    directory       => $directory,
    introducer_furl => $introducer_furl,
    webport         => $webport,
    stats_gatherer  => $stats_gatherer,
    helper_furl     => $helper_furl,
    storage         => "true",
  }
}

define tahoe::helper (
  $ensure = present,
  $directory,
  $introducer_furl,
  $webport = false,
  $stats_gatherer_furl = false
) {
  tahoe::client {$name:
    ensure                => $ensure,
    directory             => $directory,
    introducer_furl       => $introducer_furl,
    webport               => $webport,
    stats_gatherer_furl   => $stats_gatherer_furl,
    helper                => "true",
  }
}


define tahoe::client (
  $ensure = present,
  $directory,
  $introducer_furl,
  $webport = false,
  $stats_gatherer_furl = false,
  $helper_furl = false,
  $storage = "false",
  $helper  = "false"
) {
  tahoe::node {$name:
    ensure    => $ensure,
    directory => $directory,
    type      => "client",
  }

  case $ensure {
    present: {
      augeas {$name:
        context   => "/files${directory}/tahoe.cfg/",
        load_path => $directory,
        force     => true,
        changes   => [
          "set /client/introducer.furl \"${introducer_furl}\"",
          "set /storage/enabled ${storage}",
          "set /helper/enabled ${helper}",
          "set /node/web.port \"${webport}\"",
    
          $webport ? {
            false   => "",
            default => "set /node/web.port \"${webport}\"",
          },
    
          $stats_gatherer_furl ? {
            false   => "",
            default => "set /client/stats_gatherer.furl \"${stats_gatherer_furl}\"",
          },
    
          $helper_furl ? {
            false   => "",
            default => "set /client/helper.furl \"${helper_furl}\"",
          },
        ],
        notify => Service["tahoe-${name}"],
      }
    }
  }
}

define tahoe::stats-gatherer (
  $ensure = present,
  $directory
) {
  tahoe::node {$name:
    ensure    => $ensure,
    directory => $directory,
    type      => "stats-gatherer",
  }
}


define tahoe::node ($ensure = present, $directory, $type) {
  case $type {
    client,introducer,stats-gatherer: {}
    default: { fail "unknown node type: ${type}" }
  }

  $tahoe_cfg = "${directory}/tahoe.cfg"
  $user = "tahoe-${name}"

  user {$user:
    ensure     => $ensure,
    home       => $directory,
  }

  case $ensure {
    present: {
      file {$directory:
        ensure => "directory",
        owner  => $user,
        mode   => 700,
      }
    }
    absent: {
        file {$directory:
          ensure => absent,
          force  => true,
        }
    }
  }

  file {"/etc/init.d/tahoe-${name}":
    ensure  => $ensure,
    content => template("tahoe/tahoe.init.erb"),
    mode    => 755,
    require => $ensure ? {
      present => Exec["create ${type} ${name}"],
      absent  => [],
    },
  }

  case $ensure {
    present: {

      exec {"create ${type} ${name}":
        command   => "tahoe create-${type} --basedir=${directory}",
        user      => $user,
        logoutput => on_failure,
        creates   => "${directory}/tahoe-${type}.tac",
        require   => File[$directory],
      }

      #
      # Service
      #
      exec {"update-rc.d tahoe-${name} defaults":
        creates => "/etc/rc2.d/S20tahoe-${name}",
        require => File["/etc/init.d/tahoe-${name}"],
      }

      service {"tahoe-${name}":
        ensure  => running,
        require => File["/etc/init.d/tahoe-${name}"],
      }

      #
      # Augeas
      #
      $augeas_name = gsub($name, "-", "")

      file {"${directory}/${augeas_name}.aug":
        ensure => present,
        content => template("tahoe/tahoe.aug.erb"),
        require => Exec["create ${type} ${name}"],
      }

      augeas {"tahoe/${name}/nickname":
        context   => "/files${directory}/tahoe.cfg",
        load_path => $directory,
        changes   => "set node/nickname ${name}@${fqdn}",
        force     => true,
        require   => Exec["create ${type} ${name}"],
      }
    }

    absent: {
      exec {"update-rc.d -f tahoe-${name} remove":
        onlyif => "test -f /etc/rc2.d/S20tahoe-${name}",
      }
    }
  }
}
