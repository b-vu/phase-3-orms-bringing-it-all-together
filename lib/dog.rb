class Dog
    attr_accessor :name, :breed, :id

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE IF EXISTS dogs
        SQL

        DB[:conn].execute(sql)
    end

    def self.create(attributes)
        new_dog = Dog.new(attributes)
        new_dog.save
    end

    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.all
        sql = <<-SQL
            SELECT *
            FROM dogs
        SQL

        array = DB[:conn].execute(sql).map do |dog|
            Dog.new_from_db(dog)
        end

        array
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
            LIMIT 1
        SQL

        dog = DB[:conn].execute(sql, name)

        Dog.new_from_db(dog[0])
    end

    def self.find(id)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE id = ?
            LIMIT 1
        SQL

        dog = DB[:conn].execute(sql, id)

        Dog.new_from_db(dog[0])
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs(name, breed)
            VALUES(?, ?)
        SQL

        DB[:conn].execute(sql, self.name, self.breed)

        self.id = DB[:conn].last_insert_row_id

        self
    end
end
