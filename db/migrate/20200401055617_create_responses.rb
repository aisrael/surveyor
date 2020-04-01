class CreateResponses < ActiveRecord::Migration[6.0]
  def change
    create_table :responses do |t|
      t.integer :respondent_id
      t.integer :question_id
      t.integer :response_body_id
      t.string :response_body_type

      t.timestamps
    end
  end
end
