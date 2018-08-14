class Dog

attr_accessor :name, :breed, :id

def initialize(name:, breed:, id:nil)
  @name = name
  @breed = breed
  @id = id
end

def self.create(dog_hash)
  new_dog = Dog.new(dog_hash)
  new_dog.save
  new_dog
end


  def self.create_table
    sql =  <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
        DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end


  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES(?, ?)
    SQL

      DB[:conn].execute(sql, self.name, self.breed)


          beef = <<-SQL
            SELECT * FROM dogs ORDER BY id  DESC LIMIT 1
          SQL

          new_dog_hash = DB[:conn].execute(beef)
          new_dog_hash_flatten = new_dog_hash.flatten
          self.id = new_dog_hash_flatten[0]
          self

        end



        def self.new_from_db(row)
          Dog.new(name:row[1], breed:row[2], id:row[0])
        end

        def self.find_by_id(id)
          sql = <<-SQL
            SELECT * FROM dogs WHERE id = ?
          SQL


          value = DB[:conn].execute(sql, id).flatten
          Dog.new(name:value[1],breed:value[2],id:value[0])

          end



        def self.find_by_name(name)
          sql = <<-SQL
            SELECT * FROM dogs WHERE name = ?
          SQL


          value = DB[:conn].execute(sql, name).flatten
          Dog.new(name:value[1],breed:value[2],id:value[0])

          end

def self.find_or_create_by(name:, breed:)
  dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
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
    UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end
