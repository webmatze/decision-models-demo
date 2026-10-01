# Drei Modelle, dieselben Issues, dieselbe Wahrheit. Fehlt ein frischer Lauf,
# nehmen wir den aufgezeichneten aus dem Repo.
require "json"

def laden(frisch, aufgezeichnet, schluessel)
  rows = (JSON.parse(File.read(frisch)) rescue [])
  return rows unless rows.empty?

  puts "#{frisch} fehlt -- nehme #{aufgezeichnet}"
  roh = JSON.parse(File.read(aufgezeichnet))
  roh = roh.values if roh.is_a?(Hash)
  roh.select { |r| r[schluessel] }
     .map { |r| { "truth" => r["truth"], "probability" => r[schluessel], "tokens" => r["#{schluessel[0, 3]}_tokens"] || r["tokens"] } }
end

llm = (JSON.parse(File.read("llm.json")) rescue []).map { |r| { "truth" => r["truth"], "probability" => r["verdict"] ? 1.0 : 0.0, "tokens" => r["tokens"] } }
llm = laden("llm.json", "run-2026-09-26.json", "llm_p") if llm.empty?
jev = laden("jev.json", "run-2026-09-26.json", "jev_p")
laya = laden("laya.json", "run-laya-2026-10-01.json", "probability")
