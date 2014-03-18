# (C) 2014, Fusionbox, Inc.
# Please refer to COPYING for more informations.

class iptables($policies={}) {
  if $kernel != 'Linux' {
    fail('iptables module only works on Linux')
  }

  if $lsbdistid == 'Debian' {
    package {'iptables-persisent':
      name   => 'iptables-persistent',
      ensure => latest,
    }

    $ipv4_rules = '/etc/iptables/rules.v4'

    concat { $ipv4_rules:
      owner          => 'root',
      group          => 'root',
      mode           => 0644,
      ensure_newline => true,
    }

    concat::fragment {"iptables-policies-header":
      target  => $ipv4_rules,
      content => template('iptables/policies.erb'),
      order   => '001',
    }

    concat::fragment {"iptables-policies-footer":
      target  => $ipv4_rules,
      content => "COMMIT",
      order   => '999',
    }

    exec {"commit-iptables":
      command   => "/sbin/iptables-restore < ${ipv4_rules}",
      subscribe => Concat["$ipv4_rules"],
    }

    file {"/etc/iptables/rules.v6":
      ensure => absent
    }

  }

}
