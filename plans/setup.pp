# @summary A plan to configure an entire CD4PE stack
#
# @param agent
#  The TargetSpec of the PE agent you wish to be the CD4PE host
# @param master
#  The TargetSpec of the PE master of $agent
# @param gitlab
#  The TargetSpec of the gitlab server.  This is currently expected to have been built using vagrant_bolt_gitlab::install, since the plan makes assumptions.
# @param dns
#  Optional: The TargetSpec of the DNS server.  This is currently expected to have been built using vagrant_bolt_bind::install, since the plan makes assumptions.
# @example Install a 2019.1.1 PE master on a node using `puppetlabs` as the password
#   '/opt/puppetlabs/bin/bolt plan run vagrant_bolt_cd4pe::setup gitlab=infra dns=infra master=pe-201950-master agent=cd4pe-bolt
plan vagrant_bolt_cd4pe::setup (
  TargetSpec $gitlab,
  Optional[TargetSpec] $dns = undef,
  TargetSpec $master,
  TargetSpec $agent,
)  {

  run_plan(vagrant_bolt_cd4pe::wire_dns, $dns, {gitlab => $gitlab, master => $master, agent => $agent})
  run_plan(vagrant_bolt_cd4pe::wire_code_manager, $master, {gitlab => $gitlab})
  run_task(vagrant_bolt_cd4pe::add_cd4pe_module, $master, {gitlab => $gitlab})
  run_plan(vagrant_bolt_cd4pe::cd4pe_config, $master, {agent => $agent, gitlab => $gitlab})
}
