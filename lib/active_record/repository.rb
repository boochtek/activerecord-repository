require "active_record/base"
require "active_record/base_class_fix"


module ActiveRecord

  def self.repository(model: nil, table_name: nil)
    ::ActiveRecord::Repository
  end

  module Repository

    MODULES_EXTENDED = [
      ActiveModel::Naming,
      ActiveSupport::Benchmarkable,
      ActiveSupport::DescendantsTracker,
      ConnectionHandling,
      QueryCache::ClassMethods,
      Querying,
      Translation,
      DynamicMatchers,
      Explain,
      Enum,
      Delegation::DelegateCache,
      CollectionCacheKey,
    ]

    MODULES_INCLUDED_FIRST = [
      Core,
      Persistence,
      ReadonlyAttributes,
      ModelSchema,
      Inheritance,
    ]

    MODULES_INCLUDED = [
      Core,
      Persistence,
      ReadonlyAttributes,
      ModelSchema,
      Inheritance,
      Scoping,
      Sanitization,
      AttributeAssignment,
      ActiveModel::Conversion,
      Integration,
      CounterCache,
      Attributes,
      AttributeDecorators,
      Locking::Optimistic,
      Locking::Pessimistic,
      DefineCallbacks,
      AttributeMethods,
      Timestamp,
      Associations,
      ActiveModel::SecurePassword,
      AutosaveAssociation,
      Aggregations,
      Transactions,
      Reflection,
      Serialization,
      Store,
      SecureToken,
      Suppressor,
      # Validations,
      # Callbacks,
      # NestedAttributes,
      # TouchLater,
      # NoTouching,
    ]

    def self.included(mod)
      MODULES_EXTENDED.each do |m|
        mod.extend(m)
      end

      MODULES_INCLUDED_FIRST.each do |m|
        mod.include(m)
      end

      # Unfortunately, this has to go between some of the inclusions.
      mod.extend(BaseClassFix)

      MODULES_INCLUDED.each do |m|
        mod.include(m)
      end

      # mod.initialize_generated_modules # AttributeMethods
      mod.initialize_relation_delegate_cache # Delegation::DelegateCache
      mod.initialize_find_by_cache # Core
      mod.__send__(:initialize_load_schema_monitor) # ModelSchema

      # TODO: Make this more robust. Allow passing table_name as module parameter.
      mod.table_name = mod.name.split("::").first.tableize

      class << mod

        # NOTE: Requires AttributeMethods.
        def save(entity)
          raise ArgumentError unless entity.is_a? ActiveModel::Entity

          mirror_object = new(entity.attributes.transform_keys(&:to_sym))
          mirror_object.save
          entity.id = mirror_object.id
        end

        # NOTE: Requires AttributeMethods.
        def save!(entity)
          mirror_object = new(entity.attributes.transform_keys(&:to_sym))
          mirror_object.save!
          entity.id = mirror_object.id
        end

        # NOTE: These should probably be protected.

        def where(*args, **kwargs, &block)
          # TODO: Make this more robust. Allow passing model's class as module parameter.
          model_class = name.split("::").first.constantize
          super.map{ |x| model_class.new(x.attributes.transform_keys(&:to_sym)) }
        end

        def find(id)
          where(id: id).first
        end

        # Don't let anyone new up a Repository themselves.
        private :new

      end

    end

  end

end
