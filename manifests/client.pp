define tahoe::client (
  $directory,
  $introducer_furl,
  $ensure = present,
  $webport = 'tcp:3456:interface=127.0.0.1',
  $stats_gatherer_furl = false,
  $helper_furl = false,
  $storage = false,
  $helper  = false
) {
  tahoe::node {$name:
    ensure              => $ensure,
    directory           => $directory,
    type                => 'client',
    introducer_furl     => $introducer_furl,
    webport             => $webport,
    stats_gatherer_furl => $stats_gatherer_furl,
    helper_furl         => $helper_furl,
    storage             => $storage,
    helper              => $helper,
  }
}
