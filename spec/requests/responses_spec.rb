require 'swagger_helper'

RSpec.describe 'responses', type: :request do

  before do

    fixtures_files_dir = 'test/fixtures/files/'
    questions_file = File.new(File.join(fixtures_files_dir, 'questions.yml'))

    YAML.load(questions_file).each do |record|
        Question.create id: record['id'],
            question_type: record['type'],
            prompt: record['prompt'],
            optional: record['optional']
    end

    respondents_file = File.new(File.join(fixtures_files_dir, 'respondents.yml'))
    YAML.load(respondents_file).each do |record|
        Respondent.create identifier: record['identifier'],
            gender: record['profile']['gender'],
            department: record['profile']['department']
    end

  end

  path '/responses' do
    post('submit responses') do
      consumes 'application/json'
      produces 'application/json'
      parameter name: :payload,
        in: :body,
        schema: {
          type: :object,
          properties: {
            respondentIdentifier: {
              type: :string,
              example: '00001'
            },
            responses: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  questionId: {
                    type: :integer,
                    example: 1
                  },
                  respondentId: {
                    type: :string,
                    example: "00001"
                  },
                  body: {
                    oneOf: [
                      {
                        type: :integer,
                        example: 4
                      },
                      {
                        type: :string,
                        example: "Unclear expectations"
                      }
                    ]
                  }
                }
              }
            }
          }
        }

      response(200, 'successful') do
        schema type: :object,
          properties: {
            data: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: {
                    type: :integer,
                    example: 1
                  },
                  respondentIdentifier: {
                    type: :string,
                    example: "00001"
                  },
                  questionId: {
                    type: :integer,
                    example: 1
                  },
                  body: {
                    oneOf: [
                      {
                        type: :integer,
                        example: 4
                      },
                      {
                        type: :string,
                        example: "Unclear expectations"
                      }
                    ]
                  }
                },
                required: ['id', 'respondentIdentifier', 'questionId', 'body']
              }
            }
          },
          required: [:data]

        let(:payload) {
          {
            respondentIdentifier: '00001',
            responses: [
              {
                "questionId": 1,
                "body": 4
              },
              {
                "questionId": 2,
                "body": "Unclear expectations"
              }
            ]
          }
        }

        before do |example|
          @count = Response.count
          submit_request(example.metadata)
        end

        it 'returns a valid 201 response' do |example|
          assert_response_matches_metadata(example.metadata)
          assert(Response.count == @count + 2) # Two new responses
        end

        after do |example|
          example.metadata[:response][:examples] = { 'application/json' => JSON.parse(response.body, symbolize_names: true) }
        end
      end
    end

    get('list responses') do
      response(200, 'successful') do
        schema type: :object,
          properties: {
            responses: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  questionId: {
                    type: :integer,
                    example: 1
                  },
                  body: {
                    type: :string,
                    example: "4"
                  }
                },
                required: ['questionId', 'body']
              }
            }
          }

        let(:responses) do
          respondent = Respondent.first
          question = Question.first
          ScoredResponse.create!(
            respondent_id: respondent.id,
            question_id: question.id,
            body: '4'
          )
        end

        after do |example|
          example.metadata[:response][:examples] = { 'application/json' => JSON.parse(response.body, symbolize_names: true) }
        end
        run_test!
      end
    end
  end

  path '/averages' do
    get('list averages') do
      produces 'application/json'

      response(200, 'successful') do
        schema type: :object,
          properties: {
            questionAverages: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  questionId: {
                    type: :integer,
                    example: 1
                  },
                  averageScore: {
                    type: :number,
                    example: 4.0
                  }
                },
                required: ['questionId', 'averageScore']
              }
            }
          }

        before do
          # Create test data
          question = Question.where(question_type: 'scored').first
          ScoredResponse.create!(
            respondent_id: Respondent.first.id,
            question_id: question.id,
            body: '4'
          )
          ScoredResponse.create!(
            respondent_id: Respondent.second.id,
            question_id: question.id,
            body: '2'
          )
        end

        after do |example|
          example.metadata[:response][:examples] = { 'application/json' => JSON.parse(response.body, symbolize_names: true) }
        end

        run_test! do |response|

          data = JSON.parse(response.body)
          first = data['questionAverages'].first
          expect(first['questionId']).to eq(1)
          expect(first['averageScore']).to eq(3.0)
        end
      end
    end
  end
end
