require "safe_yaml"

class RThread

  attr_accessor :name, :author, :num_comments, :permalink

  def initialize(name, author, num_comments, permalink)
    @name = name
    @author = author
    @num_comments = num_comments.to_i
    @permalink = permalink
    @cache = "./dat/threads.yml"
  end

  def should_check?
    @num_comments > 0 and previous_num_comments < @num_comments
  end

  def cache_comment_count!
    threads = YAML.load(File.open(@cache))
    threads[@name] = @num_comments
    File.open(@cache, "w") do |f|
      f.write(threads.to_yaml)
    end
  end

 private

  def previous_num_comments
    threads = YAML.load(File.open(@cache))
    threads[@name] || 0
  end

end
