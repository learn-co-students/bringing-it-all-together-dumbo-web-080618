require 'pry'


class Dog

  attr_accessor :name, :id, :breed

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
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

    DB[:conn].execute(sql, self.name, self.breed)

    beef = <<-SQL
      SELECT * FROM dogs ORDER BY id DESC LIMIT 1
    SQL

    new_fan_hash = DB[:conn].execute(beef).flatten

    self.id = new_fan_hash[0]

    return self
  end

  def self.create(hash)
    new_dog = Dog.new(hash)
    new_dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL

    something = DB[:conn].execute(sql, id).flatten

    self.new(id: something[0], name: something[1], breed: something[2])

  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
    SQL

    something = DB[:conn].execute(sql, name).flatten

    self.new(id: something[0], name: something[1], breed: something[2])
  end

  def self.find_or_create_by(dog_row)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?
    SQL

    something = DB[:conn].execute(sql, dog_row[:name], dog_row[:breed]).flatten

    if something[0] != nil
      Dog.new_from_db(something)
    else
      variable = Dog.new(dog_row)
      variable.save
    end

  end

  def self.new_from_db(array)
    Dog.new(id: array[0], name: array[1], breed: array[2])
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
      SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
