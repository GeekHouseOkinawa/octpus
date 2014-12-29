package 'sl'

package 'nginx'
service 'nginx' do
  action %i(start enable)
end

include_recipe 'oracle_jdk'
include_recipe 'minecraft'
include_recipe 'minecraft::overviewer'
include_recipe 'rtn_rbenv::system'

execute 'install td-agent' do
  command 'curl -L http://toolbelt.treasuredata.com/sh/install-debian-squeeze-td-agent2.sh | sh'
  not_if 'cat /etc/apt/sources.list | grep http://packages.treasuredata.com/2/debian/squeeze/'
end

template '/opt/minecraft/crontab' do
  source 'crontab.erb'
  owner node[:minecraft][:user]
  group node[:minecraft][:user]
end

execute 'register minecraft overviewer' do
  command 'crontab /opt/minecraft/crontab'
  user    node[:minecraft][:user]
end

link '/usr/share/nginx/www/mcmap' do
  to '/opt/minecraft/mcmap'
end
