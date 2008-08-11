task :cadillac_edge do
  require 'vendor/plugins/cadillac_edge_deploy/lib/cadillac_edge_deploy'
  CadillacEdgeDeploy.new.deploy("eb4668b26ad4aacf79488d2bee553e9452971c35", nil, File.join(ENV['HOME'], 'dev'))
end