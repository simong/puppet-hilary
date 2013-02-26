###################
## Nagios Client ##
###################

class nagios::client (
    $hostgroups     = 'appservers',
    ){
    

    package { $nagios::client::params::packages:
        ensure          => present,
        provider        => $nagios::client::params::provider,
    }

    # Overwrite nrpe.cfg
    file { $nagios::client::params::nrpe_cfg_path:
        ensure  =>  present,
        content =>  template('nagios/nrpe.cfg.erb'),
        require =>  Package[$nagios::client::params::packages],
        notify  =>  Service[$nagios::client::params::nrpe_service]
    }

    service {$nagios::client::params::nrpe_service:
        ensure  => running
    }


    @@nagios_host { $hostname:
        host_name       => $hostname,
        hostgroups      => $hostgroups,
        ensure          => present,
        alias           => $hostname,
        address         => $ipaddress_net1,
        use             => "generic-host",
        target          => "/etc/nagios3/conf.d/puppet/hosts/$hostname.cfg",
    }

    @@nagios_hostextinfo { $hostname:
        ensure          => present,
        icon_image_alt  => $operatingsystem,
        icon_image      => "base/$operatingsystem.png",
        statusmap_image => "base/$operatingsystem.gd2",
        target          => "/etc/nagios3/conf.d/puppet/hostextinfo/$hostname.cfg",
    }

    # We add a couple of default checks such as ping, ssh, ..
    @@nagios_service { "check_ping_${hostname}":
        use                 => "generic-service",
        service_description => "PING",
        host_name           => "$hostname",
        check_command       => "check_ping!100.0,20%!500.0,60%",
        target              => "/etc/nagios3/conf.d/puppet/services/$hostname-check-ping.cfg",
    }

    @@nagios_service { "check_ssh_${hostname}":
        use                 => "generic-service",
        service_description => "SSH",
        host_name           => "$hostname",
        check_command       => "check_ssh",
        target              => "/etc/nagios3/conf.d/puppet/services/$hostname-check-ssh.cfg",
    }

    @@nagios_service { "check_load_${hostname}":
        use                 => "generic-service",
        service_description => "LOAD",
        host_name           => "$hostname",
        check_command       => "check_nrpe_1arg!check_load",
        target              => "/etc/nagios3/conf.d/puppet/services/$hostname-check-load.cfg",
    }

    @@nagios_service { "check_users_${hostname}":
        use                 => "generic-service",
        service_description => "USERS",
        host_name           => "$hostname",
        check_command       => "check_nrpe_1arg!check_users",
        target              => "/etc/nagios3/conf.d/puppet/services/$hostname-check-users.cfg",
    }
}

class nagios::client::params {
    case $operatingsystem {
        debian, ubuntu: {
            $packages           = [ 'nagios-nrpe-plugin', 'nagios-plugins' ]
            $nrpe_cfg_path      = '/opt/local/etc/nagios/nrpe.cfg'
            $nrpe_service       = 'nrpe'
            $provider           = 'apt'
        }
        centos: {
            $packages           = [ 'nagios-nrpe-plugin', 'nagios-plugins-nrpe' ]
            $nrpe_cfg_path      = '/opt/local/etc/nagios/nrpe.cfg'
            $nrpe_service       = 'nrpe'
            $provider           = 'yum'
        }
        Solaris: {
            $packages           = [ 'nagios-nrpe-2.12nb2', 'nagios-plugins-1.4.15nb2' ]
            $nrpe_cfg_path      = '/opt/local/etc/nagios/nrpe.cfg'
            $nrpe_service       = 'nrpe'
            $provider           = 'pkgin'
        }
        default: {
            err('We currently only support Nagios clients for debian, ubuntu and Solaris.')
        }
    }
}