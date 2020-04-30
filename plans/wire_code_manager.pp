plan vagrant_bolt_cd4pe::wire_code_manager(
  TargetSpec $master,
) {

  out::message("Installing jq on ${master}")
  run_command('curl -sLo /usr/local/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64', $master)
  run_command('chmod +x /usr/local/bin/jq', $master)
  
  out::message("Uploading gitlab ssh key")
  run_plan('vagrant_bolt_gitlab::upload_ssh_key', $master)
  
  out::message("Adding code manager to the PE Master node group")
  $id_hash = run_task('vagrant_bolt_cd4pe::add_cm_to_pe_master_group', $master)
  $id = $id_hash.to_data[0]['value']['_output']
  out::message($id)

  # TODO: All of the following needs to be wrapped in a no-normal-logging block
  # TODO:  This run_command needs to accept a return code of 2
  out::message("Running puppet to pull in code manager update")
  run_command('/opt/puppetlabs/bin/puppet agent -t', $master)

  out::message("Generating token")
  run_command('echo "puppetlabs" | /opt/puppetlabs/bin/puppet access login -l 0 --username "admin"', $master)

  out::message("Deploying production")
  run_command('/opt/puppetlabs/bin/puppet code deploy production --wait', $master)
}

