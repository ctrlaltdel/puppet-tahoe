define tahoe::helper (
  $directory,
  $introducer_furl,
  $ensure = present,
  $webport = false,
  $stats_gatherer_furl = false
) {
  tahoe::client {$name:
    ensure                => $ensure,
    directory             => $directory,
    introducer_furl       => $introducer_furl,
    webport               => $webport,
    stats_gatherer_furl   => $stats_gatherer_furl,
    helper                => true,
  }
}
