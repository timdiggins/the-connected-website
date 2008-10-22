module TinyMCEValidator

  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    def validates_tiny_mce_presence_of(*attr_names)
      configuration = { :message => I18n.translate('activerecord.errors.messages')[:blank], :on => :save }
      configuration.update(attr_names.extract_options!)

      send(validation_method(configuration[:on]), configuration) do |record|
        for attr in [attr_names].flatten
          value = record.respond_to?(attr.to_s) ? record.send(attr.to_s) : record[attr.to_s]
          sanitized = HTML::FullSanitizer.new.sanitize(value)
          record.errors.add(attr, configuration[:message]) if sanitized.nil? || sanitized.gsub(/&nbsp;/,'').strip.blank?
        end
      end
    end
  end
end
