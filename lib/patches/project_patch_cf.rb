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
      @settings = Setting.send "plugin_redmine_custom_project_name"
      output = ["#{identifier}"]
  if @settings.present?
      cfs= get_sorted_cf(@settings)
      puts "#{cfs}==================================8798"
      if cfs.present?
        cfs.select{|col| @settings[col.name] }.each do |cf|
          visible_custom_field_values.select{|coll| coll.custom_field.name == cf.name }.each do |custom_value|
            unless custom_value.value.blank?
              output<< custom_value.value
            end
          end
        end
      end
  end
      "[#{output.compact.join('/')}] name"
    end
  end

end


