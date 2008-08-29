require 'yaml'

# require 'rubygems'
# require 'ruby-debug'
# debugger

APPLICATION="republic"
INTERVAL=5.seconds

mongrel_cluster_file = "/etc/mongrel_cluster/#{APPLICATION}.yml"
mongrel_cluster = YAML::load_file(mongrel_cluster_file)
starting_port = mongrel_cluster['port']
number_of_servers = mongrel_cluster['servers']
mongrel_ports = (starting_port...(starting_port+number_of_servers)).to_a
RAILS_ROOT = mongrel_cluster['cwd'] || "/var/www/apps/#{APPLICATION}/current"

mongrel_ports = ['8004']
mongrel_ports.each do |port|
  God.watch do |w|
    w.name = "#{APPLICATION}-mongrel-#{port}"
    w.interval = INTERVAL
    w.start = "mongrel_rails cluster::start -C #{mongrel_cluster_file} --clean --only #{port}"
    w.stop = "mongrel_rails cluster::stop -C #{mongrel_cluster_file} --clean --only #{port}"
    w.pid_file = mongrel_cluster['pid_file'] || File.join(RAILS_ROOT, "tmp/pids/mongrel.#{port}.pid")
    w.behavior(:clean_pid_file)
    w.group = "#{APPLICATION}-mongrels"
    
    w.start_if do |start|
      start.condition(:process_running) do |c|
        c.interval = INTERVAL
        c.running = false
      end
    end

    w.restart_if do |restart|
      restart.condition(:memory_usage) do |c|
        c.above = 150.megabytes
        c.times = [3, 5] # 3 out of 5 intervals
      end

      restart.condition(:cpu_usage) do |c|
        c.above = 50.percent
        c.times = 5
      end
    end

    # lifecycle
    w.lifecycle do |on|
      on.condition(:flapping) do |c|
        c.to_state = [:start, :restart]
        c.times = 5
        c.within = 5.minute
        c.transition = :unmonitored
        c.retry_in = 10.minutes
        c.retry_times = 5
        c.retry_within = 2.hours
      end
    end
  end
end