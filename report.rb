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

table = { "gpt-4o-mini" => llm, "Jev (hosted)" => jev, "Laya (local)" => laya }
table.each do |name, rows|
  rows.each { |r| r["hit"] = ((r["probability"] >= 0.5) == r["truth"]) }
  puts format("%-13s %3d/%-3d correct", name, rows.count { |r| r["hit"] }, rows.size)
end

puts
puts "How much runs unattended, and is it right?"
table.except("gpt-4o-mini").each do |name, rows|
  [0.9, 0.95].each do |s|
    sure = rows.select { |r| r["probability"] >= s || r["probability"] <= 1 - s }
    next if sure.empty?

    puts format("  %-12s %.2f+ %3d/%d unattended, %3d right",
                name, s, sure.size, rows.size, sure.count { |r| r["hit"] })
  end
end
