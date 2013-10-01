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
