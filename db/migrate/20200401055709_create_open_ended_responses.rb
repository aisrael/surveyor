class CreateOpenEndedResponses < ActiveRecord::Migration[6.0]
  def change
    create_table :open_ended_responses do |t|
      t.integer :response_id
      t.string :body

      t.timestamps
    end
  end
end
