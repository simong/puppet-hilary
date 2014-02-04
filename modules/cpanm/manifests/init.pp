class cpanm {

  # Copy the cpan installation script.
  file { '/root/cpanm.pl':
    ensure  => present,
    content => template('cpanm/cpanm.pl'),
  }

  # Ensure the perldoc utility is present
  # This will allow us to check if a module is already installed
  package { 'perl-doc':
    ensure => present,
  }

  # Run the installer if cpanm is not installed.
  exec { 'install_cpanm':
    unless  => 'test -f /usr/local/bin/cpanm',
    command => '/usr/bin/perl /root/cpanm.pl --self-upgrade',
    require => File['/root/cpanm.pl'],
  }
}
