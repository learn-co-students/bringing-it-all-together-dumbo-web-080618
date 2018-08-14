require 'pry'

class Dog

  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT);
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE dogs
    SQL
    DB[:conn].execute(sql)
  end

  def self.new_from_db(arr)
    Dog.new(id: arr[0], name: arr[1], breed: arr[2])
  end


  def self.find_or_create_by(dog_hash)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ? AND breed = ?;
    SQL
    dog_arr = DB[:conn].execute(sql, dog_hash[:name], dog_hash[:breed]).flatten
    if dog_arr[0] == nil
      new_dog = Dog.new(dog_hash)
      new_dog.save
    else
      Dog.new_from_db(dog_arr)
    end
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs WHERE id = ?;
    SQL
    dog_arr = DB[:conn].execute(sql, id).flatten
    self.new(id: dog_arr[0], name:dog_arr[1], breed:dog_arr[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ?;
    SQL
    dog_arr = DB[:conn].execute(sql, name).flatten
    self.new(id: dog_arr[0], name:dog_arr[1], breed:dog_arr[2])
  end

  def self.create(dog_hash)
    #binding.pry
    new_dog = Dog.new(dog_hash)
    new_dog.save
  end

  def save
    Dog.insert(self.name, self.breed)

    sql2 = <<-SQL
    SELECT * FROM dogs ORDER BY id DESC LIMIT 1
    SQL

    new_dog_hash = DB[:conn].execute(sql2)

    self.id = new_dog_hash[0][0]
    return self
  end

  def update
    sql = <<-SQL
    UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.insert(name, breed)
    sql = <<-SQL
    INSERT INTO dogs (name, breed) VALUES (?, ?);
    SQL

    DB[:conn].execute(sql, name, breed)
  end

end
