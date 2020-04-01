class CreateScoredResponses < ActiveRecord::Migration[6.0]
  def change
    create_table :scored_responses do |t|
      t.integer :response_id
      t.integer :score

      t.timestamps
    end
  end
end
