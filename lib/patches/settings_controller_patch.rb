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
          setting = params[:settings] ? params[:settings].permit!.to_h : {}
          Setting.send "plugin_#{@plugin.id}=", setting
          Thread.new do
            Project.all.each do |project|
              project.save
            end
            ActiveRecord::Base.connection.close
          end

        end
      end
    end
  end

end