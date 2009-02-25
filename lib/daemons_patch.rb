class Daemons::Application
  def change_privilege
    environment_stat = File.stat(File.join(File.dirname(__FILE__), '..', 'config', 'environment.rb'))
    user = Etc.username(environment_stat.uid)
    group = Etc.groupname(environment_stat.gid)
    CurrentProcess.change_privilege(user, group)
  end
end
