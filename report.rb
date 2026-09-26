# Was ist herausgekommen: Trefferquote, Zeit, Kosten -- und was eine Schwelle bringt.
require "json"

def quote(rows, &sicher)
  treffer = rows.count { |r| r["hit"] }
  [rows.size, treffer, (100.0 * treffer / [rows.size, 1].max).round]
end

llm = JSON.parse(File.read("llm.json")).each { |r| r["hit"] = (r["verdict"] == r["truth"]) }
jev = JSON.parse(File.read("jev.json")).each { |r| r["hit"] = ((r["probability"] >= 0.5) == r["truth"]) }

n, t, q = quote(llm); puts "LLM  #{t}/#{n} richtig (#{q}%), #{llm.sum { |r| r['tokens'].to_i }} Token"
n, t, q = quote(jev); puts "Jev  #{t}/#{n} richtig (#{q}%), #{jev.sum { |r| r['tokens'].to_i }} Token"

puts
puts "Schwelle: wie viel laeuft automatisch, wie gut ist es?"
[0.5, 0.8, 0.9, 0.95].each do |s|
  sicher = jev.select { |r| r["probability"] >= s || r["probability"] <= 1 - s }
  next if sicher.empty?

  richtig = sicher.count { |r| r["hit"] }
  anteil = (100.0 * sicher.size / jev.size).round
  puts format("  ab %.2f: %2d von %2d automatisch (%3d%%), davon richtig %2d (%3d%%)",
              s, sicher.size, jev.size, anteil, richtig, (100.0 * richtig / sicher.size).round)
end
