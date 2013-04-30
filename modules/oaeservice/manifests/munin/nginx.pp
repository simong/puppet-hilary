class oaeservice::munin::nginx {
    class { '::cpanm::install':
        libraries => ['LWP::UserAgent'],
    }
}