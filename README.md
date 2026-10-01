# decision-models-demo

Stage for Elbcasts #005: the same question asked of three models, measured
against real issues from `rails/rails` — the maintainers' own component labels
are the reference.

    export AI_GATEWAY_API_KEY=...   # only for the hosted models
    ruby llm.rb 100                 # gpt-4o-mini: prompt, JSON schema, parse
    ruby jev.rb 100                 # Jev (hosted): value plus probability
    uv tool install laya            # Laya runs locally, Apache-2.0
    python run_laya.py 100          # 421M ModernBERT, no API
    ruby report.rb                  # accuracy and threshold side by side

`issues.json`: 100 issues (title, body, component label), fetched with `gh`.
Every number in the episode comes from these 100.

`run-2026-09-26.json` and `run-laya-2026-10-01.json` are the recorded runs, so
the numbers can be checked without a key and without a GPU. `report.rb` uses a
fresh run only when it covers all 100 issues; a shorter live run falls back to
the recording and says so.

Do not name the Laya script `laya.py` — it would import itself.
