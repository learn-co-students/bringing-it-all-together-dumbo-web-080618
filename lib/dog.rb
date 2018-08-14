require 'pry'
class Dog

  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id:nil)
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
      DROP TABLE dogs
    SQL

    DB[:conn].execute(sql)
  end

  def save
     sql = <<-SQL
       INSERT INTO dogs (name, breed) VALUES (?, ?)
     SQL
    #
     DB[:conn].execute(sql, self.name, self.breed)

    id = <<-SQL
      SELECT * FROM dogs ORDER BY id DESC LIMIT 1
    SQL

    new_dog_array = DB[:conn].execute(id)
    new_dog_array_flattened = new_dog_array.flatten
    self.id = new_dog_array_flattened[0]
    self
  end

  def self.create(dog_hash)
    new_dog = Dog.new(dog_hash)
    new_dog.save
    new_dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE  id == ?
    SQL

    value = DB[:conn].execute(sql, id).flatten
    new_dog = Dog.new(name:value[1], breed:value[2], id:value[0])
  end

  def self.find_by_name(name)

    sql = <<-SQL
      SELECT * FROM dogs WHERE name == ?
    SQL

    value = DB[:conn].execute(sql, name).flatten
    new_dog = Dog.new(name:value[1], breed:value[2], id:value[0])

  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND BREED = ?", name, breed)

    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new(name:dog_data[1], breed:dog_data[2], id:dog_data[0])
    else
      dog = self.create(name: name, breed: breed)
    end

    dog
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL

#SQL does not have access to dog instance therefore we need to pass dog instance
#instance variable into DB.execute command  and use ? as a standin (replacement) for
#the value I will be passing in later

    DB[:conn].execute(sql, self.name, self.breed, self.id)

  end

  def self.new_from_db(row)
    Dog.new(name:row[1], breed:row[2], id:row[0])
  end

end
