require_dependency 'application_helper'

module  Patches
  module ApplicationHelperPatch
    def self.included(base)
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)
      base.class_eval do
        def self.get_sorted_cf(settings)
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
        alias_method_chain :link_to_project, :identifier
        alias_method_chain :link_to_project_settings, :identifier
        alias_method_chain :render_project_jump_box, :new_select if Redmine::VERSION.to_s.start_with?("3.")
      end
    end


  end
  module ClassMethods
  end

  module InstanceMethods
    def render_project_jump_box_with_new_select
      return unless User.current.logged?
      projects = User.current.projects.active.select(:id, :name, :identifier, :lft, :rgt, :identifier_with_cfs, :parent_id).to_a
      if projects.any?
        options =
            ("<option value=''>#{ l(:label_jump_to_a_project) }</option>" +
                '<option value="" disabled="disabled">---</option>').html_safe

        options << project_tree_options_for_select(projects, :selected => @project) do |p|
          { :value => project_path(:id => p, :jump => current_menu_item) }
        end

        select_tag('project_quick_jump_box', options, :onchange => 'if (this.value != \'\') { window.location = this.value; }')
      end
    end

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

