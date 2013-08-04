require "active_support/time"

class RComment

  attr_accessor :name, :permalink, :body, :created, :parent

  def initialize(name, permalink, body created, parent)
    @name = name
    @permalink = permalink
    @body = body
    @created = Time.at(created)
    @parent = parent
    @phrases = ["thanks professor", "thank professor", "thanks prof", "thanks professors", "thank professors"]
  end

  # Timestamp is younger than hours.
  def should_check?(hours=6)
    @created > hours.hours.ago
  end

  def has_magic_words?
    # Contains phrase.
    true
  end

end
