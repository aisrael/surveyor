require "swagger_helper"

RSpec.describe "analytics", type: :request do
  before do
    seed_test_data
  end

  path "/averages" do
    get("averages") do
      produces "application/json"

      response(200, "successful") do
        schema type: :object,
          properties: {
            questionAverages: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  questionId: {
                    type: :integer,
                    example: 1,
                  },
                  averageScore: {
                    type: :number,
                    example: 4.0,
                  },
                },
                required: ["questionId", "averageScore"],
              },
            },
          }

        before do
          # Create test data
          question = Question.where(question_type: "scored").first
          ScoredResponse.create!(
            respondent_id: Respondent.first.id,
            question_id: question.id,
            body: "4",
          )
          ScoredResponse.create!(
            respondent_id: Respondent.second.id,
            question_id: question.id,
            body: "2",
          )
        end

        after do |example|
          example.metadata[:response][:examples] = { "application/json" => JSON.parse(response.body, symbolize_names: true) }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          first = data["questionAverages"].first
          expect(first["questionId"]).to eq(1)
          expect(first["averageScore"]).to eq(3.0)
        end
      end
    end
  end
end
