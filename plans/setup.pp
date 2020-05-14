plan vagrant_bolt_cd4pe::setup (
  TargetSpec $gitlab,
  TargetSpec $dns,
  TargetSpec $master,
  TargetSpec $agent,
)  {

  run_plan(vagrant_bolt_cd4pe::wire_dns, $dns, {gitlab => $gitlab, master => $master, agent => $agent})
  run_plan(vagrant_bolt_cd4pe::wire_code_manager, $master, {gitlab => $gitlab})
  run_task(vagrant_bolt_cd4pe::add_cd4pe_module, $master, {gitlab => $gitlab})
  run_plan(vagrant_bolt_cd4pe::cd4pe_config, $master, {agent => $agent, gitlab => $gitlab})
}
