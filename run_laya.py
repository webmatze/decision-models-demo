# Laya runs locally: 421M parameters, Apache-2.0, no network, no key.
import json, sys, time, laya

agent = laya.load("convaiinnovations/laya")
QUESTIONS = {"active_record": {"type": "noul", "instructions":
             "Is this GitHub issue about Active Record (models, migrations, queries, the database layer)?"}}

count = int(sys.argv[1]) if len(sys.argv) > 1 else 100
issues = json.load(open("issues.json"))[:count]
rows = []
for i in issues:
    state = "Title: %s\n\n%s" % (i["title"], i["body"])
    t = time.time()
    out = laya.decide(agent, state, questions=QUESTIONS, return_details=True)
    rows.append({"number": i["number"], "truth": i["label"] == "activerecord",
                 "probability": out.probabilities["active_record"]["true"],
                 "ms": round((time.time() - t) * 1000),
                 "tokens": out.usage["input_tokens"]})
    print("A" if rows[-1]["probability"] >= 0.5 else ".", end="", flush=True)

json.dump(rows, open("laya.json", "w"), indent=1)
ms = sorted(r["ms"] for r in rows)
print("\n%d answers, median %d ms, no network" % (len(rows), ms[len(ms) // 2]))
