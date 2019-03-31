require "active_record/base"


module ActiveRecord

  # We have to override Inheritance.ClassMethods.base_class, because we don't directly subclass from ActiveRecord::Base.
  module BaseClassFix
    def self.extended(mod)
      define_method :base_class, -> { mod }
      mod.class.__send__(:define_method, :abstract_class?, -> { false })
      def connection_specification_name
        "primary" # FIXME: This should be the default, but should be overridable, like normal ActiveRecord.
      end
      def connection
        ActiveRecord::Base.connection
      end
    end
  end

end
