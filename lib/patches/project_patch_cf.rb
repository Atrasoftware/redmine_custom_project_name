require_dependency 'project'

module  Patches
  module ProjectPatchCf
    def self.included(base)
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)
      base.class_eval do
        alias_method_chain :to_s, :identifier_and_cf

        before_save :set_new_identifier_with_cfs
      end
    end

  end
  module ClassMethods
    def update_identifier_with_cfs
      projects = all
      projects.each do |pr|
        pr.save
      end
    end
  end

  module InstanceMethods
    def to_s_with_identifier_and_cf
      return identifier_with_cfs if identifier_with_cfs.presence
      project.identifier_with_cfs = identifier
      project.save
      project.reload
      project.identifier_with_cfs
    end

    def set_new_identifier_with_cfs
      settings = Setting.send "plugin_redmine_custom_project_name"
      output = ["#{identifier}"]
      if settings.present?
        cfs= ApplicationHelper.get_sorted_cf(settings)
        if cfs.present?
          cfs.select{|col| settings[col.name] }.each do |cf|
            visible_custom_field_values.select{|coll| coll.custom_field.name == cf.name }.each do |custom_value|
              unless custom_value.value.blank?
                output<< custom_value.value
              end
            end
          end
        end
      end
      self.identifier_with_cfs= "[#{output.compact.join('/')}] #{name}"
    end
  end

end
