require "active_record/base"
require "active_record/base_class_fix"


module ActiveRecord

  def self.repostitory(model: nil, table_name: nil)
    ::ActiveRecord::Repository
  end

  module Repository

    def self.included(mod)
      mod.extend ActiveModel::Naming
      mod.extend ActiveSupport::Benchmarkable
      mod.extend ActiveSupport::DescendantsTracker
      mod.extend ConnectionHandling
      mod.extend QueryCache::ClassMethods
      mod.extend Querying
      mod.extend Translation
      mod.extend DynamicMatchers
      mod.extend Explain
      mod.extend Enum
      mod.extend Delegation::DelegateCache
      mod.extend CollectionCacheKey
      mod.include Core
      mod.include Persistence
      mod.include ReadonlyAttributes
      mod.include ModelSchema
      mod.include Inheritance
      mod.extend BaseClassFix
      mod.include Scoping
      mod.include Sanitization
      mod.include AttributeAssignment
      mod.include ActiveModel::Conversion
      mod.include Integration
      # mod.include Validations
      mod.include CounterCache
      mod.include Attributes
      mod.include AttributeDecorators
      mod.include Locking::Optimistic
      mod.include Locking::Pessimistic
      mod.include DefineCallbacks
      mod.include AttributeMethods
      # mod.include Callbacks
      mod.include Timestamp
      mod.include Associations
      mod.include ActiveModel::SecurePassword
      mod.include AutosaveAssociation
      # mod.include NestedAttributes
      mod.include Aggregations
      mod.include Transactions
      # mod.include TouchLater
      # mod.include NoTouching
      mod.include Reflection
      mod.include Serialization
      mod.include Store
      mod.include SecureToken
      mod.include Suppressor

      # mod.initialize_generated_modules # AttributeMethods
      mod.initialize_relation_delegate_cache # Delegation::DelegateCache
      mod.initialize_find_by_cache # Core
      mod.__send__(:initialize_load_schema_monitor) # ModelSchema


      # NOTE: Requires AttributeMethods.
      def mod.save(entity)
        new(entity.to_h).save
      end

      # NOTE: Requires AttributeMethods.
      def mod.save!(entity)
        new(entity.to_h).save!
      end

      # NOTE: These should probably be private.

      def mod.where(*args, **kwargs, &block)
        # TODO: Need to make this an Arel relation, not an Array.
        super.map{ |x| User.new(x.attributes) }
      end

      def mod.find(id)
        where(id: id).first
      end
    end

  end

end
