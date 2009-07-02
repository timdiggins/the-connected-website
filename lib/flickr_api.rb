require 'nokogiri'
require 'open-uri'

class FlickrApi
  include Exceptions
  def initialize config_file=nil
    config_file = "#{RAILS_ROOT}/config/flickr.yml" if config_file.nil?
    yaml = YAML.load_file(config_file)
    @api_key = yaml['key']
    @secret = yaml['secret']
  end
  
  
  def call(options)
    unless options.has_key? :method
      raise BadFlickrApiUsage.new('Needs method ')
    end
    options[:api_key]=@api_key
    qs = []
    options.keys.each { |key| qs << "#{key}=#{options[key]}"}
    url = "http://api.flickr.com/services/rest/?#{qs.join('&')}"
    open(url) do |response|
      doc = Nokogiri::XML(response)
      rsp = doc.xpath('/rsp')[0]
#      p "resp: #{rsp}"
      stat = rsp['stat']
#      p "stat: #{stat}"
      raise FlickrApiFailure.new('some problem') unless stat == 'ok'
      yield rsp
    end
  end
  
  def flickr_images_sizes_fromurl url
    photo_id, photo_secret = flickr_photo_id_and_secret_fromurl(url)
    return [] if photo_id.nil?
    flickr_image_sizes(photo_id, photo_secret)
  end

  def flickr_photo_id_and_secret_fromurl url
    m = /http:\/\/farm[^\/.]+.static.flickr.com\/[^\/]+\/([^_\/]+)_([^_\/]+)(?:_[mstb])?.jpg/.match(url)
    return [nil, nil] if m.nil?
    return m.captures[0], m.captures[1]
  end
  
  def flickr_image_sizes(photo_id, photo_secret)
    call(:method=>"flickr.photos.getSizes", :photo_id=>photo_id, :secret=>photo_secret) do |rsp|
      sizes = rsp.xpath("./sizes/size").collect { |size_node| FlickrImageSize.new(size_node)}
      sizes.sort!.reverse!
    end
    
  end
end

class FlickrImageSize
  attr_reader :width, :label, :source
  def initialize(node)
    @width = node["width"].to_i
    @label = node["label"]
    @source = node["source"]
    @url = node["url"]
  end
  
  def <=> other
    return self.width <=> other.width
  end
end