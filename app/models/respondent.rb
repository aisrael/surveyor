class Respondent < ApplicationRecord
  has_many :responses do
    def to_scored_questions
      joins(:question).where('questions.question_type': "scored")
    end
  end

  scope :gender, ->(gender) { where(gender: gender.to_s.downcase.capitalize) }

  # Return a demographic breakdown of scores by respondent gender
  def self.profile_segment_scores_by_gender
    scored_questions = Question.scored_questions

    genders = Respondent.select(:gender).distinct.map(&:gender) # Should really just be ['Female', 'Male]
    genders.map do |gender|
      question_averages = Respondent.gender(gender).map do |respondent|
        respondent.responses.to_scored_questions
      end.reject(&:empty?).flatten.group_by(&:question_id).map do |question_id, responses|
        total = responses.map(&:score).sum
        {
          questionId: question_id,
          averageScore: total / responses.size,
        }
      end
      {
        segment: { gender: gender },
        questionAverages: question_averages,
      }
    end
  end
end
