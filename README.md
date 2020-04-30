Concept workflow:

- The user will have already provisioned a dns, gitlab, and PE server along with an agent to that master.  
- The plan will take these targets as paramters `dns=<> gitlab=<> master=<> agent=<>`
- Set up DNS
  - Go through all targets, pull their hostname and IP
    - Will need to add a task to vagrant_bolt_bind that does this
  - use vagrant_bolt_bind::add_host to push all of these to the dns server
  - use vagrant_bolt_bind::set_nameserver on each target to set it to the dns server's IP
- Set up code manager
  - Install jq on the PE master to process the API calls?
  - Use GET /v1/groups to get the id for the PE Master group
    - https://puppet.com/docs/pe/2018.1/groups_endpoint.html#get_v1_groups
  - Use `POST /v1/groups/<id>` classifier API to push a new PE master group with the code manager params
    - https://puppet.com/docs/pe/2018.1/groups_endpoint.html#reference-9634
    - set 
      - code_manager_auto_configure = true
      - r10k_remote = git@<gitlabserver>:root/control-repo.git
      - r10k_private_key = /etc/puppetserver/conf.d/blah.key
    - Upload the key to the private key location
    - Run `puppet agent -t`
    - Run `puppet access login -l 0 --user admin --password puppetlabs`
- Connect CD4PE
  - install and configure using the cd4pe module tasks
  - WIP

