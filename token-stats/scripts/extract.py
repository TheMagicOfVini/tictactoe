#!/usr/bin/env python3
"""Extract token usage from Claude Code transcripts for the tictactoe project."""
import csv, glob, json, os, sys, collections, datetime

HOME = os.path.expanduser("~")
ROOTS = [
    os.path.join(HOME, ".claude/projects/-Users-tmov-repos-cryoport-tictactoe"),
    os.path.join(HOME, ".claude/projects/-Users-tmov-repos-cryoport-tictactoe-tictactoe"),
]
OUT = sys.argv[1] if len(sys.argv) > 1 else "token-stats"
os.makedirs(OUT, exist_ok=True)

# $ per million tokens: input, output, cache read, cache write 5m, cache write 1h
RATES = {
    "claude-fable-5-1":           (10.0, 50.0, 0.25, 12.5, 20.0),
    "claude-opus-5-5":            (4.0, 20.0, 0.20, 5.0, 8.0),
    "claude-sonnet-5":            (2.0, 10.0, 0.20, 2.5, 4.0),
    "claude-haiku-4-5-20251001":  (1.0, 5.0, 0.10, 1.25, 2.0),
}

def rate_cost(model, inp, out, cread, c5, c1):
    r = RATES.get(model)
    if not r:
        return None
    return (inp*r[0] + out*r[1] + cread*r[2] + c5*r[3] + c1*r[4]) / 1e6

def iter_records(path):
    with open(path) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                yield json.loads(line)
            except json.JSONDecodeError:
                continue

def user_prompt_text(msg):
    c = msg.get("content")
    if isinstance(c, str):
        return c
    if isinstance(c, list):
        texts = [b.get("text", "") for b in c if isinstance(b, dict) and b.get("type") == "text"]
        if any(isinstance(b, dict) and b.get("type") == "tool_result" for b in c):
            return None
        return "\n".join(texts) if texts else None
    return None

calls = {}          # message_id -> call dict (dedupe split records)
sessions = collections.OrderedDict()
cost_state = {}     # session -> last cost-state record
files_scanned = []

def session(sid):
    s = sessions.get(sid)
    if s is None:
        s = sessions[sid] = {
            "session_id": sid, "title": None, "slug": None, "first_prompt": None,
            "prompts": 0, "prompt_texts": [], "start": None, "end": None,
            "versions": set(), "branches": set(), "cwds": set(),
            "subagent_files": set(), "tool_results": 0, "user_records": 0,
        }
    return s

def scan(path, sid, source, agent_file=None):
    files_scanned.append(path)
    s = session(sid)
    if agent_file:
        s["subagent_files"].add(agent_file)
    for d in iter_records(path):
        t = d.get("type")
        ts = d.get("timestamp")
        if ts and source == "main":
            s["start"] = min(s["start"], ts) if s["start"] else ts
            s["end"] = max(s["end"], ts) if s["end"] else ts
        if t == "cost-state" and source == "main":
            cost_state[d.get("sessionId", sid)] = d
        elif t == "ai-title" and source == "main":
            s["title"] = d.get("aiTitle")
        elif t == "user":
            s["user_records"] += 1
            txt = user_prompt_text(d.get("message", {}))
            if txt is None:
                s["tool_results"] += 1
            elif source == "main" and not d.get("isMeta"):
                if txt.startswith("<command-name>") or txt.startswith("<local-command") or txt.startswith("<system-reminder"):
                    continue
                s["prompts"] += 1
                s["prompt_texts"].append(txt[:200].replace("\n", " "))
                if s["first_prompt"] is None:
                    s["first_prompt"] = txt[:200].replace("\n", " ")
        elif t == "assistant":
            m = d.get("message", {})
            u = m.get("usage")
            if not u:
                continue
            if d.get("version"): s["versions"].add(d["version"])
            if d.get("gitBranch"): s["branches"].add(d["gitBranch"])
            if d.get("cwd"): s["cwds"].add(d["cwd"])
            if d.get("slug") and not s["slug"]: s["slug"] = d["slug"]
            mid = m.get("id") or d.get("requestId") or d.get("uuid")
            content = m.get("content") if isinstance(m.get("content"), list) else []
            tools = [b.get("name") for b in content if isinstance(b, dict) and b.get("type") == "tool_use"]
            text_chars = sum(len(b.get("text", "")) for b in content if isinstance(b, dict) and b.get("type") == "text")
            all_chars = 0
            for b in content:
                if not isinstance(b, dict): continue
                if b.get("type") == "thinking": all_chars += len(b.get("thinking") or "")
                elif b.get("type") == "text": all_chars += len(b.get("text") or "")
                elif b.get("type") == "tool_use": all_chars += len(json.dumps(b.get("input", {})))
            if mid in calls:
                c = calls[mid]
                c["tools"].extend(tools)
                c["text_chars"] += text_chars
                c["content_chars"] += all_chars
                c["records"] += 1
                if m.get("stop_reason"):
                    c["stop_reason"] = m["stop_reason"]; c["usage_final"] = True
                cc = u.get("cache_creation") or {}
                for k, v in (("input_tokens", u.get("input_tokens", 0)), ("cache_creation_tokens", u.get("cache_creation_input_tokens", 0)),
                             ("cache_5m_tokens", cc.get("ephemeral_5m_input_tokens", 0)), ("cache_1h_tokens", cc.get("ephemeral_1h_input_tokens", 0)),
                             ("cache_read_tokens", u.get("cache_read_input_tokens", 0)), ("output_tokens_recorded", u.get("output_tokens", 0)),
                             ("thinking_tokens", (u.get("output_tokens_details") or {}).get("thinking_tokens", 0))):
                    c[k] = max(c[k], v or 0)
                continue
            cc = u.get("cache_creation") or {}
            c5 = cc.get("ephemeral_5m_input_tokens", 0) or 0
            c1 = cc.get("ephemeral_1h_input_tokens", 0) or 0
            inp = u.get("input_tokens", 0) or 0
            out = u.get("output_tokens", 0) or 0
            cr = u.get("cache_read_input_tokens", 0) or 0
            cw = u.get("cache_creation_input_tokens", 0) or 0
            think = (u.get("output_tokens_details") or {}).get("thinking_tokens", 0) or 0
            model = m.get("model")
            calls[mid] = {
                "message_id": mid, "request_id": d.get("requestId"), "session_id": sid,
                "source": source, "agent_file": agent_file or "",
                "timestamp": ts, "model": model, "effort": d.get("effort") or "",
                "input_tokens": inp, "cache_creation_tokens": cw,
                "cache_5m_tokens": c5, "cache_1h_tokens": c1,
                "cache_read_tokens": cr, "output_tokens_recorded": out, "thinking_tokens": think,
                "stop_reason": m.get("stop_reason") or "", "usage_final": bool(m.get("stop_reason")),
                "tools": list(tools), "text_chars": text_chars, "content_chars": all_chars, "records": 1,
                "cwd": d.get("cwd", ""), "git_branch": d.get("gitBranch", ""),
                "is_sidechain": bool(d.get("isSidechain")),
            }

for root in ROOTS:
    for path in sorted(glob.glob(os.path.join(root, "*.jsonl"))):
        sid = os.path.basename(path)[:-6]
        scan(path, sid, "main")
        for ap in sorted(glob.glob(os.path.join(root, sid, "subagents", "*.jsonl"))):
            scan(ap, sid, "subagent", os.path.basename(ap)[:-6])

# finalize: a message whose stream never wrote a final usage record only has the
# message_start usage (output_tokens ~ a few tokens). Estimate output from content size.
for c in calls.values():
    c["context_tokens"] = c["input_tokens"] + c["cache_creation_tokens"] + c["cache_read_tokens"]
    est_from_content = round(c["content_chars"] / 3.6)
    if c["usage_final"]:
        c["output_tokens"] = c["output_tokens_recorded"]; c["output_estimated"] = False
    else:
        c["output_tokens"] = max(c["output_tokens_recorded"], est_from_content); c["output_estimated"] = True
    c["est_cost_usd"] = rate_cost(c["model"], c["input_tokens"], c["output_tokens"], c["cache_read_tokens"], c["cache_5m_tokens"], c["cache_1h_tokens"])
call_list = sorted(calls.values(), key=lambda c: c["timestamp"] or "")

# ---- per-session aggregation ----
def blank_tot():
    return collections.Counter()

sess_rows = []
for sid, s in sessions.items():
    cs = cost_state.get(sid, {})
    mine = [c for c in call_list if c["session_id"] == sid]
    tot = blank_tot()
    by_model = collections.defaultdict(blank_tot)
    tools = collections.Counter()
    for c in mine:
        for k in ("input_tokens", "cache_creation_tokens", "cache_5m_tokens", "cache_1h_tokens",
                  "cache_read_tokens", "output_tokens", "thinking_tokens"):
            tot[k] += c[k]; by_model[c["model"]][k] += c[k]
        tot["calls"] += 1; by_model[c["model"]]["calls"] += 1
        if c["source"] == "subagent": tot["subagent_calls"] += 1
        if c["output_estimated"]: tot["output_estimated_calls"] += 1
        tot["est_cost_usd"] += c["est_cost_usd"] or 0
        by_model[c["model"]]["est_cost_usd"] += c["est_cost_usd"] or 0
        tools.update(c["tools"])
    start = s["start"]; end = s["end"]
    dur = None
    if start and end:
        dur = (datetime.datetime.fromisoformat(end.replace("Z", "+00:00")) -
               datetime.datetime.fromisoformat(start.replace("Z", "+00:00"))).total_seconds()
    peak_ctx = max((c["context_tokens"] for c in mine if c["source"] == "main"), default=0)
    sess_rows.append({
        "session_id": sid,
        "title": s["title"] or s["slug"] or (s["first_prompt"] or "")[:60],
        "slug": s["slug"], "first_prompt": s["first_prompt"],
        "start": start, "end": end, "wall_seconds": dur,
        "prompts": s["prompts"], "tool_results": s["tool_results"],
        "calls": tot["calls"], "subagent_calls": tot["subagent_calls"], "output_estimated_calls": tot["output_estimated_calls"],
        "subagents": len(s["subagent_files"]),
        "input_tokens": tot["input_tokens"], "cache_creation_tokens": tot["cache_creation_tokens"],
        "cache_5m_tokens": tot["cache_5m_tokens"], "cache_1h_tokens": tot["cache_1h_tokens"],
        "cache_read_tokens": tot["cache_read_tokens"], "output_tokens": tot["output_tokens"],
        "thinking_tokens": tot["thinking_tokens"],
        "total_tokens": tot["input_tokens"] + tot["cache_creation_tokens"] + tot["cache_read_tokens"] + tot["output_tokens"],
        "peak_context_tokens": peak_ctx,
        "est_cost_usd": round(tot["est_cost_usd"], 4),
        "reported_cost_usd": cs.get("totalCostUSD"),
        "api_seconds": (cs.get("totalAPIDuration") or 0) / 1000 if cs else None,
        "tool_seconds": (cs.get("totalToolDuration") or 0) / 1000 if cs else None,
        "lines_added": cs.get("totalLinesAdded"), "lines_removed": cs.get("totalLinesRemoved"),
        "models": ", ".join(sorted(k for k in by_model if k)),
        "by_model": {k: dict(v) for k, v in by_model.items()},
        "reported_model_usage": cs.get("modelUsage"),
        "tools": dict(tools.most_common()),
        "versions": sorted(s["versions"]), "branches": sorted(s["branches"]),
    })
sess_rows.sort(key=lambda r: r["start"] or "")

# ---- global aggregation ----
grand = blank_tot(); by_model = collections.defaultdict(blank_tot)
by_effort = collections.defaultdict(blank_tot); by_hour = collections.defaultdict(blank_tot)
by_tool = collections.Counter(); by_source = collections.defaultdict(blank_tot)
by_stop = collections.Counter()
for c in call_list:
    for k in ("input_tokens", "cache_creation_tokens", "cache_5m_tokens", "cache_1h_tokens",
              "cache_read_tokens", "output_tokens", "thinking_tokens"):
        grand[k] += c[k]; by_model[c["model"]][k] += c[k]
        by_effort[c["effort"] or "unknown"][k] += c[k]; by_source[c["source"]][k] += c[k]
        if c["timestamp"]:
            by_hour[c["timestamp"][:13]][k] += c[k]
    for b in (grand, by_model[c["model"]], by_effort[c["effort"] or "unknown"], by_source[c["source"]]):
        b["calls"] += 1; b["est_cost_usd"] += c["est_cost_usd"] or 0
    if c["timestamp"]:
        by_hour[c["timestamp"][:13]]["calls"] += 1
        by_hour[c["timestamp"][:13]]["est_cost_usd"] += c["est_cost_usd"] or 0
    by_tool.update(c["tools"]); by_stop[c["stop_reason"] or "no_final_record"] += 1
    if c["output_estimated"]: grand["output_estimated_calls"] += 1; by_model[c["model"]]["output_estimated_calls"] += 1

reported_total = sum((cs.get("totalCostUSD") or 0) for cs in cost_state.values())
reported_by_model = collections.defaultdict(blank_tot)
for cs in cost_state.values():
    for m, u in (cs.get("modelUsage") or {}).items():
        for k, v in u.items():
            reported_by_model[m][k] += v

stats = {
    "generated_at": datetime.datetime.now(datetime.timezone.utc).isoformat(),
    "project": "/Users/tmov/repos/cryoport/tictactoe",
    "transcript_roots": ROOTS, "files_scanned": len(files_scanned),
    "rates_usd_per_mtok": {k: dict(zip(["input", "output", "cache_read", "cache_write_5m", "cache_write_1h"], v)) for k, v in RATES.items()},
    "totals": dict(grand),
    "totals_extra": {
        "sessions": len(sess_rows), "prompts": sum(r["prompts"] for r in sess_rows),
        "subagent_runs": sum(r["subagents"] for r in sess_rows),
        "reported_cost_usd": reported_total,
        "total_tokens": grand["input_tokens"] + grand["cache_creation_tokens"] + grand["cache_read_tokens"] + grand["output_tokens"],
        "first_call": call_list[0]["timestamp"] if call_list else None,
        "last_call": call_list[-1]["timestamp"] if call_list else None,
    },
    "by_model": {k: dict(v) for k, v in by_model.items()},
    "reported_by_model": {k: dict(v) for k, v in reported_by_model.items()},
    "by_effort": {k: dict(v) for k, v in by_effort.items()},
    "by_source": {k: dict(v) for k, v in by_source.items()},
    "by_hour": {k: dict(v) for k, v in sorted(by_hour.items())},
    "by_tool": dict(by_tool.most_common()),
    "by_stop_reason": dict(by_stop),
    "sessions": sess_rows,
}

with open(os.path.join(OUT, "stats.json"), "w") as f:
    json.dump(stats, f, indent=1, default=list)

call_fields = ["timestamp", "session_id", "source", "agent_file", "model", "effort",
               "input_tokens", "cache_creation_tokens", "cache_5m_tokens", "cache_1h_tokens",
               "cache_read_tokens", "output_tokens", "output_tokens_recorded", "output_estimated", "thinking_tokens", "context_tokens",
               "est_cost_usd", "stop_reason", "usage_final", "records", "tools", "text_chars", "content_chars", "git_branch", "cwd",
               "message_id", "request_id"]
with open(os.path.join(OUT, "calls.csv"), "w", newline="") as f:
    w = csv.DictWriter(f, fieldnames=call_fields, extrasaction="ignore", lineterminator="\n")
    w.writeheader()
    for c in call_list:
        row = dict(c); row["tools"] = "|".join(c["tools"])
        row["est_cost_usd"] = round(c["est_cost_usd"], 6) if c["est_cost_usd"] is not None else ""
        w.writerow(row)

sess_fields = ["start", "end", "wall_seconds", "session_id", "title", "prompts", "calls", "subagent_calls",
               "subagents", "output_estimated_calls", "input_tokens", "cache_creation_tokens", "cache_5m_tokens", "cache_1h_tokens",
               "cache_read_tokens", "output_tokens", "thinking_tokens", "total_tokens", "peak_context_tokens",
               "est_cost_usd", "reported_cost_usd", "api_seconds", "tool_seconds", "lines_added",
               "lines_removed", "models", "first_prompt"]
with open(os.path.join(OUT, "sessions.csv"), "w", newline="") as f:
    w = csv.DictWriter(f, fieldnames=sess_fields, extrasaction="ignore", lineterminator="\n")
    w.writeheader()
    for r in sess_rows:
        w.writerow(r)

# ---- console summary ----
print(f"files scanned: {len(files_scanned)}  sessions: {len(sess_rows)}  calls: {len(call_list)}")
print("totals:", dict(grand))
print(f"est cost ${grand['est_cost_usd']:.2f}  reported cost ${reported_total:.2f}")
for m, v in by_model.items():
    r = reported_by_model.get(m, {})
    print(f"  {m}: calls={v['calls']} in={v['input_tokens']} cw={v['cache_creation_tokens']} cr={v['cache_read_tokens']} out={v['output_tokens']} est=${v['est_cost_usd']:.2f} reported=${r.get('costUSD',0):.2f} reported_out={r.get('outputTokens')}")
print("effort:", {k: (v['calls'], round(v['est_cost_usd'],2)) for k, v in by_effort.items()})
print("source:", {k: (v['calls'], round(v['est_cost_usd'],2)) for k, v in by_source.items()})
print("stop:", dict(by_stop))
print("tools:", by_tool.most_common(15))
for r in sess_rows:
    print(f"  {r['start'][11:16] if r['start'] else '?'} {r['session_id'][:8]} calls={r['calls']:4d} sub={r['subagent_calls']:3d} prompts={r['prompts']:3d} peak={r['peak_context_tokens']:7d} est=${r['est_cost_usd']:6.2f} rep=${(r['reported_cost_usd'] or 0):6.2f} {r['models']} | {r['title']}")
