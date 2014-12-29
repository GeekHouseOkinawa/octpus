package 'sl'

package 'nginx'
service 'nginx' do
  action %i(start enable)
end

include_recipe 'oracle_jdk'
include_recipe 'minecraft'
include_recipe 'minecraft::overviewer'
include_recipe 'rbenv::system'
