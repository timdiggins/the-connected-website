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
end