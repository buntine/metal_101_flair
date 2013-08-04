require "active_support/time"

class RComment

  attr_accessor :author, :name, :link_id, :body, :created, :parent, :thread

  def initialize(author, name, link_id, body, created, parent, thread)
    @author = author
    @name = name
    @link_id = link_id
    @body = body
    @created = Time.at(created)
    @parent = parent
    @thread = thread
    @phrases = ["thanks professor", "thank professor", "thanks prof", "thanks professors", "thank professors"]
  end

  # Timestamp is younger than hours.
  def should_check?(hours=6)
    created > hours.hours.ago
  end

  def has_magic_words?
    body.gsub(/\W+/, " ").downcase =~ /#{@phrases.join("|")}/
  end

  def permalink
    File.join("http://www.reddit.com", thread.permalink, link_id)
  end

end
