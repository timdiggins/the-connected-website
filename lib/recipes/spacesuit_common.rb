#adapted from https://github.com/ntalbott/spacesuit/blob/master/lib/spacesuit/recipes/common.rb

namespace :deploy do
  desc "Run migrations by default"
  task :default do
    transaction do
      update_code
      web.disable
      symlink
      migrate
    end
    restart
    web.enable
    cleanup
  end

  namespace :git do
    desc "Print out a nice report of what will be deployed."
    task :pending do
      deployed_already = ("#{current_revision}.." rescue '')
      to_be_deployed = `git rev-parse --short "HEAD"`.chomp

      message = <<EOM
##############################################

Deployment to #{stage.to_s.upcase} (#{to_be_deployed})
I deployed the latest. It includes:

#{%x{git log --no-merges --pretty=format:"* %s %b (%cn)" #{deployed_already} | sed 's/<unknown>//'}}

#{"http://#{domain}/" if domain}

##############################################
EOM
      puts message
      File.open('deploy_history.txt', 'a'){|f| f.write message}
    end
  end
end

def sudo_put(data, destination, temporary_area='/tmp', options={})
  temporary_area = File.join(temporary_area,"#{File.basename(destination)}") 
  put(data, temporary_area, options)
  sudo %(
    sh -c "install -m#{sprintf("%3o",options[:mode]||0755)} #{temporary_area} #{destination} &&
    rm -f #{temporary_area}"
  )
end  
