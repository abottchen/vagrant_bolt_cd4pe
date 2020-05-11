plan vagrant_bolt_cd4pe::wire_dns(
  TargetSpec $targets,
  TargetSpec $gitlab,
  TargetSpec $master,
  TargetSpec $agent,
) {

  $targets.apply_prep
  without_default_logging() || { run_plan(facts, targets => $targets) }
  $dns_facts = get_target($targets).facts()
  $dns_ip = $dns_facts['ec2_metadata']['public-ipv4']
  out::message("Found DNS server IP: '${dns_ip}'")

  [$gitlab, $master, $agent].each |$host| {
    $host.apply_prep
    out::message("Updating facts for ${host}")
    without_default_logging() || { run_plan(facts, targets => $host) }
    $host_facts = get_target($host).facts()

    out::message("Adding DNS records for ${host} on ${targets}")
    run_task('vagrant_bolt_bind::add_host', $targets, 
      ipaddress => $host_facts['ec2_metadata']['public-ipv4'],
      hostname => $host_facts['fqdn'],
    ) 
    out::message("Setting DNS server on ${host} to ${targets}")
    run_task('vagrant_bolt_bind::set_nameserver', $host, 
      ipaddress => $dns_ip,
    ) 
  }
}

