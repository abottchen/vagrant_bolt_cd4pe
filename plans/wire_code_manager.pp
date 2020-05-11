plan vagrant_bolt_cd4pe::wire_code_manager(
  TargetSpec $targets,
  TargetSpec $gitlab,
) {

#  out::message("Installing jq on ${targets}")
#  run_command('curl -sLo /usr/local/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64', $targets)
#  run_command('chmod +x /usr/local/bin/jq', $targets)
#
#  out::message('Uploading gitlab ssh key')
#  run_plan('vagrant_bolt_gitlab::upload_ssh_key', $targets)
#
#  out::message('Gathering facts from gitlab server')
#  $gitlab.apply_prep
#  without_default_logging() || { run_plan(facts, targets => $gitlab) }
#  $gitlab_facts = get_target($gitlab).facts()
#  $gitlab_fqdn = $gitlab_facts['fqdn']
#  $r10k_remote = "ssh://git@${gitlab_fqdn}:8022/root/control-repo.git"
#  out::message('Adding code manager to the PE Master node group')
#  out::message("Setting r10k_remote to '${r10k_remote}'")
#  $id_hash = run_task('vagrant_bolt_cd4pe::add_cm_to_pe_master_group', $targets, {r10k_remote => $r10k_remote})
#  $id = $id_hash.to_data[0]['value']['_output']
#
#  out::message('Running puppet to pull in code manager update')
#  run_command('/opt/puppetlabs/bin/puppet agent -t ; if [ $? -eq 2 ]; then exit 0; fi', $targets)
#
#  out::message("Setting up dev environment on ${targets}")
#  run_plan(vagrant_bolt_gitlab::clone_control_repo, $targets, {gitlab => $gitlab})
#
#  out::message('Updating Puppetfille')
#  run_task(vagrant_bolt_cd4pe::add_cd4pe_module, $targets, {gitlab => $gitlab})
#
#  out::message('Generating token')
#  run_command('echo "puppetlabs" | /opt/puppetlabs/bin/puppet access login -l 0 --username "admin"', $targets)

#  run_command('/opt/puppetlabs/bin/puppet code deploy production --wait', $targets, 'Deploying production')

  out::message('Running puppet to pull in cd4pe module code')
  run_command('/opt/puppetlabs/bin/puppet agent -t ; if [ $? -eq 2 ]; then exit 0; fi', $targets)
}

