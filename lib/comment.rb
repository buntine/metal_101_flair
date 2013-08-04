class Comment

  attr_accessor :name, :permalink, :created, :parent

  def initialize(name, permalink, created, parent)
    @name = name
    @permalink = permalink
    @created = created
    @parent = parent
    @phrases = ["thanks professor", "thank professor", "thanks prof", "thanks professors", "thank professors"]
  end

  def should_check?(hours=6)
    # Timestamp is younger than hours.
  end

  def has_magic_words?
    # Contains phrase.
  end

end
