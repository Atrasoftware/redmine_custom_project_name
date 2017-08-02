require_dependency 'application_helper'

module  Patches
  module ApplicationHelperPatch
    def self.included(base)
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)
      base.class_eval do
        def self.get_sorted_cf(settings)
          sorting_options = settings[:sortable_position].split('|')
          cfs_sorted = Array.wrap(CustomField.where(type: "ProjectCustomField").where(id: sorting_options).order(sorting_options.map{|v| "id=#{v} ASC" }.join(', ')))
          cfs_sorted<< CustomField.where(type: "ProjectCustomField").where.not(id: sorting_options)
          cfs_sorted.flatten!
          cfs_sorted
        end

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
      else
        link_to project.name,
                project_url(project, {:only_path => true}.merge(options)),
                html_options
      end
    end

    # Generates a link to a project settings if active
    def link_to_project_settings_with_identifier(project, options={}, html_options=nil)
      if project.active?
        link_to "[#{project.identifier}] #{project.name}" , settings_project_path(project, options), html_options
      elsif project.archived?
        h(project)
      else
        link_to project, project_path(project, options), html_options
      end
    end

    def get_sorted_cf(settings)
      ApplicationHelper.get_sorted_cf(settings)
    end


  end

end

