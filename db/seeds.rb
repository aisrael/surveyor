# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'yaml'

FIXTURES_FILES_DIR = 'test/fixtures/files/'
QUESTIONS_FILE = File.new(File.join(FIXTURES_FILES_DIR, 'questions.yml'))

YAML.load(QUESTIONS_FILE).each do |record|
    Question.create id: record['id'],
        question_type: record['type'],
        prompt: record['prompt'],
        optional: record['optional']
end

RESPONDENTS_FILE = File.new(File.join(FIXTURES_FILES_DIR, 'respondents.yml'))
YAML.load(RESPONDENTS_FILE).each do |record|
    Respondent.create identifier: record['identifier'],
        gender: record['profile']['gender'],
        department: record['profile']['department']
end
