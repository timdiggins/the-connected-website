ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")

$: << File.expand_path(File.dirname(__FILE__) + "/integration/dsl")
require 'basics_dsl'
require 'republic_dsl'
require 'test_help'

SAMPLE_IMAGES_DIR = File.expand_path(File.dirname(__FILE__) + "/unit/sample_images")
SAMPLE_IMAGE = "#{SAMPLE_IMAGES_DIR}/samplejpg.jpg"
SAMPLE_TOO_SMALL_IMAGE = "#{SAMPLE_IMAGES_DIR}/too_small.gif"
PUBLIC_DIR = File.expand_path(File.dirname(__FILE__) + "/../public")
DOWNLOADED_IMAGES_DIR = "#{PUBLIC_DIR}/downloaded_images"
TEST_DOWNLOADED_IMAGES_DIR = "#{PUBLIC_DIR}/test_downloaded_images"

class Test::Unit::TestCase
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
  
  fixtures :all
  
  def image_downloader_setup
    assert File.exists?(PUBLIC_DIR), "expected #{PUBLIC_DIR} to exist"
    if !File.exists?(DOWNLOADED_IMAGES_DIR)
      @previous_downloaded_images_dir = nil
    else
      @previous_downloaded_images_dir = "#{PUBLIC_DIR}/previous_downloaded_images"
      raise "Won't overwrite #@previous_downloaded_images_dir" if File.exists?(@previous_downloaded_images_dir)
      File.move(DOWNLOADED_IMAGES_DIR, @previous_downloaded_images_dir)
    end
  end
  def image_downloader_teardown
    FileUtils.mkdir(TEST_DOWNLOADED_IMAGES_DIR) if !File.exists?(TEST_DOWNLOADED_IMAGES_DIR)
    if File.exists?(DOWNLOADED_IMAGES_DIR)
      FileUtils.cp_r("#{DOWNLOADED_IMAGES_DIR}/.", TEST_DOWNLOADED_IMAGES_DIR) 
      FileUtils.remove_dir(DOWNLOADED_IMAGES_DIR)
    end
    if !@previous_downloaded_images_dir.nil?
      File.move(@previous_downloaded_images_dir, DOWNLOADED_IMAGES_DIR)
    end
  end
end

class TestUtil
  def self.recalculate_counters
    Post.reset_column_information
    Post.find(:all).each do |p|
      Post.update_counters p.id, :post_images_count => p.images.length
    end
  end
end

class ActionController::IntegrationTest
  
  def new_session(&block) 
    open_session do | session | 
      session.extend(BasicsDsl)
      session.extend(RepublicDsl)
      session.host!("website.dev")
      session.instance_eval(&block) if block
      session
    end 
  end 
  
  def new_session_as(user_symbol, &block)
    session = new_session
    session.login(user_symbol)
    session.instance_eval(&block) if block
    session
  end 
  
  def logger
    Rails.logger
  end
  
end


module ActionController
  module Integration
    module Runner
      def reset!
        @integration_session = new_session
      end
    end
  end
end
