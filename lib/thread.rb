class Thread

  attr_accessor :name, :author, :num_comments, :permalink

  def initialize(name, author, num_comments, permalink)
    @name = name
    @author = author
    @num_comments = num_comments
    @permalink = permalink
  end

  def should_check?
    # Check for any comments
  end

end
