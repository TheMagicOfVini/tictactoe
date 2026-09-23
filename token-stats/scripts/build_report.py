import json, csv, sys, os
out = sys.argv[1]; tpl = sys.argv[2]
stats = json.load(open(os.path.join(out, "stats.json")))
calls = []
with open(os.path.join(out, "calls.csv")) as f:
    for r in csv.DictReader(f):
        calls.append({"ts": r["timestamp"], "sid": r["session_id"], "src": r["source"], "model": r["model"],
                      "ctx": int(r["context_tokens"]), "out": int(r["output_tokens"]), "cw": int(r["cache_creation_tokens"]),
                      "cost": float(r["est_cost_usd"] or 0)})
data = json.dumps({"stats": stats, "calls": calls}, separators=(",", ":")).replace("</", "<\\/")
html = open(tpl).read().replace("__DATA__", data)
open(os.path.join(out, "report.html"), "w").write(html)
print("wrote", os.path.join(out, "report.html"), len(html), "bytes")
