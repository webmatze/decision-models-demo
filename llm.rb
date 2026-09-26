# Der uebliche Weg: Prompt, JSON-Schema, Antwort parsen.
require "json"; require "net/http"; require "uri"; require "benchmark"

URL = URI("https://ai-gateway.vercel.sh/v1/chat/completions")
FRAGE = "Is this GitHub issue about Active Record (models, migrations, queries, the database layer)?"
SCHEMA = { type: "object", properties: { active_record: { type: "boolean" } },
           required: ["active_record"], additionalProperties: false }.freeze

def ask(state)
  req = Net::HTTP::Post.new(URL, "Authorization" => "Bearer #{ENV.fetch('AI_GATEWAY_API_KEY')}",
                                 "Content-Type" => "application/json")
  req.body = JSON.generate(
    model: "openai/gpt-4o-mini", max_tokens: 50,
    messages: [{ role: "user", content: "#{FRAGE} Answer JSON.\n\n#{state}" }],
    response_format: { type: "json_schema", json_schema: { name: "verdict", schema: SCHEMA, strict: true } }
  )
  res = Net::HTTP.start(URL.host, URL.port, use_ssl: true, read_timeout: 60) { |h| h.request(req) }
  body = JSON.parse(res.body)
  text = body.dig("choices", 0, "message", "content")
  [JSON.parse(text)["active_record"], body.dig("usage", "total_tokens")]   # und wehe, es ist kein JSON
end

issues = JSON.parse(File.read("issues.json")).first(Integer(ARGV.fetch(0, 20)))
rows = []
seconds = Benchmark.realtime do
  issues.each do |i|
    verdict, tokens = ask("Title: #{i['title']}\n\n#{i['body']}")
    rows << { "number" => i["number"], "truth" => i["label"] == "activerecord",
              "verdict" => verdict, "tokens" => tokens }
    print verdict ? "A" : "."
  end
end
File.write("llm.json", JSON.pretty_generate(rows))
puts "\n#{rows.size} Issues in #{seconds.round(1)}s, #{rows.sum { |r| r['tokens'].to_i }} Token"
