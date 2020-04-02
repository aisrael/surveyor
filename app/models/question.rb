class Question < ApplicationRecord
  has_many :responses

  scope :scored_questions, -> { where(question_type: "scored") }

  # Returns the scored question distributions:
  #
  # ```
  # [
  #   {
  #     questionId: question.id,
  #     responseFrequencies: [
  #       {score: 1, frequency: 0}, ...
  #     ]
  #   }
  # ]
  # ```
  def self.scored_question_distributions
    Question.scored_questions.all.map do |question|
      responses_grouped_by_score = question.responses.group_by(&:score)
      response_frequencies = (1..5).map do |score|
        frequency = if responses_grouped_by_score.has_key?(score)
            responses_grouped_by_score[score].size
          else
            0
          end
        { score: score, frequency: frequency }
      end
      {
        questionId: question.id,
        responseFrequencies: response_frequencies,
      }
    end
  end
end
