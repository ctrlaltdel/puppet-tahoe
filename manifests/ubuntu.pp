class tahoe::ubuntu inherits tahoe::base {

  case $::lsbdistcodename {
    maverick:  { $dist = 'maverick' }
    lucid: { $dist = 'lucid' }
    karmic: { $dist = 'karmic' }
    trusty: { $dist = 'trusty' }
    default: { fail "Unsupported distribution ${::lsbdistcodename}" }
  }

  package { 'tahoe':
    ensure => 'latest',
    name   => 'tahoe-lafs'
  }
}
