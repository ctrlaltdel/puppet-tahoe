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
