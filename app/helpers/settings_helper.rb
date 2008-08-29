module SettingsHelper
  
  def current_if_context_is(settings_context)
	  return '' unless settings_context == params[:action].to_sym
	  'class="current"'
  end
	
end
