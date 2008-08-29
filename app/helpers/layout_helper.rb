module LayoutHelper
  
  def flash_class
    return "" if flash.values.empty?
    %{class = "#{flash.keys.join(' ')}"}
  end
  
  def flash_value
    flash.values.collect { | value | "<p>#{value}</p>"}.join("\n")
  end
  
  def body_tag
    onload_str = @onload_event ? %{ onload="#{@onload_event}"} : ''
    "<body#{onload_str}>"
	end
	
	def current_if_tab_is(tab)
	  return '' unless tab == @current_tab
	  'class="current"'
  end
  
end
