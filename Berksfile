def rackspace_cookbook(name, version = '>= 0.0.0', options = {})  
  cookbook(name, version, {
    git: "git@github.com:rackspace-cookbooks/#{name}.git",
    branch: "rackspace-rebuild"
  }.merge(options))
end 

site :opscode
metadata

group :integration do
  rackspace_cookbook 'mysql', '~> 5.0'
  rackspace_cookbook 'postgresql', '~> 4.0'
end
