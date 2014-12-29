package 'sl'

package 'nginx'
service 'nginx' do
  action %i(start enable)
end

include_recipe 'oracle_jdk'
include_recipe 'minecraft'
include_recipe 'minecraft::overviewer'
include_recipe 'rtn_rbenv::system'

package 'curl'
execute 'install td-agent' do
  command 'curl -L http://toolbelt.treasuredata.com/sh/install-debian-squeeze-td-agent2.sh | sh'
  not_if 'test -f /etc/apt/sources.list.d/treasure-data.list'
end

execute 'install romankana' do
  command 'td-agent-gem install romankana'
  not_if 'td-agent-gem list | grep romankana'
end

execute 'install fluent-plugin-idobata' do
  command 'td-agent-gem install fluent-plugin-idobata'
  not_if 'td-agent-gem list | grep fluent-plugin-idobata'
end

execute 'install fluent-plugin-record-reformer' do
  command 'td-agent-gem install fluent-plugin-record-reformer'
  not_if 'td-agent-gem list | grep fluent-plugin-record-reformer'
end

directory '/opt/minecraft/td-agent/words/lib' do
  owner node[:minecraft][:user]
  group node[:minecraft][:user]
end

remote_file '/opt/minecraft/td-agent/words/lib/words.rb' do
  owner node[:minecraft][:user]
  group node[:minecraft][:user]
  source 'words.rb'
end

file '/etc/default/td-agent' do
  owner 'td-agent'
  group 'td-agent'
  content <<SCRIPT
DAEMON_ARGS="-vv -I /opt/minecraft/td-agent/words/lib -r romankana -r words"
SCRIPT
end

template '/etc/td-agent/td-agent.conf' do
  source 'td-agent.conf.erb'
  owner 'td-agent'
  group 'td-agent'
  variables(idobata_hook_url: ENV['IDOBATA_HOOK_URL'])
end

service 'td-agent' do
  action %i(start enable)
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
