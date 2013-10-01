define tahoe::stats-gatherer (
  $directory,
  $ensure = present
) {

  tahoe::node { $name:
    ensure    => $ensure,
    directory => $directory,
    type      => 'stats-gatherer'
  }
}
