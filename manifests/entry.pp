define iptables::entry ($table="filter", $chain="INPUT", $proto="tcp",
                        $dport=undef, $jump="ACCEPT", $position=50, $source=undef, $rule=undef) {

  $target = $iptables::ipv4_rules

  if $position < 0 {
    fail("position should be a positive number")
  }
  if $position > 800 {
    fail("position can't be greater than 800")
  }

  $absolute_position = 100 + $position

  if $rule == undef {

    if $dport == undef {
      fail("You should specify a port to open")
    }

    if $source == undef {
      concat::fragment {"$name":
        target  => $target,
        content => "-A ${chain} -p ${proto} --dport $dport -j $jump -m comment --comment \"${name}\"",
        order   => "${absolute_position}",
      }
    }
    else {
      concat::fragment {"$name":
        target  => $target,
        content => "-A ${chain} -s ${source} -p ${proto} --dport $dport -j $jump -m comment --comment \"${name}\"",
        order   => "${absolute_position}",
      }
    }

  } else {
    concat::fragment{"$name":
      target  => $target,
      content => "$rule -m comment --comment \"${name}\"",
      order   => "${absolute_position}",
    }
  }
}
