require File.join(File.dirname(__FILE__), 'etc_patch')

class CurrentProcess
  def self.change_privilege(user, group=user)
    puts ">> Changing process privilege to #{user}:#{group}"
  
    uid, gid = Process.euid, Process.egid
    target_uid = Etc.getpwnam(user).uid
    target_gid = Etc.getgrnam(group).gid

    if uid != target_uid || gid != target_gid
      # Change process ownership
      Process.initgroups(user, target_gid)
      Process::GID.change_privilege(target_gid)
      Process::UID.change_privilege(target_uid)
    end
  rescue Errno::EPERM => e
    raise "Couldn't change user and group to #{user}:#{group}: #{e}"
  end
end