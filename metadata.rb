name             'rackspace_database'
maintainer       'Rackspace, US Inc.'
maintainer_email 'rackspace-cookbooks@rackspace.com'
license          'Apache 2.0'
description      'Sets up the database master or slave'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '2.0.0'

recipe 'rackspace_database', 'Empty placeholder'
recipe 'rackspace_database::master', 'Creates application specific user and database'
recipe 'rackspace_database::snapshot', 'Locks tables and freezes XFS filesystem for replication, assumes EC2 + EBS'

depends 'rackspace_mysql', '>= 1.3.0'
depends 'rackspace_postgresql', '>= 1.0.0'

%w{ debian ubuntu centos redhat }.each do |os|
  supports os
end
