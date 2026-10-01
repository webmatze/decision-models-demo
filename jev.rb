# Jev (hosted): send a state and typed questions, get a value and a probability.
# Early access is often rate limited, so every answer is written out immediately
# and missing ones are retried in rounds.
require "json"; require "net/http"; require "uri"

URL = URI("https://ai-gateway.vercel.sh/v1/evaluate")
QUESTION = "Is this GitHub issue about Active Record (models, migrations, queries, the database layer)?"
OUT = "jev.json"

def ask(state)
  req = Net::HTTP::Post.new(URL, "Authorization" => "Bearer #{ENV.fetch('AI_GATEWAY_API_KEY')}",
                                 "Content-Type" => "application/json")
  req.body = JSON.generate(model: "typesafe-ai/jev", state: state,
                           questions: { active_record: { type: "boolean", instructions: QUESTION } })
  t = Time.now
  res = Net::HTTP.start(URL.host, URL.port, use_ssl: true, read_timeout: 90) { |h| h.request(req) }
  [JSON.parse(res.body), ((Time.now - t) * 1000).round]
rescue StandardError => e
  [{ "error" => { "message" => e.message } }, 0]
end

issues = JSON.parse(File.read("issues.json")).first(Integer(ARGV.fetch(0, 20)))
rounds = Integer(ARGV.fetch(1, 20))
pause  = Integer(ARGV.fetch(2, 120))
done = File.exist?(OUT) ? JSON.parse(File.read(OUT)).to_h { |r| [r["number"], r] } : {}

rounds.times do |round|
  open = issues.reject { |i| done.dig(i["number"], "probability") }
  break warn("done: #{issues.size} answers") if open.empty?

  warn "round #{round + 1}/#{rounds}: #{open.size} left"
  open.each do |i|
    body, ms = ask("Title: #{i['title']}\n\n#{i['body']}")
    answer = body.dig("answers", "active_record")
    if answer
      done[i["number"]] = { "number" => i["number"], "truth" => i["label"] == "activerecord",
                            "probability" => answer["probability"], "ms" => ms,
                            "tokens" => body.dig("usage", "input_tokens") }
      print answer["probability"] >= 0.5 ? "A" : "."
    else
      print "x"   # rate limited or an error: the next round tries again
    end
    File.write(OUT, JSON.pretty_generate(done.values))
  end
  puts
  sleep pause unless round == rounds - 1
end
