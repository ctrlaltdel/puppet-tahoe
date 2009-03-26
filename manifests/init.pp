class tahoe {
  case $operatingsystem {
    Debian: { include tahoe::debian }
    default:  { include tahoe::base }
  }
}

class tahoe::base {
}

class tahoe::egg {
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

class tahoe::debian {
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
    ensure => present,
  }
}

define tahoe::introducer ($ensure = present, $directory) {
  tahoe::node {$name:
    ensure    => $ensure,
    directory => $directory,
    type      => "introducer",
  }
}

define tahoe::node ($ensure = present, $directory, $type) {
  case $type {
    client,introducer: {}
    default: { fail "unknown node type: ${type}" }
  }

  user {$name:
    ensure     => $ensure,
    home       => $directory,
  }

  file {$directory:
    ensure => $ensure ? {
      present => "directory",
      absent  => "absent"
    },
    owner  => $name,
    mode   => 700,
  }

  file {"/etc/init.d/tahoe-${name}":
    ensure  => $ensure,
    content => template("tahoe/tahoe.init.erb"),
    mode    => 755,
  }

  case $ensure {
    present: {
      exec {"create ${type} ${name}":
        command   => "tahoe create-${type} --basedir=${directory}",
        user      => $name,
        logoutput => on_failure,
        creates   => "${directory}/tahoe-${type}.tac",
        require   => File[$directory],
      }

      exec {"update-rc.d tahoe-${name} defaults":
        creates => "/etc/rc2.d/S20tahoe-${name}",
        require => File["/etc/init.d/tahoe-${name}"],
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
}
