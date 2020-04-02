class ScoredResponse < Response
  def score
    return nil if body.nil?
    return body.to_i
  end

  # Returns the averages for all scored responses
  # @return `{questionId: 1, averageScore: 4.0}``
  def self.question_averages
    ScoredResponse.group(:question_id).average("body::integer").map do |question_id, average|
      {
        questionId: question_id,
        averageScore: average.to_f, # since it's BigDecimal, we need to `.to_f` it
      }
    end
  end
end
