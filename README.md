# jev-demo

Bühne für Elbcasts #005: dieselbe Frage an ein LLM und an Jev (TypeSafe AI),
gemessen an echten Issues aus `rails/rails` — die Labels der Maintainer sind
die Referenz.

    export AI_GATEWAY_API_KEY=...   # Vercel AI Gateway
    ruby llm.rb 20                  # klassisch: Prompt, JSON-Schema, parsen
    ruby jev.rb 20                  # typisiert: Wert + Wahrscheinlichkeit
    ruby report.rb                  # Trefferquote, Token, Schwelle

`issues.json`: 120 Issues (Titel, Text, Komponenten-Label), geholt mit `gh`.
