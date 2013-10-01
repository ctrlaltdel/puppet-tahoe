class tahoe::debian inherits tahoe::base {

  package { 'tahoe':
    ensure => 'latest',
    name   => 'tahoe-lafs',
  }
}
