require "net/http"
require "json"
require "active_support/core_ext/object/to_query"
require "./lib/r_thread"
require "./lib/r_comment"

# Get 100 threads, order by new
# See if new comments exist in each
  # Delete those that have not changed
  # Update databse with new threads
  # Update database with new comments count

# Check comments for each
  # Delete comments older than 6 hours
  # Search for magic words
    # If found, find parent and record

# Collate into comment
# PM mods

class Metal101Flair

  def initialize(limit=100, hours=6)
    @limit = limit
    @hours = hours
    @base_url = "http://www.reddit.com"
  end

  def professors
    professors = {}

    threads = get_json("/r/Metal101/new", {:limit => @limit})["children"]
    threads.each do |t|
      t = t["data"]
      thread = RThread.new(t["name"], t["author"], t["num_comments"], t["permalink"])

      if thread.should_check?
        puts "Entering thread #{thread.name}"  
        thread.cache_comment_count!

        comments = get_json(thread.permalink)["children"]
        comments = flatten_comments(comments)

        comments.each do |c|
          if c.should_check?
            if c.has_magic_words?
              # Find parent comment in "comments" array.
              # Add Author to professors hash.
              puts " ! Found magic words in #{c.name}"
            else
              puts " - No magic words in #{c.name}"
            end
          else
            puts " - Ignoring old comment #{c.name}"
          end
        end
      else
        puts "Ignoring thread #{thread.name}"  
      end
    end

    # Collate data and print / PM.
  end

 private

  # Recursively consumes the comments from a thread an returns a flattened array.
  def flatten_comments(comments)
    comms = []

    comments.each do |c|
      c = c["data"]
      comms << RComment.new(c["name"], c["permalink"], c["body"], c["created_utc"], c["parent"])

      if c["replies"].is_a?(Hash)
        comms = comms.concat(flatten_comments(c["replies"]["data"]["children"]))
      end
    end

    comms
  end

  def get_json(path="/", query={})
    url = File.join(@base_url, "#{path.sub(/\/+$/, '')}.json?#{query.to_query}")
    resp = Net::HTTP.get_response(URI.parse(url))
    buffer = resp.body

    json = JSON.parse(buffer, :max_nesting => 100)

    if json.is_a?(Array)
      json[1]["data"]
    else
      json["data"]
    end
  end

end
