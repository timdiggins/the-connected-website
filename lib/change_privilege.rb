base_dir = File.dirname(__FILE__)
require File.join(base_dir, 'etc_patch')

def change_privilege(user, group=user)
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

environment_stat = File.stat(File.join(base_dir, '..', 'config', 'environment.rb'))
user = Etc.username(environment_stat.uid)
group = Etc.groupname(environment_stat.gid)
change_privilege(user, group)
