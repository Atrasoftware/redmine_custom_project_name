require_dependency 'application_helper'

module  Patches
  module ApplicationHelperPatch
    def self.included(base)
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)
      base.class_eval do
        alias_method_chain :link_to_project, :identifier
        alias_method_chain :link_to_project_settings, :identifier
      end
    end

  end
  module ClassMethods
  end

  module InstanceMethods

    def link_to_project_with_identifier(project, options={}, html_options = nil)
      if project.archived?
        h(project.identifier)
      elsif options.key?(:action)
        ActiveSupport::Deprecation.warn "#link_to_project with :action option is deprecated and will be removed in Redmine 3.0."
        url = {:controller => 'projects', :action => 'show', :id => project}.merge(options)
        link_to project.identifier, url, html_options
      else
        link_to project.identifier, project_path(project, options), html_options
      end
    end

# Generates a link to a project settings if active
    def link_to_project_settings_with_identifier(project, options={}, html_options=nil)
      if project.active?
        link_to project.identifier, settings_project_path(project, options), html_options
      elsif project.archived?
        h(project.name)
      else
        link_to project.identifier, project_path(project, options), html_options
      end
    end


  end

end

