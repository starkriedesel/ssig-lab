class ChallengeHint < ActiveRecord::Base
  attr_accessible :challenge_id, :hint_text, :cost
  
  # Markdown support for Hint Text
  extend MarkdownSupport
  with_markdown :hint_text
  
  belongs_to :challenge
end
