class oaeservice::munin::cassandra {

  # Munin needs to be installed before this class can be applied
  Class['munin::client'] -> Class['oaeservice::munin::cassandra']

  # Copy the plugins to the right place.
  file { '/etc/munin/plugins/cassandra_oae_principals':
    ensure  => present,
    content => template('munin/plugins/cassandra/cassandra_oae_principals'),
    mode    => 1777,
  }
}