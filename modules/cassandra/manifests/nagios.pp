class cassandra::nagios {

  ##############
  # Monitoring #
  ##############

  # todo: Make this work for non solaris systems.

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
