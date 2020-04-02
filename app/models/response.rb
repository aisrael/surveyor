class Response < ApplicationRecord
    belongs_to :respondent
    belongs_to :question

    def as_json(*)
        h = super.except("id", "created_at", "updated_at").map do |k, v|
            [k.to_s.camelcase(:lower), v]
        end
        Hash[h]
    end
end
