require "active_record/base"
require "active_record/base_class_fix"


module ActiveRecord

  def self.entity(*_params)
    ::ActiveRecord::Entity
  end

  module Entity

    # NOTE: There seems to be an AR module that prevents this initializer from running if its included.
    def initialize(attrs = {})
      attribute_keys = attrs.keys.map(&:to_sym)
      extra_attribute_keys = attribute_keys - self.class.column_names.map(&:to_sym) - [:id]
      # Oddly, AR only names the first unknown attribute it sees.
      fail ActiveRecord::UnknownAttributeError.new(self, extra_attribute_keys.first) unless extra_attribute_keys.empty? || attrs[:ignore_extra_attributes]
    end

    def self.included(mod)
      mod.extend ActiveModel::Naming
      # mod.include Core
      mod.extend BaseClassFix
      # mod.include AttributeAssignment # Has `assign_attributes`.
      mod.include Attributes # Has `attribute`.
      # mod.include AttributeDecorators
      # mod.include AttributeMethods # Has `primary_key`, which requires a schema and a connection.
      # mod.include Integration
      # mod.include Validations
      # mod.include Timestamp
      # mod.include Associations
      # mod.include NestedAttributes

      def mod.reload_schema_from_cache
      end

      def mod.define_attribute_methods
      end

      def mod._default_attributes
        []
      end

      def mod.column_names
        attributes_to_define_after_schema_loads.keys
      end

    end

    def respond_to_missing?(_method_name, *_args)
      true
    end

    def method_missing(method_name, *args)
      puts "method called: #{method_name}(#{args})"
    end

  end

end
