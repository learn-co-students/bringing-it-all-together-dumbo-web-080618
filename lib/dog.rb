
require 'pry'
class Dog
  @@all = []
  attr_accessor :id, :name, :breed

def initialize (dog_hash)
  @name = dog_hash[:name]
  @breed = dog_hash[:breed]
  @id = dog_hash[:id]
  @@all << self
end

def self.create_table
  sql = <<-SQL
          CREATE TABLE dogs
          (id INTEGER PRIMARY KEY,
           name TEXT,
           breed TEXT);
          SQL
 DB[:conn].execute(sql)
end

def self.drop_table
  DB[:conn].execute("DROP TABLE IF EXISTS dogs")
end

def save
  sql = <<-SQL
          INSERT INTO dogs (
          name, breed)
          VALUES (?,?);
          SQL
  DB[:conn].execute(sql,self.name,self.breed)
  sql1 =         <<-SQL
              SELECT * FROM dogs
              ORDER BY id DESC
              LIMIT 1
              SQL
   dog_inst = DB[:conn].execute(sql1)
  self.id = dog_inst[0][0]
  self
end

def self.create (hash)
  dog1 = self.new (hash)
  dog1.save
end

def self.new_from_db (arr)
  id = arr[0]
  name = arr[1]
  breed = arr[2]
  x=self.new ({id:id,name:name,breed:breed})
  x
end


def self.find_by_id (id)
  sql1 =         <<-SQL
                SELECT * FROM dogs
                WHERE id = ?
                SQL
  dog_inst = (DB[:conn].execute(sql1, id)).flatten!
  self.new_from_db (dog_inst)
end

def self.find_by_name (name)
  sql1 =         <<-SQL
                SELECT * FROM dogs
                WHERE name = ?
                SQL
  dog_inst = (DB[:conn].execute(sql1, name)).flatten!
  self.new_from_db (dog_inst)
end

def self.find_or_create_by(hash)
  self.all.each do |dog|
    if dog.name == hash[:name] && dog.breed == hash[:breed]
      return dog
    else
      self.create(hash)
    end
  end
end

def update
  sql2 =         <<-SQL
                UPDATE dogs
                SET name = ?
                WHERE id = ?
                SQL
    DB[:conn].execute(sql2,self.name,self.id)
end

def self.all
  @@all
end

end
