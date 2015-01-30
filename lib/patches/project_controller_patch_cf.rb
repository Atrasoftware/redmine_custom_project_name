require_dependency 'projects_controller'

module  Patches
  module ProjectControllerPatchCf
    def self.included(base)
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)
      base.class_eval do
        append_after_filter :add_identifier_and_cf, :only=> [:update]
      end
    end

  end
  module ClassMethods

  end

  module InstanceMethods
    def add_identifier_and_cf
      Project.identifier_with_cf(@project)
    end
  end

end


