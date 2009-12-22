========================
Tahoe-LAFS Puppet module
========================

This Puppet module ease the deployment of a Tahoe storage grid across multiple
machine thanks to the Puppet system management system.

Currently supported distributions are Debian and Ubuntu but preliminary support
for easy_install is also present.

Usage
-----

First, ensure that system-wide Tahoe dependencies are present on your system::

  include tahoe

Even though a generic Tahoe node can be managed directly by the ``tahoe::node``
type, you'll probably end up using the following special-purposes types:

- ``tahoe::introducer`` - The introducer's purpose is to keep a 
- ``tahoe::storage`` - A storage node
- ``tahoe::helper`` - An upload helper
- ``tahoe::client`` - A simple Tahoe client which *does not* provide any storage to the grid.
- ``tahoe::stats-gatherer`` - A Tahoe node whose goal is to gatherer stats from other nodes in the grid.

To install a Tahoe introducer in directory ``/srv/tahoe-introducer`` which
listen on port 8123::

  tahoe::introducer {"introducer":
    ensure    => present,
    directory => "/srv/tahoe-introducer,
    webport   => "tcp:8123:interface=0.0.0.0",
  }

  tahoe::storage {"storage1":
    ensure          => present,
    directory       => "/mnt/sdb",
    webport         => "tcp:3456:interface=0.0.0.0",
    introducer_furl => "pb://blah@1.1.1.1:12345/introducer",
    stats_furl      => "pb://blah@1.1.1.2:12346/foobar",
  }

  tahoe::helper {"helper":
    ensure          => present,
    directory       => "/srv/tahoe-helper";
    webport         => "tcp:8124:interface=0.0.0.0",
    introducer_furl => "pb://blah@1.1.1.1:12345/introducer",
    stats_furl      => "pb://blah@1.1.1.2:12346/foobar",
  }

  tahoe::client {"client":
    ensure          => present,
    directory       => "/srv/tahoe-client",
    webport         => "tcp:3456:interface=0.0.0.0",
    introducer_furl => "pb://blah@1.1.1.1:12345/introducer",
    stats_furl      => "pb://blah@1.1.1.2:12346/foobar",
    helper_furl     => "pb://blah@1.1.1.3:12347/foobar2",
  }

  tahoe::stats-gatherer {"stats":
    ensure    => present,
    directory => "/srv/tahoe-stats",
  }

Sample usage
------------

The following sample puppet configuration allows the deployment of a complete Tahoe storage grid spanning three different systems (one introducer and two storage nodes)::

  $introducer_furl = "pb://blah@1.2.3.4:55368,127.0.0.1:55368/introducer"
  $stats_furl      = "pb://blah@127.0.0.1:55945,1.2.3.4:55945/blah"
 
  node 'srv1.mydomain.com' {
    include base
    include tahoe
 
    # 
    # Tahoe Introducer
    #
    tahoe::introducer {"introducer":
      ensure    => present,
      directory => "/srv/tahoe-introducer",
      webport   => "tcp:8123:interface=0.0.0.0",
    }
  
    #
    # Tahoe helper
    #
    tahoe::helper {"helper":
      ensure          => present,
      directory       => "/srv/tahoe-helper",
      webport         => "tcp:8124:interface=0.0.0.0",
      introducer_furl => $introducer_furl,
      stats_furl      => $stats_gatherer_furl,
    }
  
    #
    # Grid stats
    #
    tahoe::stats-gatherer {"stats":
      ensure    => present,
      directory => "/srv/tahoe-stats-gatherer",
    }
  }

  # Simple storage node with one disk
  node 'srv2.mydomain.com' {
    include base
    include tahoe
  
    tahoe::storage {"storage1":
      ensure              => present,
      directory           => "/srv/tahoe-s1",
      webport             => "tcp:3456:interface=0.0.0.0",
      introducer_furl     => $introducer_furl,
      stats_furl          => $stats_furl,
    }
  }

  # Storage node with two disks
  node 'srv3.mydomain.com' {
    include base
    include tahoe
  
    tahoe::storage {"storage2":
      ensure              => present,
      directory           => "/mnt/sdb",
      webport             => "tcp:3456:interface=0.0.0.0",
      introducer_furl     => $introducer_furl,
      stats_furl          => $stats_furl,
    }
  
    tahoe::storage {"storage3":
      ensure              => present,
      directory           => "/mnt/sdc",
      webport             => "tcp:3457:interface=0.0.0.0",
      introducer_furl     => $introducer_furl,
      stats_furl          => $stats_furl,
    }
  }


Bugs
----

- Debian packages provided by allmydata.org are not signed and therefore cannot
  be automatically installed by Puppet. You have to install them by calling
  apt-get install.

- A recent version of the Augeas library is required and the appropriate Puppet
  augeas type should be installed on your system.

- It is currently necessary to write the introducer furl by hand to your puppet
  recipe. It is not automatically filled after the introducer node got created.

Credits
-------

Author: François Deppierraz francois@ctrlaltdel.ch

Part of this work was made possible by Nimag Networks Sàrl http://www.nimag.net/.

References
----------

- Puppet: http://reductivelabs.com/trac/puppet/
- Tahoe-LAFS: http://allmydata.org/

