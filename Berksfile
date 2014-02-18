def rackspace_cookbook(name, version = '>= 0.0.0', options = {})  
  cookbook(name, version, {
    git: "git@github.com:rackspace-cookbooks/#{name}.git",
  }.merge(options))
end 

site :opscode
metadata

group :integration do
  rackspace_cookbook 'rackspace_mysql', '~> 5.0'
  rackspace_cookbook 'rackspace_postgresql', '~> 4.0', branch: 'rackspace-rebuild'
end
