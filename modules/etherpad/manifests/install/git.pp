class etherpad::install::git ($install_config, $etherpad_dir = '/opt/etherpad') {
    require ::oaeservice::deps::package::git

    $_install_config = merge({
        'etherpad_source'    => 'https://github.com/ether/etherpad-lite',
        'etherpad_revision'  => 'master'
    }, $install_config)

    # Get the etherpad source
    vcsrepo { $etherpad_dir:
        ensure      =>  present,
        provider    =>  git,
        source      => $_install_config['etherpad_source'],
        revision    => $_install_config['etherpad_revision'],
    }

    # Install the etherpad npm dependencies
    exec { 'install_etherpad_dependencies':
        command     =>  "${etherpad_dir}/bin/installDeps.sh",
        cwd         =>  $etherpad_dir,
        require     =>  Vcsrepo[$etherpad_dir],
    }

    # Install the OAE etherpad plugin
    vcsrepo { "${etherpad_dir}/node_modules/ep_oae":
        ensure      =>  present,
        provider    =>  git,
        source      =>  $_install_config['ep_oae_source'],
        revision    =>  $_install_config['ep_oae_revision'],
        require     =>  Exec['install_etherpad_dependencies'],
    }

    # Install the custom CSS for etherpad
    file { "${etherpad_dir}/src/static/custom/pad.css":
        ensure     => present,
        source     => "${etherpad_dir}/node_modules/ep_oae/static/css/pad.css",
        require    => Vcsrepo["${etherpad_dir}/node_modules/ep_oae"],
    }

    # Install the headings plugin
    exec { "install_ep_headings":
        command     => "npm install ep_headings",
        cwd         => $etherpad_dir,
        unless      => "npm ls ep_headings@0.1.6 | grep ep_headings",
        require     => Exec['install_etherpad_dependencies'],
    }

    # Install the spellchecker plugin
    exec { "install_ep_spellcheck":
        command     => "npm install ep_spellcheck",
        cwd         => $etherpad_dir,
        unless      => "npm ls ep_spellcheck@0.0.2 | grep ep_spellcheck",
        require     => Exec['install_etherpad_dependencies'],
    }

    # Install the page view plugin
    exec { "install_ep_page_view":
        command     => "npm install ep_page_view",
        cwd         => $etherpad_dir,
        unless      => "npm ls ep_page_view@0.5.0 | grep ep_page_view",
        require     => Exec['install_etherpad_dependencies'],
    }

    # Install the line height plugin
    exec { "install_ep_line_height":
        command     => "npm install ep_line_height",
        cwd         => $etherpad_dir,
        unless      => "npm ls ep_line_height@0.0.2 | grep ep_line_height",
        require     => Exec['install_etherpad_dependencies'],
    }
}
