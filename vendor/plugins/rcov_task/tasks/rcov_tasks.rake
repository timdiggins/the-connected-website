namespace :test do
  desc 'Measures test coverage'
  task :coverage do
    mkdir 'doc/coverage' unless File.exists? 'doc/coverage'
    Dir.glob('doc/coverage/*').each { |file| remove_file file }
    system "rcov --rails --text-summary -Ilib -x gem,TextMate --html -o doc/coverage test/**/*_test.rb"
    system "open doc/coverage/index.html" if PLATFORM['darwin']
  end
end