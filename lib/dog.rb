require 'pry'

class Dog

  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create(dog_hash)
    new_dog = Dog.new(dog_hash)
    new_dog.save
    new_dog
  end

  def save
    Dog.insert(self.name, self.breed)

    dog_id = <<-SQL
      SELECT * FROM dogs ORDER BY id DESC LIMIT 1
    SQL

    new_dog_hash = DB[:conn].execute(dog_id)

    self.id = new_dog_hash[0][0]
    self

  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )
    SQL
    DB[:conn].execute(sql)
  end

  def self.insert(name, breed)
    sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, name, breed)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs
    SQL
    DB[:conn].execute(sql)
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id =?
    SQL
    newer_dog = DB[:conn].execute(sql, id)
    found_dog = Dog.new(id: newer_dog[0][0], name: newer_dog[0][1], breed: newer_dog[0][2])
    found_dog
  end

  def self.new_from_db(row)
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
    SQL
    newer_dog = DB[:conn].execute(sql, name)
    found_dog = Dog.new(id: newer_dog[0][0], name: newer_dog[0][1], breed: newer_dog[0][2])
    found_dog
  end

  def self.find_by_breed(breed)
    sql = <<-SQL
      SELECT * FROM dogs WHERE breed = ?
    SQL
    newer_dog = DB[:conn].execute(sql, breed)
    found_dog = Dog.new(id: newer_dog[0][0], name: newer_dog[0][1], breed: newer_dog[0][2])
    found_dog
  end

  def self.find_or_create_by(dog_hash)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?
    SQL
    found = DB[:conn].execute(sql, dog_hash[:name], dog_hash[:breed]).flatten
    if Dog.find_by_name(dog_hash[:name]).name == found[1]
      if Dog.find_by_breed(dog_hash[:breed]).breed == found[2]
        Dog.find_by_name(dog_hash[:name])
      end
    else
      Dog.create(dog_hash)
    end
  end

  def update
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL
    data = DB[:conn].execute(sql, self.id).flatten

    sql = <<-SQL
      UPDATE dogs SET name = ? WHERE name = ?
    SQL
    DB[:conn].execute(sql, self.name, data[1])
  end

end
