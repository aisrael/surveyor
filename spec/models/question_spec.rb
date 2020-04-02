require "rails_helper"

RSpec.describe Response, type: :model do
  before do
    seed_test_data
  end

  it "has custom as_json behavior" do
    response = Response.new question_id: 1, respondent_id: 1, body: 4
    as_json = response.as_json
    expect(as_json).to be_a(Hash)
    expect(as_json.keys).to eq(%w[respondentId questionId body])
  end
end
