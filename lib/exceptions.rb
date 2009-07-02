module Exceptions
  
  class PermissionDenied < StandardError
    # ok
  end
  
  class DownloadedImageTooSmall < StandardError
    #ok
  end
  class DownloadError < StandardError
    #ok
  end
  
  class BadFlickrApiUsage < StandardError
    
  end
  class FlickrApiFailure < StandardError
    
  end
end