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
        h(project)
      elsif options.key?(:action)
        ActiveSupport::Deprecation.warn "#link_to_project with :action option is deprecated and will be removed in Redmine 3.0."
        url = {:controller => 'projects', :action => 'show', :id => project}.merge(options)
        link_to project, url, html_options
      else
        link_to project, project_path(project, options), html_options
      end
    end

# Generates a link to a project settings if active
    def link_to_project_settings_with_identifier(project, options={}, html_options=nil)
      if project.active?
        link_to project.identifier, settings_project_path(project, options), html_options
      elsif project.archived?
        h(project)
      else
        link_to project, project_path(project, options), html_options
      end
    end

    def get_sorted_cf(settings)
      sorting_options = settings[:sortable_position]
      cfs_sorted = Array.new
        cfs = CustomField.where(type: "ProjectCustomField")
        if sorting_options and sorting_options.present?
          sorting_options= sorting_options.split('|')
          sorting_options.each do |cf_id|
            cf = cfs.select{|c| "#{c.id}" == "#{cf_id}" }
            cfs_sorted<< cf
            cfs = cfs.reject{|c| "#{c.id}" == "#{cf_id}" }
          end
        end
        cfs.each do |cf|
          cfs_sorted<< cf
        end
        cfs_sorted.flatten!
      cfs_sorted
    end


  end

end

