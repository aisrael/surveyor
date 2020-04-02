class CreateResponses < ActiveRecord::Migration[6.0]
  def change
    create_table :responses do |t|
      t.string :type
      t.integer :respondent_id
      t.integer :question_id
      t.string :body

      t.timestamps
    end
  end
end
