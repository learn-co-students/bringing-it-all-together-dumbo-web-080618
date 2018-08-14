

class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id:nil)
    @name = name
    @breed = breed
    @id = id
    #attributes.each {|key, value| self.send(("#{key}="), value)}
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
    INSERT INTO dogs (name,breed) VALUES(?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)
    sql_2 = <<-SQL
      SELECT * FROM dogs ORDER BY id DESC LIMIT 1;
    SQL
    new_dog_hash = DB[:conn].execute(sql_2)
    self.id = new_dog_hash[0][0]
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
def self.find_or_create_by(name)
  sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?;
    SQL
    #binding.pry
    dog_array = DB[:conn].execute(sql, name[:name], name[:breed]).flatten
#binding.pry
if dog_array[0] == nil
  new_dog = Dog.new(name)
  new_dog.save
else
  Dog.new_from_db(dog_array)
end
end

def self.new_from_db(name)
  Dog.new(id:name[0], name:name[1], breed:name[2])

#binding.pry



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

  #binding.pry
end

def update

  sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)

#binding.pry
end

end





  #  new_fan_hash = DB[:conn].execute(sql)
    # binding.pry
  #  self.id = new_fan_hash[0]["id"]

    # DESC -> 10, 9, 8, 7....
    # ASC -> 1, 2, 3, 4....
