plan vagrant_bolt_cd4pe::cd4pe_config (
  TargetSpec $targets,
  TargetSpec $agent,
  TargetSpec $gitlab,
  Optional[String[1]] $access_token = 'FvmcbSWwpS9LxZYs1iBt',
) {


  $agent.apply_prep
  without_default_logging() || { run_plan(facts, targets => $agent) }
  $agent_facts = get_target($agent).facts()
  $agent_fqdn = $agent_facts['fqdn']
  $agent_ip = $agent_facts['ec2_metadata']['public-ipv4']

  $targets.apply_prep
  without_default_logging() || { run_plan(facts, targets => $targets) }
  $master_facts = get_target($targets).facts()
  $master_fqdn = $master_facts['fqdn']
  $master_ip = $master_facts['ec2_metadata']['public-ipv4']

  $gitlab.apply_prep
  without_default_logging() || { run_plan(facts, targets => $gitlab) }
  $gitlab_facts = get_target($gitlab).facts()
  $gitlab_fqdn = $gitlab_facts['fqdn']
  $gitlab_ip = $gitlab_facts['ec2_metadata']['public-ipv4']

  $email = 'root@puppet.com'
  $password = 'test'
  $user = 'test'
  $user_email = "${user}@puppet.com"
  $user_workspace = "${user}-workspace"


  $root_config = { root_email                 => $email,
                    root_password             => $password,
                    generate_trial_license    => true,
                    resolvable_hostname       => $agent_fqdn,
  }

  $install_config = { cd4pe_admin_email       => $email,
                    cd4pe_admin_password      => $password,
                    resolvable_hostname       => $agent_fqdn,
                    cd4pe_version             => '3.x',
                    cd4pe_docker_extra_params => ["--add-host ${master_fqdn}:${master_ip}",
                                                  "--add-host ${agent_fqdn}:${agent_ip}",
                                                  "--add-host ${gitlab_fqdn}:${gitlab_ip}",
                    ],
  }

  $install_config_json = $install_config.to_json()

  $user_config = {
      email      => $user_email,
      username   => $user,
      password   => $password,
      first_name => 'Test',
      last_name  => 'User',
  }

  $workspace_config = {
      email     => $user_email,
      password  => $password,
      username  => $user,
      workspace => $user_workspace,
  }

  $vcs_config = {
    email     => $user_email,
    password  => $password,
    provider  => 'gitlab',
    workspace => $user_workspace,
    provider_specific => {
      host  => "http://${gitlab_fqdn}",
      token => $access_token,
      sshPort => '8022',
    }
  }

  $pe_config = {
    email           => $user_email,
    password        => $password,
    workspace       => $user_workspace,
    creds_name      => $targets,
    pe_console_host => $master_fqdn,
    pe_username     => 'admin',
    pe_password     => 'puppetlabs',
  }

#  $crepo_config = {
#    email => $user_email,
#    password => $password,
#    repo_type => 'control',
#    source_control => 'gitlab',
#    source_repo_name => 'control-repo',
#    source_repo_org => 'root',
#    repo_name => 'control-repo',
#    source_repo_branch => 'master',
#    workspace => $user_workspace,
#  }
#
#  $pipeline_config = {
#    email         => $user_email,
#    password      => $password,
#    workspace     => $user_workspace,
#    repo_name     => 'control-repo',
#    repo_branch   => 'master',
#    pipeline_type => 'control',
#  }
#
#  $module_pipeline_config = {
#    email         => $user_email,
#    password      => $password,
#    workspace     => $user_workspace,
#    repo_name     => 'puppetlabs-motd',
#    repo_branch   => 'master',
#    pipeline_type => 'module',
#  }

  run_command("/opt/puppetlabs/bin/puppet task run pe_installer_cd4pe::install --params '${install_config_json}' -n ${agent_fqdn}", $targets)
  run_task('cd4pe::root_configuration',             $agent, $root_config)
  run_task('cd4pe::create_user',             $agent, $user_config)
  run_task('cd4pe::create_workspace',        $agent, $workspace_config)
  run_task('cd4pe::add_vcs_integration',     $agent, $vcs_config)
  run_task('cd4pe::discover_pe_credentials', $agent, $pe_config)

# The add repo task does not seem to work.  From looking over the code, it looks outdated
# and may not be currently maintained.
#  run_task('cd4pe::add_repo', $agent, $crepo_config)
#  run_task('cd4pe::create_pipeline',          $agent, $pipeline_config)
#  run_task create the puppetlabs-motd repo
#  run_task('cd4pe::create_pipeline',          $agent, $module_pipeline_config)
}
