# Three models, the same issues, the same truth. A fresh run that is shorter
# than the recorded one (a short live demo) falls back to the recorded run.
require "json"

MEASURED = 100
FALLBACK = []

def load_rows(fresh, recorded, key)
  rows = (JSON.parse(File.read(fresh)) rescue [])
  return rows if rows.size >= MEASURED

  FALLBACK << fresh
  raw = JSON.parse(File.read(recorded))
  raw = raw.values if raw.is_a?(Hash)
  raw.select { |r| r[key] }
     .map { |r| { "truth" => r["truth"], "probability" => r[key], "tokens" => r["#{key[0, 3]}_tokens"] || r["tokens"] } }
end

llm = (JSON.parse(File.read("llm.json")) rescue []).map { |r| { "truth" => r["truth"], "probability" => r["verdict"] ? 1.0 : 0.0, "tokens" => r["tokens"] } }
llm = load_rows("llm.json", "run-2026-09-26.json", "llm_p") if llm.size < MEASURED
jev = load_rows("jev.json", "run-2026-09-26.json", "jev_p")
laya = load_rows("laya.json", "run-laya-2026-10-01.json", "probability")
puts "recorded run used for: #{FALLBACK.join(', ')}" if FALLBACK.any?
