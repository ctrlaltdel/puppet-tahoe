class tahoe::egg inherits tahoe::base {

  package {
    'python':
      ensure => present;
    'python-dev':
      ensure => present;
    'python-setuptools':
      ensure => present;
    'build-essential':
      ensure => present;
    'libcrypto++-dev':
      ensure => present;
    'python-twisted':
      ensure => present;
    'python-pyopenssl':
      ensure => present;
  }

  exec { 'easy_install allmydata-tahoe':
    unless => 'python -c "import allmydata"',
  }
}
