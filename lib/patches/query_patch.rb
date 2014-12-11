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
    @settings = Setting.send "plugin_redmine_enhanced_projects_list"
    if @settings[:sorting_projects_order] == 'true'
      order_desc = true
    else
      order_desc = false
    end
    Project.project_tree_with_order(all_projects,order_desc) do |p, level|
      prefix = (level > 0 ? ('--' * level + ' ') : '')
      output = ["#{p.identifier}"]
      #
      get_sorted_cf(@settings).each do |cf|
        p.visible_custom_field_values.select{|coll| coll.custom_field.name == cf.name }.each do |custom_value|
           unless custom_value.value.blank?
              output<< custom_value.value
           end
         end
       end
      values << ["#{prefix}#{p}", p.id.to_s]
    end
    @all_projects_values = values
  end
end

end