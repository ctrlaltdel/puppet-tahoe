class tahoe {
  case $::operatingsystem {
    Debian:   { include tahoe::debian }
    ubuntu:   { include tahoe::ubuntu }
    default:  { include tahoe::base }
  }
}
