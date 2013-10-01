class tahoe::ubuntu inherits tahoe::base {
  case $lsbdistcodename {
    maverick:  { $dist = "maverick" }
    lucid: { $dist = "lucid" }
    karmic: { $dist = "karmic" }
    default: { fail "Unsupported distribution $lsbdistcodename" }
  }
  
  package {"tahoe":
    name   => "tahoe-lafs",
    ensure => "latest",
  }
}
