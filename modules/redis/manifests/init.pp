class redis (
    $eviction_maxmemory   = 'null',
    $eviction_policy      = 'null',
    $eviction_samples     = 'null',
    $slave_of             = 'null',) {

  package { 'redis':
    ensure    => present,
    provider  => pkgin,
  }

  exec { 'svccfg import redis.xml':
    command => '/usr/sbin/svccfg import /opt/local/share/smf/redis/manifest.xml',
    require => Package['redis'],
  }

  # Set the configuration file.
  file { 'redis.conf':
    path    => '/opt/local/etc/redis.conf',
    ensure  => present,
    mode    => 0644,
    owner   => $owner,
    group   => $group,
    content => template('redis/redis.conf.erb'),
    require => Package['redis']
  }

  # define the service to restart
  service { 'redis':
    ensure    => 'running',
    enable    => 'true',
    require   => File['redis.conf'],
    subscribe => File['redis.conf']
  }
}

class redis::nagios {

  ##############
  # Monitoring #
  ##############

  # todo: Make this work for non solaris systems.

  package { 'ruby18-rubygems-1.8.24':
      ensure   => 'installed',
      provider => 'pkgin',
  }

  exec { '/opt/local/bin/gem18 install redis':
      command  => '/opt/local/bin/gem18 install redis',
      require  => Package['ruby18-rubygems-1.8.24'],
  }

  file { '/opt/local/libexec/nagios/check_redis':
      path    => '/opt/local/libexec/nagios/check_redis',
      ensure  => present,
      mode    => 0555,
      owner   => 'root',
      group   => 'root',
      content => template('redis/check_redis'),
  }

  @@nagios_service { "check_redis_running_${hostname}":
        use                 => "generic-service",
        service_description => "REDIS",
        host_name           => "$hostname",
        check_command       => "check_nrpe_1arg!check_redis_running",
        target              => "/etc/nagios3/conf.d/puppet/services/$hostname-check-redis-running.cfg",
  }

  @@nagios_service { "check_redis_memory_${hostname}":
        use                 => "generic-service",
        service_description => "MEM",
        host_name           => "$hostname",
        check_command       => "check_nrpe_1arg!check_redis_memory",
        target              => "/etc/nagios3/conf.d/puppet/services/$hostname-check-redis-memory.cfg",
  }
}
