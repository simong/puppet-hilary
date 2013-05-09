class oaeservice::driver {

  require oaeservice::deps::common
  require oaeservice::deps::package::git
  require oaeservice::deps::package::nodejs

  Class['::oaeservice::deps::common']                   -> Class['::tsung']
  Class['::oaeservice::deps::package::git']             -> Class['::tsung']
  Class['::oaeservice::deps::package::nodejs']          -> Class['::tsung']

  class { '::tsung': }

  package { 'nginx':
    ensure    => present,
    provider  => pkgin,
  }

  service { 'nginx':
    ensure  => running,
    enable  => true,
    require => Package['nginx'],
  }

  vcsrepo { '/opt/slapchop':
    ensure    => latest,
    provider  => git,
    source    => "http://github.com/simong/slapchop",
    revision  => "performance",
  }

  vcsrepo { '/opt/oae-nightly-stats':
    ensure    => latest,
    provider  => git,
    source    => "http://github.com/simong/oae-nightly-stats",
    revision  => "nightly-performance",
  }

  vcsrepo { '/opt/OAE-model-loader':
    ensure    => latest,
    provider  => git,
    source    => "http://github.com/sakaiproject/OAE-model-loader",
    revision  => "Hilary",
  }

  cron { 'nightly-performance-run':
    ensure  => present,
    command => "/opt/oae-nightly-stats/nightly-run.sh",
    user    => 'root',
    target  => 'root',
    hour    => 4,
    minute  => 0,
  }
}