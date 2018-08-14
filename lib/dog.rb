require "pry"

class Dog

  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id:nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT);
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs;
    SQL

    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name,breed) VALUES (?,?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)

    sql_2 = <<-SQL
      SELECT * FROM dogs ORDER BY id DESC LIMIT 1;
    SQL

    new_dog_hash = DB[:conn].execute(sql_2)
    # binding.pry
    self.id = new_dog_hash[0][0]
    # binding.pry
    return self
  end

  def self.create(dog_hash)
    new_dog = Dog.new(dog_hash)
    new_dog.save
    new_dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL

    dog_array = DB[:conn].execute(sql, id)
    dog_id = dog_array[0][0]
    dog_name = dog_array[0][1]
    dog_breed = dog_array[0][2]
    Dog.new(id:dog_id, name:dog_name, breed:dog_breed)
  end

  def self.find_or_create_by(hash)

    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed=?
    SQL

    dog_array = DB[:conn].execute(sql, hash[:name], hash[:breed]).flatten

    if dog_array[0] == nil
      new_dog = Dog.new(hash)
      new_dog.save
    else
      Dog.new_from_db(dog_array)
    end
  end

  def self.new_from_db(dog_array)
    dog_id = dog_array[0]
    dog_name = dog_array[1]
    dog_breed = dog_array[2]
    Dog.new(id:dog_id, name:dog_name, breed:dog_breed)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
    SQL

    dog_array = DB[:conn].execute(sql, name)
    dog_id = dog_array[0][0]
    dog_name = dog_array[0][1]
    dog_breed = dog_array[0][2]
    Dog.new(id:dog_id, name:dog_name, breed:dog_breed)
  end

  def update

    sql = <<-SQL
      UPDATE dogs SET name = ?, breed= ? WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
