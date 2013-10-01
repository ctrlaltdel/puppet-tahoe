class tahoe::debian inherits tahoe::base {

  package { 'tahoe-lafs':
    ensure => 'latest',
  }
}
