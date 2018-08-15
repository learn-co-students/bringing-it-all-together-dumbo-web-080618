require 'pry'
class Dog

  attr_accessor :name, :breed, :id
  attr_reader
  attr_writer

  def initialize(dog_hash)
    @name = dog_hash[:name]
    @breed = dog_hash[:breed]
    @id = dog_hash[:id]
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

  def self.insert(name, breed)

    sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, name, breed)

  end

  def save
    Dog.insert(self.name, self.breed)
    sql = <<-SQL
      SELECT * FROM dogs ORDER BY id DESC LIMIT 1
    SQL
    new_dog_hash = DB[:conn].execute(sql)
    self.id = new_dog_hash[0][0]
    self

  end

  def self.create(dog_hash)
    #binding.pry
    new_hash = Dog.new(dog_hash)
    new_hash.save
    new_hash

  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL

    temp = DB[:conn].execute(sql, id)
    self.new_from_db(temp.flatten)

  end

  def self.find_or_create_by(hash)
    #binding.pry
    if self.find_by_name(hash[:name]).name == hash[:name] && self.find_by_breed(hash[:breed]).breed == hash[:breed]
      self.find_by_name(hash[:name])
    else
      self.create(hash)
    end

  end

  def self.new_from_db(db)
    new_hash = {}
    new_hash[:id] = db[0]
    new_hash[:name] = db[1]
    new_hash[:breed] = db[2]
    self.new(new_hash)

  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
    SQL

    temp = DB[:conn].execute(sql, name)
    self.new_from_db(temp.flatten)

  end

  def self.find_by_breed(breed)
    sql = <<-SQL
      SELECT * FROM dogs WHERE breed = ?
    SQL

    temp = DB[:conn].execute(sql, breed)
    self.new_from_db(temp.flatten)

  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed)

  end

end
