require 'octokit'
require 'redcarpet'
require 'redis'

class Vision

  def initialize
    @concepts = []
    @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
    @octokit  = Octokit::Client.new(:login => ENV["GITHUB_USER"], :password => ENV["GITHUB_PASSWORD"])
    uri = URI.parse(ENV["REDISCLOUD_URL"])
    @redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
    load_gist
  end

  def concepts
    @redis.get("vision")
  end

  def load_gist
    input_text = @octokit.gist("6068276")["files"]["Coding the Humanities.md"]["content"]
    parse_gist(@markdown.render(input_text))
  end

  def parse_gist(text)
    concept = {}
    text.each_line do |line|
      if line =~ /\<h2\>/
        l = line.match(/\>(.+)\</)
        concept = {}
        concept[:name] = l[1]
        concept[:description] = ""
        @concepts << concept
      elsif line =~ /\<.+\>/
        concept[:description] << line.delete("\n")
      end
    end
    @redis.set("vision", @concepts.to_json)
  end
end
