class tahoe {
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

define tahoe::server (
  $ensure = present,
  $directory,
  $introducer,
  $webport="tcp:8123:interface=127.0.0.1") {

  user {$name:
    ensure     => $ensure,
    home       => $directory,
  }

  file {$directory:
    ensure => present,
    owner  => $name,
    mode   => 700,
  }

  case $ensure {
    present: {
      exec {"create client ${name}":
        command   => "tahoe create-client --basedir=${directory} --webport='${webport}'",
        user      => $name,
        logoutput => on_failure,
        creates   => "${directory}/tahoe-client.tac",
        require   => File[$directory],
      }

      exec {"update-rc.d tahoe-${name} defaults":
        creates => "/etc/rc2.d/S20tahoe-${name}",
        require => File["/etc/init.d/tahoe-${name}"],
      }

      file {"${directory}/introducer.furl":
        ensure  => $ensure,
        owner   => $name,
        content => "${introducer}\n",
        require => Exec["create client ${name}"],
      }

      file {"${directory}/webport":
        ensure  => $ensure,
        owner   => $name,
        content => "${webport}\n",
        require => Exec["create client ${name}"],
      }

    
      file {"${directory}/nickname":
        ensure  => $ensure,
        content => "${name}@${fqdn}\n",
        require => Exec["create client ${name}"],
      }

      service {"tahoe-${name}":
        ensure  => running,
        require => File["/etc/init.d/tahoe-${name}"],
      }
    }

    absent: {
      exec {"update-rc.d -f tahoe-${name} remove":
        onlyif => "test -f /etc/rc2.d/S20tahoe-${name}",
      }
    }
  }

  file {"/etc/init.d/tahoe-${name}":
    ensure  => $ensure,
    content => template("tahoe/tahoe.init.erb"),
    mode    => 755,
  }
}
