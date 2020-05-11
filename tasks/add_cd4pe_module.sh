#!/bin/bash
PT_gitlab="infra.puppetdebug.vlan"

cd /root/dev/control-repo || exit

git stash
git checkout production

grep "^[^#].*puppetlabs-cd4pe" Puppetfile > /dev/null || 
  echo "mod 'puppetlabs-cd4pe', :latest" >> Puppetfile

grep "^[^#].*puppetlabs-concat" Puppetfile  > /dev/null || 
  echo "mod 'puppetlabs-concat', '5.3.0'" >> Puppetfile

grep "^[^#].*puppetlabs-hocon" Puppetfile > /dev/null || 
  echo "mod 'puppetlabs-hocon', '1.0.1'" >> Puppetfile

grep "^[^#].*puppetlabs-puppet_authorization" Puppetfile > /dev/null || 
  echo "mod 'puppetlabs-puppet_authorization', '0.5.0'" >> Puppetfile

grep "^[^#].*puppetlabs-stdlib" Puppetfile > /dev/null || 
  echo "mod 'puppetlabs-stdlib', '4.25.1'" >> Puppetfile

grep "^[^#].*puppetlabs-docker" Puppetfile > /dev/null || 
  echo "mod 'puppetlabs-docker', '3.2.0'" >> Puppetfile

grep "^[^#].*puppetlabs-reboot" Puppetfile > /dev/null || 
  echo "mod 'puppetlabs-reboot', '2.0.0'" >> Puppetfile

grep "^[^#].*puppetlabs-apt" Puppetfile > /dev/null || 
  echo "mod 'puppetlabs-apt', '6.2.1'" >> Puppetfile

grep "^[^#].*puppetlabs-translate" Puppetfile > /dev/null || 
  echo "mod 'puppetlabs-translate', '1.1.0'" >> Puppetfile

grep "^[^#].*puppetlabs-cd4pe_jobs" Puppetfile > /dev/null || 
  echo "mod 'puppetlabs-cd4pe_jobs', :latest" >> Puppetfile
 
grep "^[^#].*puppetlabs-powershell" Puppetfile > /dev/null || 
  echo "mod 'puppetlabs-powershell', '2.2.0'" >> Puppetfile

grep "motd" Puppetfile > /dev/null ||
  cat >> Puppetfile << EOF
mod "motd",
  :git    => 'ssh://git@${PT_gitlab}:8022/root/control-repo.git',
  :branch => :control_branch
EOF

git config --global user.name "cd4pe admin"
git config --global user.email root\@"$(hostname -f)"
git add Puppetfile
git commit -m "Adding cd4pe module requirements"
git push origin production

cp Puppetfile ..

git checkout master
mv ../Puppetfile .
git add Puppetfile
git commit -m "Adding cd4pe module requirements"
git push origin master