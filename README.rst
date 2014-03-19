Puppet ``iptables`` Management Like it should be
================================================

This is how puppet ``iptables`` management should be:

Idempotent
    Running puppet again and again, with the same iptable configuration should
    not modify anything.

Transactional
    When ``iptables`` rules changed, it should not remove or add rules one by
    one. There should not be intermediate states.


This does not intend to be compatible with other platforms other than Linux.
This is just a proof of concept for now. It only works on Debian.

Examples
--------

.. code-block:: puppet

    # Define the default policies for each node

    node base {
      class {"iptables":
        policies => {
          'INPUT'   => "DROP",
          'OUTPUT'  => "ACCEPT",
          'FORWARD' => "DROP",
        },
      }

      iptables::entry {"accept ssh":
        dport => 22,
        jump  => "ACCEPT",
      }

    }

    class dns_server {
      package {"bind9":
        ensure => pesent;
      }

      iptables::entry {"accept dns traffic":
        proto => "udp",
        dport => "domain", # Equivalent to 53
      }
    }

    node dns1.example.com inherits base {
      include dns_server

      iptables::entry {"accept replication from dns2.example.com":
        proto  => "tcp", # Default value
        source => "dns2.example.com",
        dport  => "domain",
        jump   => "ACCEPT",
      }

      iptables::entry {"block kumar":
        rule => "-A INPUT -m country --country-block kumar -j REJECT",
      }

    }

Known bugs
----------

For now, this is a proof of concept:

 * It only supports IPv4
 * It only work on Debian
 * It only supports the filter table
