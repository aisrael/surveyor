class Response < ApplicationRecord
    belongs_to :response_body, polymorphic: true
end
