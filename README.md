# decision-models-demo

Bühne für Elbcasts #005: dieselbe Frage an drei Modelle, gemessen an echten
Issues aus `rails/rails` — die Labels der Maintainer sind die Referenz.

    export AI_GATEWAY_API_KEY=...   # nur für die gehosteten Modelle
    ruby llm.rb 100                 # gpt-4o-mini: Prompt, JSON-Schema, parsen
    ruby jev.rb 100                 # Jev (gehostet): Wert + Wahrscheinlichkeit
    uv tool install laya            # Laya laeuft lokal, Apache-2.0
    python run_laya.py              # 421M ModernBERT, keine API
    ruby report.rb                  # Trefferquote und Schwelle nebeneinander

`issues.json`: 120 Issues (Titel, Text, Komponenten-Label), geholt mit `gh`.
