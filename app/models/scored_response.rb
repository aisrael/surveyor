class ScoredResponse < Response
    def score
        return nil if body.nil?
        return body.to_i
    end
end
