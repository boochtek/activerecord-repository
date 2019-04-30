ActiveRecord Repository
=======================

This is an implementation of the repository pattern for ActiveRecord.
Using this allows splitting the domain model and persistence classes.


WARNING: This is currently merely a proof of concept.


TODO
----

* Loading
    * Loading relations
        * Avoiding N+1 queries
* Saving
    * Saving relations
* Entity#persisted?
    * Otherwise URLs created by Rails won't have the object's ID
    * Just define `persisted?` as `id.present?`
        * Have Repository.save update the item to add/update the `id` field
* Probably need to restrict other calls to Repository
    * `User::Repository.create`
* Entity#initialize and #update should basically be the same
    * Maybe the only difference is that initialize will set things to `nil`
* Relations between entities
    * belongs_to
    * has_many
    * has_one
    * has_many through:
    * Cascading deletions
* Entity#changed?
* Identity mapping
* Use module builder pattern in ActiveModel.entity
    * Add more options
* Use module factory (and module builder) pattern in ActiveRecord.repository
    * Add options
        * Setting entity class
        * Setting table_name
        * Setting a different primary key than `id`
        * Maybe define indexes
* More validations
