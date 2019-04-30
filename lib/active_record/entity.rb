require "active_record/base"
require "active_record/base_class_fix"


module ActiveModel

  def self.entity(datestamps: true)
    modules = [::ActiveModel::Entity]
    modules << ::ActiveModel::Entity::DateStamps if datestamps
    composite_module(modules)
  end

  def self.composite_module(modules)
    Module.new.tap { |composite_module|
      composite_module.define_singleton_method(:included) do |entity_module|
        modules.each do |mod|
          entity_module.__send__(:include, mod)
        end
      end
    }
  end

  module Entity

    def self.included(mod)
      mod.extend ActiveModel::Model # Includes AttributeAssignment, Validations, Conversion, Naming, Translation.
      mod.include ActiveModel::AttributeMethods
      mod.include ActiveModel::Attributes
      mod.include ActiveModel::Validations
      # mod.include ActiveSupport::Callbacks
      # mod.include AttributeAssignment # Has `assign_attributes`.
      # mod.include Attributes # Has `attribute`.
      # mod.include AttributeDecorators
      # mod.include AttributeMethods # Has `primary_key`, which requires a schema and a connection. Requires `Core.initialize_generated_modules`.
      # mod.include Core
      # mod.include Transactions # Requires active_model/callbacks
      # mod.include Integration
      # mod.include Validations
      # mod.include Timestamp
      # mod.include Associations
      # mod.include NestedAttributes

      # def mod._default_attributes
      #   []
      # end

      # def mod.column_names
      #   attributes_to_define_after_schema_loads.keys
      # end

      mod.define_attribute_methods(mod.attribute_types.keys.map(&:to_sym))

      def mod.attribute(name, type, options = {})
        super(name, type)
        validates name, presence: true if options.fetch(:required){ true }
      end

    end

    def initialize(attrs = {})
      attribute_keys = attrs.keys.map(&:to_sym)
      allowed_attributes = self.class.attribute_types.keys.map(&:to_sym)
      extra_attribute_keys = attribute_keys - allowed_attributes - [:id]
      # Oddly, AR only names the first unknown attribute it sees.
      fail ActiveRecord::UnknownAttributeError.new(self, extra_attribute_keys.first) unless extra_attribute_keys.empty? || attrs[:ignore_extra_attributes]
      attrs = attrs.reject{ |k, _v| extra_attribute_keys.include?(k.to_sym) }
      update()
      @attributes = ActiveModel::AttributeSet.new(allowed_attributes.map{ |k, _v| [k.to_s, ActiveModel::Attribute.from_user(k.to_sym, attrs.fetch(k.to_sym, nil), self.class.attribute_types[k.to_s], attrs.fetch(k.to_sym, nil))] }.to_h)
    end

    def update(attrs = {})
      attrs.each do |k,v|
        if attrs[:ignore_extra_attributes]
          begin
            self.__send__("#{k}=".to_sym, v)
          rescue NoMethodError
            nil
          end
        else
          self.__send__("#{k}=".to_sym, v)
        end
      end
    end

    # NOTE: These are for troubleshooting only. They cause some tests to fail.
    # def respond_to_missing?(_method_name, *_args)
    #   true
    # end
    # def method_missing(method_name, *args)
    #   puts "method called: #{method_name}(#{args})"
    # end

    module DateStamps
    end

  end

end
