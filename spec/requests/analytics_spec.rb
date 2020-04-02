require "swagger_helper"

RSpec.describe "analytics", type: :request do
  before do
    seed_test_data
  end

  path "/api/v1/averages" do
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

  path "/api/v1/scored-question-distributions" do
    get("scored-question-distributions") do
      produces "application/json"

      response(200, "successful") do
        schema type: :object,
          properties: {
            scored_question_distributions: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  questionId: {
                    type: :integer,
                    example: 1,
                  },
                  responseFrequencies: {
                    type: :array,
                    items: {
                      type: :object,
                      properties: {
                        score: { type: :integer },
                        frequency: { type: :integer },
                      },
                    },
                  },
                },
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
          first = data["scored_question_distributions"].first
          expect(first["questionId"]).to eq(1)
          response_frequencies = first["responseFrequencies"]
          expect(response_frequencies[1]["frequency"]).to eq(1)
          expect(response_frequencies[3]["frequency"]).to eq(1)
        end
      end
    end
  end

  path "/api/v1/profile-segment-scores-by-gender" do
    get("profile-segment-scores-by-gender") do
      produces "application/json"

      response(200, "successful") do
        schema type: :object,
          properties: {
            profileSegmentScores: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  segment: {
                    type: :object,
                    properties: {
                      gender: { type: :string },
                    },
                  },
                  questionAverages: {
                    type: :array,
                    items: {
                      type: :object,
                      properties: {
                        questionId: { type: :integer },
                        averageScore: { type: :number },
                      },
                    },
                  },
                },
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
          first = data["profileSegmentScores"].first
          expect(first["segment"]["gender"]).to eq("Female")
          expect(first["questionAverages"].first["questionId"]).to eq(1)
          expect(first["questionAverages"].first["averageScore"]).to eq(4.0)
          second = data["profileSegmentScores"].second
          expect(second["segment"]["gender"]).to eq("Male")
          expect(second["questionAverages"].first["questionId"]).to eq(1)
          expect(second["questionAverages"].first["averageScore"]).to eq(2.0)
        end
      end
    end
  end
end
