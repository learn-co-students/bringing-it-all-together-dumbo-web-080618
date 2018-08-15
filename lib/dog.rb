

class Dog

  attr_accessor :id, :name, :breed

  def initialize(name:, breed:, id: nil)
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
      DROP TABLE dogs;
      SQL

      DB[:conn].execute(sql)
    end

    def self.new_from_db(row)
      self.new(name:row[1], breed:row[2], id:row[0])
    end

    def save
      no_id = <<-SQL
      INSERT INTO dogs (name, breed) VALUES ('#{self.name}', '#{self.breed}');
      SQL

      if self.id == nil
        DB[:conn].execute(no_id)

        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      else
        update
      end

      Dog.new(name:self.name, breed: self.breed, id: self.id)

    end

    def self.create(name:, breed:)
      doggo = Dog.new(name:name, breed:breed)
      doggo.save
    end

    def self.find_by_id(id)
      sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?;
      SQL

      doggo = DB[:conn].execute(sql, id).flatten!
      Dog.new(name:doggo[1], breed:doggo[2], id:doggo[0])
    end

    def self.find_or_create_by(name:, breed:)
      sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?;
      SQL

      doggo = DB[:conn].execute(sql, name, breed).flatten!
      if doggo == nil
        return Dog.new(name:name, breed:breed).save
      else
        # binding.pry
        return Dog.new(name:doggo[1], breed:doggo[2], id:doggo[0]).save
      end
    end

    def self.find_by_name(name)
      sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?;
      SQL

      doggo = DB[:conn].execute(sql, name).flatten!
      Dog.new(name:doggo[1], breed:doggo[2], id:doggo[0])
    end

    def update
      update = <<-SQL
      UPDATE dogs SET name = '#{self.name}', breed = '#{self.breed}' WHERE id = #{self.id};
      SQL
      DB[:conn].execute(update)
    end

end
