require "active_record/base"


module ActiveRecord

  # We have to override Inheritance.ClassMethods.base_class, because we don't directly subclass from ActiveRecord::Base.
  module BaseClassFix
    def base_class
      self
    end

    def self.extended(mod)
      mod.class.class_eval {
        def abstract_class?
          false
        end
      }

      def connection_specification_name
        "primary" # FIXME: This should be the default, but should be overridable, like normal ActiveRecord.
      end

      def connection
        ActiveRecord::Base.connection
      end
    end
  end

end
