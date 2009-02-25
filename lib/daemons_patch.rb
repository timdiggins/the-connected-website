# Optionally specify the logdir seperately from the piddir
class Daemons::Application
  def logdir
    logdir = options[:log_dir]
    unless logdir
      logdir = options[:dir_mode] == :system ? '/var/log' : pidfile_dir
    end
    logdir
  end

  def output_logfile
    (options[:log_output] && logdir) ? File.join(logdir, @group.app_name + '.output') : nil
  end

  def logfile
    logdir ? File.join(logdir, @group.app_name + '.log') : nil
  end
end

require File.join(File.dirname(__FILE__), 'change_privilege')
class Daemons::Application
  alias :old_initialize :initialize 
  class_eval %{
    def initialize(*args, &block)
      old_initialize(*args, &block)
      change_privilege
    end
  }

  def change_privilege
    environment_stat = File.stat(File.join(File.dirname(__FILE__), '..', 'config', 'environment.rb'))
    user = Etc.username(environment_stat.uid)
    group = Etc.groupname(environment_stat.gid)
    CurrentProcess.change_privilege(user, group)
  end
end
