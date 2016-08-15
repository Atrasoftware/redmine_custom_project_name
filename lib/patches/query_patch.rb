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
    Project.project_tree(all_projects) do |p, level|
      prefix = (level > 0 ? ('--' * level + ' ') : '')
      values << ["#{prefix}#{p.to_s}", p.id.to_s]
    end
    @all_projects_values = values
  end
end

end