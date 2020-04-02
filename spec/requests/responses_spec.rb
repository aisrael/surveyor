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
                  body: {
                    type: :string,
                    example: "4"
                  }
                }
              }
            }
          }
        }

      response(200, 'successful') do
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
          puts "@count => #{@count}"
          submit_request(example.metadata)
        end

        it 'returns a valid 201 response' do |example|
          assert_response_matches_metadata(example.metadata)
          puts "@count => #{@count}"
          puts "Response.count => #{Response.count}"
          assert(Response.count == @count + 2) # Two new responses
        end

        after do |example|
          example.metadata[:response][:examples] = { 'application/json' => JSON.parse(response.body, symbolize_names: true) }
        end
      end
    end

    get('list responses') do
      response(200, 'successful') do

        after do |example|
          example.metadata[:response][:examples] = { 'application/json' => JSON.parse(response.body, symbolize_names: true) }
        end
        run_test!
      end
    end
  end
end
