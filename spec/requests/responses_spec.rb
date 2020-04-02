require "swagger_helper"

RSpec.describe "responses", type: :request do
  before do
    seed_test_data
  end

  path "/responses" do
    post("submit responses") do
      consumes "application/json"
      produces "application/json"
      parameter name: :payload,
        in: :body,
        schema: {
          type: :object,
          properties: {
            respondentIdentifier: {
              type: :string,
              example: "00001",
            },
            responses: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  questionId: {
                    type: :integer,
                    example: 1,
                  },
                  respondentId: {
                    type: :string,
                    example: "00001",
                  },
                  body: {
                    oneOf: [
                      {
                        type: :integer,
                        example: 4,
                      },
                      {
                        type: :string,
                        example: "Unclear expectations",
                      },
                    ],
                  },
                },
              },
            },
          },
        }

      response(200, "successful") do
        schema type: :object,
          properties: {
            data: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: {
                    type: :integer,
                    example: 1,
                  },
                  respondentIdentifier: {
                    type: :string,
                    example: "00001",
                  },
                  questionId: {
                    type: :integer,
                    example: 1,
                  },
                  body: {
                    oneOf: [
                      {
                        type: :integer,
                        example: 4,
                      },
                      {
                        type: :string,
                        example: "Unclear expectations",
                      },
                    ],
                  },
                },
                required: ["id", "respondentIdentifier", "questionId", "body"],
              },
            },
          },
          required: [:data]

        let(:payload) {
          {
            respondentIdentifier: "00001",
            responses: [
              {
                "questionId": 1,
                "body": 4,
              },
              {
                "questionId": 2,
                "body": "Unclear expectations",
              },
            ],
          }
        }

        before do |example|
          @count = Response.count
          submit_request(example.metadata)
        end

        it "returns a valid 201 response" do |example|
          assert_response_matches_metadata(example.metadata)
          assert(Response.count == @count + 2) # Two new responses
        end

        after do |example|
          example.metadata[:response][:examples] = { "application/json" => JSON.parse(response.body, symbolize_names: true) }
        end
      end
    end

    get("list responses") do
      response(200, "successful") do
        schema type: :object,
          properties: {
            responses: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  questionId: {
                    type: :integer,
                    example: 1,
                  },
                  body: {
                    type: :string,
                    example: "4",
                  },
                },
                required: ["questionId", "body"],
              },
            },
          }

        let(:responses) do
          respondent = Respondent.first
          question = Question.first
          ScoredResponse.create!(
            respondent_id: respondent.id,
            question_id: question.id,
            body: "4",
          )
        end

        after do |example|
          example.metadata[:response][:examples] = { "application/json" => JSON.parse(response.body, symbolize_names: true) }
        end
        run_test!
      end
    end
  end
end
