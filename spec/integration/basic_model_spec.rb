require "pry"
require "active_support"
require "active_record"
require "active_record/entity"
require "active_record/repository"


# Whoa. I just learned about ":memory:" from https://blog.teamtreehouse.com/active-record-without-rails-app.
# TODO: Add that to my PRO TIPS.
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
connection_spec = ActiveRecord::ConnectionAdapters::ConnectionSpecification.new("primary", {adapter: "sqlite3", database: ":memory:"}, "sqlite3_connection")
ActiveRecord::ConnectionAdapters::ConnectionPool.new(connection_spec)

ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users, force: true do |t|
    t.string :name, nil: false
    t.date :date_of_birth, nil: false
    t.integer :ssn, nil: true
    t.boolean :active, nil: false
  end
end


class User
  include ActiveModel.entity(datestamps: true)
  attribute :name, :string
  attribute :date_of_birth, :date # Gives you a validation for free
  attribute :ssn, :integer #, required: false # , range: 000_00_0000..999_99_9999
  attribute :active, :boolean
  validates :ssn, numericality: { greater_than_or_equal_to: 000_00_0000, less_than_or_equal_to: 999_99_9999, allow_nil: true }
  # has_many :children
  # belongs_to :company
end

class Users
  include ActiveRecord.repostitory(model: User, table_name: "users")
  scope :active, -> { where(active: true) }
end

# class UsersWithMissingField
#   include ActiveRecord.repostitory(model: User, table_name: "users_with_missing_field")
#   scope :active, -> (){ where(active: true) }
# end


RSpec.describe ActiveModel::Entity do
  it "allows initializing with defined attributes" do
    expect {
      User.new(id: 1, name: "Craig", active: true, date_of_birth: Date.parse("1970-12-23"))
    }.not_to raise_exception
  end

  it "does NOT allow initializing with values for attributes that are not defined" do
    expect {
      User.new(id: 1, name: "Craig", active: true, date_of_birth: Date.parse("1970-12-23"), undefined_field: 123)
    }.to raise_exception(ActiveModel::UnknownAttributeError)
  end

  it "DOES allow initializing with values for attributes that are not defined, if we pass `ignore_extra_attributes: true`" do
    expect {
      User.new(id: 1, name: "Craig", active: true, date_of_birth: Date.parse("1970-12-23"), undefined_field: 123, ignore_extra_attributes: true)
    }.not_to raise_exception
  end

  it "allows updating attributes" do
    user = User.new(id: 1, name: "Craig", active: true, date_of_birth: Date.parse("1970-12-23"))
    expect {
      user.name = "Craig Buchek"
      expect(user.name).to eq("Craig Buchek")
      user.active = false
      expect(user.active).to eq(false)
      user.update(name: "Bob", active: true)
      expect(user.name).to eq("Bob")
      expect(user.active).to eq(true)
    }.not_to raise_exception
  end

  it "does NOT allow updating attributes that are not defined" do
    user = User.new(id: 1, name: "Craig", active: true, date_of_birth: Date.parse("1970-12-23"))
    expect {
      user.undefined_field = "nice try!"
    }.to raise_exception(NoMethodError)
    expect {
      user.update(undefined_field: "nice try!")
    }.to raise_exception(NoMethodError)
  end

  it "DOES allow updating attributes that are not defined, if we pass `ignore_extra_attributes: true`" do
    user = User.new(id: 1, name: "Craig", active: true, date_of_birth: Date.parse("1970-12-23"))
    expect {
      user.update(undefined_field: "nice try!", ignore_extra_attributes: true)
    }.not_to raise_exception
  end

  it "allows accessing 'has_many' relations"
  it "allows accessing 'belongs_to' relations"

  describe "validations" do

    it "requires setting all required attributes" do
      user = User.new(id: 1, active: true, date_of_birth: nil)
      expect(user).to_not be_valid
      user = User.new(id: 1, name: "Craig", active: true, date_of_birth: Date.parse("1970-12-23"), ssn: 123_45_6789)
      expect(user).to be_valid
    end

    it "allows specifying `validates`" do
      user = User.new(id: 1, name: "Craig", active: true, date_of_birth: Date.parse("1970-12-23"))
      user.update(ssn: 123_45_6789)
      expect(user).to be_valid
    end

    it "validates types" do
      user = User.new(id: 1, name: 12345, active: true, date_of_birth: "NOT A DATE", ssn: 123_45_6789)
      expect(user).not_to be_valid
      expect(user.errors[:date_of_birth]).to include("can't be blank")
    end

    it "allows `required: false` in `attribute` declaration"

    it "validates ranges specified in `attribute` declaration"

  end

end


RSpec.describe ActiveRecord::Repository do

  xit "errors out if the repostitory fields don't include all the model attributes" do
    expect {
      UsersWithMissingField.find(1)
    }.to raise_exception(ActiveRecord::UnknownAttributeError)
  end

  it "allows saving an entity" do
    expect {
      Users.save(id: 1, active: true, date_of_birth: Date.parse("1970-12-23"))
    }.not_to raise_exception
  end

  it "allows getting an entity by ID" do
    user = Users.find(1)
    expect(user).to be_a(User)
  end

  it "allows getting entities by scope" do
    active_users = Users.active
    expect(active_users.methods).to include(:each)
    expect(active_users.length).to be(1)
    # expect(active_users.first).to be(user1)
  end

  xit "does not allow directly accessing collections that should be accessed via scopes" do
    expect {
      Users.where(active: true)
    }.to raise_exception(NoMethodError)
  end
end
