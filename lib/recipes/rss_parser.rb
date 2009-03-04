before "deploy:setup", "rss_parser:install"

namespace :rss_parser do
  task :install do
    cmds = []
    cmds << "wget http://www.cozmixng.org/~kou/download/rss.tar.gz"
    cmds << "tar -zxf rss.tar.gz"
    cmds << "cd rss*"
    cmds << "sudo ruby setup.rb"
    cmds << "rm -rf rss*"
    run cmds.join(" && ")
  end
end