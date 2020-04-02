require "rails_helper"

RSpec.describe Response, type: :model do
  before do
    seed_test_data
  end

  it "provides an integer score" do
    response = ScoredResponse.new question_id: 1, respondent_id: 1, body: 4
    expect(response.score).to eq(4)
  end
end
