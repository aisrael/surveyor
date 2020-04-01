class ScoredResponse < ApplicationRecord
    has_one :response, as: :response_body
end
