
###################
## Nagios Server ##
###################

class nagios::server {

    $packages = ['nagios3', 'nagios-nrpe-plugin', 'nagiosgrapher']
    package { $packages:
        ensure   => installed,
    }

    $nagios_directories = [ "/etc/nagios3/conf.d", "/etc/nagios3/conf.d/puppet", "/etc/nagios3/conf.d/puppet/hosts", "/etc/nagios3/conf.d/puppet/hostextinfo", "/etc/nagios3/conf.d/puppet/services", "/etc/nagios3/conf.d/puppet/hostgroups" ]
    file { $nagios_directories:
        ensure          => "directory",
        require         => Package[$packages],
        owner           => "nagios",
        group           => "nagios",
        recurse         => "true",
    }

    service { "nagios3":
        ensure          => running,
        alias           => "nagios",
        hasstatus       => true,
        hasrestart      => true,
        require         => [ Package[$packages], File[$nagios_directories] ]
    }

    # collect resources and populate them in the /etc/nagios folder
    Nagios_host <<||>> {
        notify          => Service["nagios3"],
    }
    Nagios_service <<||>> {
        notify          => Service["nagios3"],
    }
    Nagios_hostextinfo <<||>> {
        notify          => Service["nagios3"],
    }

    # Create the possible hostgroups.
    nagios_hostgroup {'nagios_hostgroup_appservers':
        alias               =>  'Application Servers',
        hostgroup_name      =>  'appservers',
        target              =>  "/etc/nagios3/conf.d/puppet/hostgroups/appservers.cfg",
    }
    nagios_hostgroup {'nagios_hostgroup_dbservers':
        alias               =>  'DB Servers',
        hostgroup_name      =>  'dbservers',
        target              =>  "/etc/nagios3/conf.d/puppet/hostgroups/dbservers.cfg",
    }
    nagios_hostgroup {'nagios_hostgroup_searchservers':
        alias               =>  'Search Servers',
        hostgroup_name      =>  'searchservers',
        target              =>  "/etc/nagios3/conf.d/puppet/hostgroups/searchservers.cfg",
    }
    nagios_hostgroup {'nagios_hostgroup_ppservers':
        alias               =>  'Preview Processors',
        hostgroup_name      =>  'ppservers',
        target              =>  "/etc/nagios3/conf.d/puppet/hostgroups/ppservers.cfg",
    }
    nagios_hostgroup {'nagios_hostgroup_cachingservers':
        alias               =>  'Caching Servers',
        hostgroup_name      =>  'cacheservers',
        target              =>  "/etc/nagios3/conf.d/puppet/hostgroups/cacheservers.cfg",
    }
    nagios_hostgroup {'nagios_hostgroup_activityservers':
        alias               =>  'Activity Servers',
        hostgroup_name      =>  'activityservers',
        target              =>  "/etc/nagios3/conf.d/puppet/hostgroups/activityservers.cfg",
    }
}
