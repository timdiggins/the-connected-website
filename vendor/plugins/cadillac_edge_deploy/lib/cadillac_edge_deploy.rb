require 'fileutils'

class CadillacEdgeDeploy
  include FileUtils
  
  def deploy(rails_revision, release_path) 
    shared_path  = File.expand_path(File.join(release_path, '../../shared'))
    @rails_path = File.join(shared_path, 'rails')

    @rails_revision = rails_revision
    @clone_path = File.join(@rails_path, 'master')
    @export_name = "rev_#{@rails_revision}"
    @export_path = File.join(@rails_path, @export_name)

    clone_rails
    clone_revision
    link_export
  end
  
  
  private
    def clone_rails
      unless File.exists?(@clone_path)
        puts 'cloning rails master'    
        system "git clone git://github.com/rails/rails.git #{@clone_path}"
      end
    end
    
    def clone_revision
      unless File.exists?(@export_path)
        puts "setting up rails rev #{@rails_revision}"
        system "cd #{@clone_path}; git pull"
        system "cd #{@rails_path}; git clone -q master #{@export_name}"
        system "cd #{@export_path}; git reset --hard #{@rails_revision}"
      end
    end

    def link_export
      symlink_path  = 'vendor/rails'
      puts 'linking rails'
      rm_rf   symlink_path

      ln_s File.expand_path(@export_path), symlink_path
      touch "vendor/rails_revision_#{@rails_revision}"
    end
    
end

if ($0 == __FILE__)
  CadillacEdgeDeploy.new.deploy(*ARGV)
end