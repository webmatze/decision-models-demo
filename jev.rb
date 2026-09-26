# Jev: typisierte Frage rein, Wert und Wahrscheinlichkeit raus. Nichts zu parsen.
require "json"; require "net/http"; require "uri"; require "benchmark"

URL = URI("https://ai-gateway.vercel.sh/v1/evaluate")
FRAGE = "Is this GitHub issue about Active Record (models, migrations, queries, the database layer)?"

def ask(state)
  req = Net::HTTP::Post.new(URL, "Authorization" => "Bearer #{ENV.fetch('AI_GATEWAY_API_KEY')}",
                                 "Content-Type" => "application/json")
  req.body = JSON.generate(model: "typesafe-ai/jev", state: state,
                           questions: { active_record: { type: "boolean", instructions: FRAGE } })
  res = Net::HTTP.start(URL.host, URL.port, use_ssl: true, read_timeout: 60) { |h| h.request(req) }
  body = JSON.parse(res.body)
  [body.dig("answers", "active_record", "probability"), body.dig("usage", "inputTokens"), body["error"]]
end

issues = JSON.parse(File.read("issues.json")).first(Integer(ARGV.fetch(0, 20)))
rows = []
busy = 0
seconds = Benchmark.realtime do
  issues.each do |i|
    probability, tokens, error = ask("Title: #{i['title']}\n\n#{i['body']}")
    if error
      busy += 1
      print "x"
      next
    end
    rows << { "number" => i["number"], "truth" => i["label"] == "activerecord",
              "probability" => probability, "tokens" => tokens }
    print probability >= 0.5 ? "A" : "."
  end
end
File.write("jev.json", JSON.pretty_generate(rows))
puts "\n#{rows.size} Antworten in #{seconds.round(1)}s#{busy.positive? ? ", #{busy}x beschaeftigt (429)" : ""}"
