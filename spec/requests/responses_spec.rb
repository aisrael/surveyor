require 'swagger_helper'

RSpec.describe 'responses', type: :request do

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
            }
          }
        }

      response(200, 'successful') do
        after do |example|
          example.metadata[:response][:examples] = { 'application/json' => JSON.parse(response.body, symbolize_names: true) }
        end
        run_test!
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
