module ActionView
  module Helpers 
    module AssetTagHelper

      def compute_public_path_with_integration_testing_support(source, dir, ext=nil, include_host=true)
        result = compute_public_path_without_integration_testing_support(source, dir, ext, include_host)
        Rails.env == 'test' ? result[1..-1] : result
      end
      alias_method_chain(:compute_public_path, :integration_testing_support)
      
    end   
  end
end