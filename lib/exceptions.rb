module Exceptions
  
  class PermissionDenied < StandardError
  end
  
  class DownloadedImageTooSmall < StandardError
  end
  
  class DownloadError < StandardError
  end
  
  class BadFlickrApiUsage < StandardError
  end
  
  class FlickrApiFailure < StandardError
  end
  
end