require_dependency 'settings_controller'

module  Patches
  module SettingsControllerPatch
    def self.included(base)
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)
      base.class_eval do
        prepend_before_filter :set_identifier_with_cfs, :only=>[:plugin]
      end
    end

  end
  module ClassMethods

  end

  module InstanceMethods
    def set_identifier_with_cfs
      if request.post?
        @plugin = Redmine::Plugin.find(params[:id])
        if @plugin.id.to_s == 'redmine_custom_project_name'
          projects = Project.all
          settings = params[:settings]
          projects.each do |pr|
            output = ["#{pr.identifier}"]
            if settings.present?
              cfs= ApplicationHelper.get_sorted_cf(settings)
              if cfs.present?
                cfs.select{|col| settings[col.name] }.each do |cf|
                  pr.visible_custom_field_values.select{|coll| coll.custom_field.name == cf.name }.each do |custom_value|
                    unless custom_value.value.blank?
                      output<< custom_value.value
                    end
                  end
                end
              end
            end
            pr.identifier_with_cfs = "[#{output.compact.join('/')}] #{pr.name}"
            pr.save
          end
        end
      end
    end
  end

end