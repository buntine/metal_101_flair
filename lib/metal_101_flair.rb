require "net/http"
require "json"
require "snoo"
require "active_support/core_ext/object/to_query"
require "./lib/r_thread"
require "./lib/r_comment"

class Metal101Flair

  def initialize(limit=100, hours=6)
    @limit = limit
    @hours = hours
    @base_url = "http://www.reddit.com"
    @moderator = "MODERATOR_NAME"
  end

  def professors
    professors = []

    threads = get_json("/r/Metal101/new", {:limit => @limit})["children"]
    threads.each do |t|
      t = t["data"]
      thread = RThread.new(t["name"], t["author"], t["num_comments"], t["permalink"])

      if thread.should_check?
        puts "Entering thread #{thread.name}"  

        comments = get_json(thread.permalink)["children"]
        comments = flatten_comments(comments, thread)

        comments.each do |c|
          if c.should_check?
            if c.has_magic_words?
              puts " ! Found magic words in #{c.name}"

              p = find_comment(comments, c.parent)
              professors << {:author => p.author, :permalink => c.permalink}
            else
              puts " - No magic words in #{c.name}"
            end
          end
        end
      end

      thread.cache_comment_count!
    end

    reddit = Snoo::Client.new
    reddit.log_in "USER_NAME", "PASSWORD"

    # Collate data and PM mods.
    pm_content = if professors.empty?
      "No professors in the past #{@hours} hours..."
    else
      "PROFESSORS\n\n" + format_professors(professors)
    end

    reddit.send_pm @moderator, "Professors for #{Time.now.strftime("%Y-%m-%d %H:%M")}", pm_content
    reddit.log_out
  end

 private

  # Recursively consumes the comments from a thread an returns a flattened array.
  def flatten_comments(comments, thread)
    comms = []

    comments.each do |c|
      c = c["data"]
      comms << RComment.new(c["author"], c["name"], c["id"], c["body"], c["created_utc"], c["parent_id"], thread)

      if c["replies"].is_a?(Hash)
        comms = comms.concat(flatten_comments(c["replies"]["data"]["children"], thread))
      end
    end

    comms
  end

  def find_comment(comments, name)
    comments.find do |c|
      c.name == name
    end
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

  def format_professors(professors)
    professors.map do |p|
      "* #{p[:author]}: #{p[:permalink]}"
    end.join("\n")
  end

end
