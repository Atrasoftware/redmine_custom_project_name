require_dependency 'project'

module  Patches
  module ProjectPatchCf
    def self.included(base)
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)
      base.class_eval do
        alias_method_chain :to_s, :identifier_and_cf
      end
    end

  end
  module ClassMethods
  end

  module InstanceMethods
    def to_s_with_identifier_and_cf
      identifier
      @settings = Setting.send "plugin_redmine_enhanced_projects_list"
      output = ["#{identifier}"]
      CustomField.where(:type=> "ProjectCustomField").order("name ASC").select{|col| @settings[col.name] }.each do |cf|
        visible_custom_field_values.select{|coll| coll.custom_field.name == cf.name }.each do |custom_value|
          unless custom_value.value.blank?
            output<< custom_value.value
          end
        end
      end
      "[#{output.compact.join('/')}] name"
    end
  end

end


