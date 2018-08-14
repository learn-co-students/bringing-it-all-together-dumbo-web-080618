class Dog
  attr_accessor :name, :breed, :id

  def initialize(attributes)
    @name = attributes[:name]
    @breed = attributes[:breed]
    @id = attributes[:id]
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
      INSERT INTO dogs (name, breed) VALUES (?, ?);
    SQL
    DB[:conn].execute(sql,self.name, self.breed)

    x = <<-SQL
      SELECT * FROM dogs ORDER BY id DESC LIMIT 1;
    SQL

    new_hash = DB[:conn].execute(x).flatten
    self.id = new_hash[0]
    self

  end


    def self.create(attr)
      new_dog = Dog.new(attr)
      new_dog.save
    end

    def self.new_from_db(arr)
      Dog.new(id:arr[0],name:arr[1],breed:arr[2])
    end

    def self.find_by_id(id)
      sql = <<-SQL
        SELECT * FROM dogs WHERE id = ?;
      SQL

      x = DB[:conn].execute(sql,id).flatten
      # binding.pry
      z=Dog.new_from_db(x)
    end

    def self.find_or_create_by(arr)

      sql = <<-SQL
        SELECT * FROM dogs WHERE name = ? AND breed = ?;
      SQL


      z= DB[:conn].execute(sql,arr[:name], arr[:breed]).flatten

      if z[0] != nil
        g = Dog.new_from_db(z)
      else
        x = Dog.new(arr)
        x.save
      end

    end


    def self.find_by_name(name)
      sql = <<-SQL
        SELECT * FROM dogs WHERE name = ?;
      SQL

      var = DB[:conn].execute(sql, name).flatten

      Dog.new_from_db(var)

    end


    def update
      sql = <<-SQL
        UPDATE dogs SET name = ? WHERE id = ?;
      SQL

      DB[:conn].execute(sql, self.name, self.id)

    end











end
