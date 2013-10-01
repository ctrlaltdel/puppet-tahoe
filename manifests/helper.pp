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
