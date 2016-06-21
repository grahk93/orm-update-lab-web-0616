require_relative "../config/environment.rb"
require 'pry'

class Student
  attr_accessor :name, :grade, :id
  
  def initialize(id=nil,name,grade)
    @id = id
    @name = name
    @grade = grade
  end
  
  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end

  def save
  if self.id
    self.update
  else
    sql = <<-SQL
      INSERT INTO students (name, grade) 
      VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.grade)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
  end 
  end

  def self.create(name,grade)
    student = Student.new(name,grade)
    student.save
    student
  end

  def self.new_from_db(row)
    #binding.pry
    # create a new Student object given a row from the database
  new_student = self.new(row[0],row[1],row[2])  # self.new is the same as running student.new
  # new_student.id = row[0]
  # new_student.name =  row[1]
  # new_student.grade = row[2]
  new_student  # return the newly created instance
  end
  #had to pass in variables, also its toding the same thing...

  def self.find_by_name(name)
    # find the student in the database given a name
    # return a new instance of the Student class
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
      LIMIT 1
    SQL
    DB[:conn].execute(sql,name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
    sql = "UPDATE students SET id = ?, name = ? WHERE grade = ?"
    DB[:conn].execute(sql, self.id, self.name, self.grade)
  end
  
 
end
