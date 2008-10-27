def run_coverage(files)
  rm_f "coverage"
  rm_f "coverage.data"
  
  if files.empty?
    puts "No files were specified for testing"
    return
  end
  
  files = files.join(" ")
  exclude = (PLATFORM =~ /darwin/) ? '--exclude "gems/*"' : '--exclude "rubygems/*"'
  rcov = "rcov --rails -Ilib:test --sort coverage --text-report #{exclude} --no-validator-links"
  cmd = "#{rcov} #{files}"
  sh cmd
  `open coverage/index.html` if PLATFORM['darwin']
end

namespace :test do
  
  desc "Measures test coverage using rcov."
  task :coverage do
    run_coverage Dir["test/**/*.rb"]
  end
  
end