require 'pry'

class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
    SQL

    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?,?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)

    sql_dog = <<-SQL
      SELECT * FROM dogs ORDER BY id DESC LIMIT 1
    SQL

    dog = DB[:conn].execute(sql_dog)[0]


    self.id = dog[0]
    self
  end

  def self.create(hash)
    new_dog = Dog.new(name: hash[:name], breed: hash[:breed])
    new_dog.save

  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL

    dog = DB[:conn].execute(sql,id)[0]
    temp = Dog.new(name: dog[1], breed: dog[2])
    temp.id = dog[0]
    temp
    # binding.pry
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?
    SQL
    dog = nil
    dogs_found = DB[:conn].execute(sql, name, breed)[0]

    if (dogs_found == nil)
      dog = Dog.create(name: name, breed: breed)
    else
      dog = Dog.find_by_id(dogs_found[0])
    end
    dog
  end

  # row = [1, "Pat", "poodle"]
  # pat = Dog.new_from_db(row)
  def self.new_from_db(args)
    dog = Dog.new(name: args[1],breed: args[2])
    dog.id = args[0]
    dog
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
    SQL
    dog_arr = DB[:conn].execute(sql, name)[0]
    dog = Dog.new(name: dog_arr[1], breed: dog_arr[2])
    dog.id = dog_arr[0]
    dog
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
