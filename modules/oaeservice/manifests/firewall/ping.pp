class oaeservice::firewall::ping {
  # Accept ICMP pings on the public interface
  iptables { '004 allow icmp pings':
    chain   => 'INPUT',
    iniface => 'eth0',
    proto   => 'icmp',
    state   => ['NEW', 'ESTABLISHED', 'RELATED'],
    icmp    => 8,
    jump    => 'ACCEPT',
  }
}
