require_dependency 'query'
module  Patches
  module QueryPatch
    def self.included(base)
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)
      base.class_eval do
        alias_method_chain :all_projects_values, :modif
      end
    end
  end




module ClassMethods
end

module InstanceMethods
  def all_projects_values_with_modif
    return @all_projects_values if @all_projects_values
    values = []
   #app_helper_get_sorted_cf = ApplicationHelper.get_sorted_cf(Setting.send "plugin_redmine_custom_project_name").map(&:name)
    Project.project_tree(all_projects) do |p, level|
      prefix = (level > 0 ? ('--' * level + ' ') : '')
=begin
    output = ["#{p.identifier}"]
    app_helper_get_sorted_cf.each do |cf|
      p.visible_custom_field_values.select{|coll| coll.custom_field.name == cf }.each do |custom_value|
        output<< custom_value.value unless custom_value.value.blank?
      end
     end
=end
      values << ["#{prefix}#{p.to_s}", p.id.to_s]
    end
    @all_projects_values = values
  end
end

end