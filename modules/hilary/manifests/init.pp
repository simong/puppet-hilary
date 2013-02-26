class hilary (
    $app_root_dir,
    $app_git_user,
    $app_git_branch,
    $ux_root_dir,
    $ux_git_user,
    $ux_git_branch,
    $os_user,
    $os_group,
    $upload_files_dir,
    $enable_activities = false,
    $enable_previews   = false,
    $provider          = 'pkgin',
    $service_name      = 'node-sakai-oae') {

  ##########################
  ## PACKAGE DEPENDENCIES ##
  ##########################

  case $operatingsystem {
    debian, ubuntu: {
      $packages   = [ 'gcc', 'automake', 'nodejs', 'npm', 'graphicsmagick', 'git' ]
      $npm_binary = '/usr/bin/npm'
      $path       = ['/usr/local/sbin', '/usr/local/bin', '/usr/sbin', '/usr/bin', '/sbin', '/bin']
    }
    solaris, Solaris: {
      $packages   = [ 'gcc47', 'automake', 'gmake', 'nodejs', 'GraphicsMagick', 'scmgit' ]
      $npm_binary = '/opt/local/bin/npm'
      $path       = ['/opt/local/gnu/bin', '/opt/local/bin', '/opt/local/sbin', '/usr/bin', '/usr/sbin']
    }
    default: {
      $packages   = [ 'gcc', 'automake', 'gmake', 'nodejs', 'npm', 'GraphicsMagick', 'git' ]
      $npm_binary = '/usr/bin/npm'
      $path       = ['/usr/local/sbin', '/usr/local/bin', '/usr/sbin', '/usr/bin', '/sbin', '/bin']
    }
  }

  package { $packages:
    ensure    => present,
    provider  => $provider,
  }

  ########################
  ## DEPLOY APPLICATION ##
  ########################

  # git clone http://github.com/sakaiproject/Hilary
  vcsrepo { $app_root_dir:
    ensure    => present,
    provider  => git,
    source    => "http://github.com/${app_git_user}/Hilary",
    revision  => $app_git_branch,
  }

  file { $app_root_dir:
    ensure  => directory,
    mode    => "0644",
    owner   => $os_user,
    group   => $os_group,
    recurse => true,
    require => Vcsrepo[$app_root_dir],
  }

  # npm install -d
  exec { "npm_install_dependencies":
    cwd         => $app_root_dir,
    command     => "${npm_binary} install -d",
    logoutput   => "on_failure",
    path        => $path,
    require     => [ File[$app_root_dir], Package[$packages], Vcsrepo[$app_root_dir] ],
  }

  # Directory for temp files
  file { $upload_files_dir:
    ensure  => directory,
    owner   => $os_user,
    group   => $os_group,
  }

  # config.js
  file { "${app_root_dir}/config.js":
    ensure  => present,
    content => template('localconfig/config.js.erb'),
    require => [ Vcsrepo[$app_root_dir], File[$upload_files_dir] ],
  }



  ####################
  ## CLONE 3AKAI-UX ##
  ####################

  # git clone http://github.com/sakaiproject/3akai-ux
  vcsrepo { $ux_root_dir:
    ensure    => present,
    provider  => git,
    source    => "http://github.com/${ux_git_user}/3akai-ux",
    revision  => $ux_git_branch,
  }



  #######################
  ## START APPLICATION ##
  #######################

  case $operatingsystem {
    debian, ubuntu: {

      file { "/etc/init/hilary.conf":
        ensure  =>  present,
        content =>  template('localconfig/upstart_hilary.conf.erb'),
        require =>  Vcsrepo[$app_root_dir],
      }

      # Create a symlink to /etc/init/*.conf in /etc/init.d, because Puppet 2.7 looks there incorrectly (see: http://projects.puppetlabs.com/issues/14297)
      file { '/etc/init.d/hilary':
        ensure => link,
        target => '/lib/init/hilary',
        require =>  File["/etc/init/hilary.conf"],
      }

      service { 'hilary':
        ensure   => running,
        provider => 'upstart',
        require  => [ File['/etc/init.d/hilary'],
                      Vcsrepo[$ux_root_dir],
                      Exec["npm_install_dependencies"],
                      File["${app_root_dir}/config.js"]
                    ],
        subscribe => File["${app_root_dir}/config.js"],     # Restart the service when the config gets refreshed.
      }
    }
    solaris, Solaris: {
      # Daemon script needed for SMF to manage the application
      file { "${app_root_dir}/service.xml":
        ensure  =>  present,
        content =>  template('localconfig/node-oae-service-manifest.xml.erb'),
        notify  =>  Exec["svccfg_${service_name}"],
        require =>  Vcsrepo[$app_root_dir],
      }

      # Force reload the manifest
      exec { "svccfg_${service_name}":
        command   => "/usr/sbin/svccfg import ${app_root_dir}/service.xml",
        notify    => Service[$service_name],
        require   => File["${app_root_dir}/service.xml"],
      }

      # Start the app server
      service { $service_name:
        ensure   => running,
        manifest => "${app_root_dir}/service.xml",
        require  => [ Exec["svccfg_${service_name}"],
                      Vcsrepo[$ux_root_dir],
                      Exec["npm_install_dependencies"],
                    ],
        subscribe => File["${app_root_dir}/config.js"],     # Restart the service when the config gets refreshed.
      }
    }
    default: {
      exec { "notsupported":
        command   => fail("No support yet for ${::operatingsystem}")
      }
    }
  }
}


################
## MONITORING ##
################

class hilary::nagios {

  @@nagios_service { "check_app_running_${hostname}":
      use                 => "generic-service",
      service_description => "APP",
      host_name           => "$hostname",
      check_command       => "check_nrpe_1arg!check_app_running",
      target              => "/etc/nagios3/conf.d/puppet/services/$hostname-check-app-running.cfg",
  }

  @@nagios_service { "check_app_http_admin_${hostname}":
      use                 => "generic-service",
      service_description => "HTTP ADMIN",
      host_name           => "$hostname",
      check_command       => "check_nrpe_1arg!check_app_http_admin",
      target              => "/etc/nagios3/conf.d/puppet/services/$hostname-check-app-http-admin.cfg",
  }

  @@nagios_service { "check_app_http_tenant_${hostname}":
      use                 => "generic-service",
      service_description => "HTTP TENANT",
      host_name           => "$hostname",
      check_command       => "check_nrpe_1arg!check_app_http_tenant",
      target              => "/etc/nagios3/conf.d/puppet/services/$hostname-check-app-http-tenant.cfg",
  }

  @@nagios_service { "check_disk_tmp_${hostname}":
      use                 => "generic-service",
      service_description => "DISK TMP",
      host_name           => "$hostname",
      check_command       => "check_nrpe_1arg!check_disk_tmp",
      target              => "/etc/nagios3/conf.d/puppet/services/$hostname-check-disk-tmp.cfg",
  }

  @@nagios_service { "check_disk_shared_${hostname}":
      use                 => "generic-service",
      service_description => "DISK SHARED",
      host_name           => "$hostname",
      check_command       => "check_nrpe_1arg!check_disk_shared",
      target              => "/etc/nagios3/conf.d/puppet/services/$hostname-check-disk-shared.cfg",
  }
}
