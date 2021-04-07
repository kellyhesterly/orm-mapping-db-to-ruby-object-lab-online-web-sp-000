class Student
  attr_accessor :name, :grade, :id

  def self.all
    sql = <<-SQL
    SELECT * FROM students
    SQL
    DB[:conn].execute(sql).map {|row| self.new_from_db(row)}
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade INTEGER
    );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS students")
  end

  def save
    sql = <<-SQL
    INSERT INTO students (name, grade) VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.grade)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
  end

  def self.new_from_db(row)
    student = self.new
    student.id = row[0]
    student.name = row[1]
    student.grade = row[2]
    student
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students WHERE name = ? LIMIT 1
    SQL
    DB[:conn].execute(sql, name).map {|song| self.new_from_db(song)}.first
  end

  def self.all_students_in_grade_9
    DB[:conn].execute("SELECT * FROM students WHERE grade = 9")
  end

  def self.students_below_12th_grade
    DB[:conn].execute("SELECT * FROM students GROUP BY name HAVING grade < 12")
  end
end
