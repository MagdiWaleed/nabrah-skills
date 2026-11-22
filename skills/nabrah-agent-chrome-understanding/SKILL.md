---
name: "nabrah-agent-chrome-understanding"
description: "Given a Nabrah agent URL, read its whole config in Chrome strictly read-only and output agent_overview.md (all fields verbatim) plus an Overview artifact with use cases, flow diagram and tool I/O."
---

# Nabrah Agent — Chrome Understanding (read-only)

Input: a Nabrah agent edit URL, e.g.
`https://app.nabrah.ai/en/agents/workspaces/<workspace_id>/agents/<agent_id>/edit`

Output — TWO deliverables, both every run:
1. **`agent_overview.md`**: every field from the editor, verbatim, organised by the editor's own sections (Step 5). Send it with SendUserFile.
2. **Overview artifact**: published page explaining the agent with use cases, conversation-flow diagram, tools with inputs/outputs, and settings (Step 6).

Plus a short summary in chat.

## HARD RULE: READ-ONLY
This skill never changes anything on the Nabrah platform.
- NEVER click: Save changes, Continue (on the final step), Edit, Delete, Link agent, New tool, Add *, Publish, Test call, or any toggle/checkbox.
- NEVER type into any field, filter box included.
- NEVER call agent tools or APIs (e.g. BookDemo would create a real booking). Never call the Nabrah API directly, and never read auth tokens from storage.
- ALLOWED: navigate to URLs, click section-nav buttons (Identity, Knowledge, …) and expand/collapse toggles, read the DOM with `get_page_text` / `read_page` / `find`, and use `javascript_tool` for **read-only** DOM queries only (no `.click()`, no value setting, no `fetch`).
- If a section can only be reached by a state-changing action, skip it and mention it in the chat reply.

## Step 1 — Chrome setup
Load the `chrome-browser` skill, then do ONE ToolSearch:
`select:mcp__claude-in-chrome__tabs_context_mcp,mcp__claude-in-chrome__tabs_create_mcp,mcp__claude-in-chrome__navigate,mcp__claude-in-chrome__get_page_text,mcp__claude-in-chrome__read_page,mcp__claude-in-chrome__find,mcp__claude-in-chrome__computer,mcp__claude-in-chrome__javascript_tool,mcp__claude-in-chrome__tabs_close_mcp`

`tabs_context_mcp(createIfEmpty)`, then use your own tab and `navigate` to the URL. If you land on a login page, stop and ask the user to sign in.

## Step 2 — Read every editor section
The agent editor has 7 sections in a left nav: **Identity & persona · Knowledge · Audio & language · Tags · Tools & analysis · Webhooks · Review**. Use `find` to get the nav button refs, then for each section:

1. Click the nav button (navigation only).
2. `get_page_text` gives labels and structure (it does NOT include field values).
3. Read the values with this read-only extractor. Define it once:
```js
window.__grab=()=>{const root=document.querySelector('main');
const labelOf=el=>{let p=el.parentElement;for(let i=0;i<5&&p;i++){const l=p.querySelector('label');if(l&&!l.contains(el))return l.innerText.trim();p=p.parentElement;}return el.getAttribute('aria-label')||el.placeholder||'';};
return JSON.stringify({
 fields:[...root.querySelectorAll('input:not([type=checkbox]):not([type=radio]):not([type=hidden]),textarea,[contenteditable=true]')].map(el=>({label:labelOf(el),value:el.value??el.innerText})).filter(x=>String(x.value).trim()),
 toggles:[...root.querySelectorAll('[aria-checked],input[type=checkbox]')].map(el=>({text:(el.closest('label')||el.parentElement).innerText.trim().slice(0,60),state:el.getAttribute('aria-checked')??el.checked})),
 ranges:[...root.querySelectorAll('[role=slider]')].map(el=>({label:labelOf(el),value:el.getAttribute('aria-valuenow')}))});};
window.__s=window.__grab(); window.__s.length
```
4. **Results get cut off at about 1,000 Arabic characters.** Read `window.__s.slice(0,1000)`, `slice(1000,2000)`, … in parallel calls until you reach the length, then stitch the pieces together. Copy text verbatim.

Notes per section:
- **Identity:** display name, type, voice, languages (with on/off state), speaks-first, interruptions, First sentence, Identity, Purpose and boundaries, Workflow, model stack, speech speed, max duration.
- **Knowledge:** Reference knowledge (long, so chunk it) plus linked KBs.
- **Tools & analysis:** custom tools and analysis groups with linked state, built-in tools, transfer settings (prompt, type, destination, SIP), ticketing on/off and its instructions. Built-in tool on/off isn't exposed in the DOM, so take it from the **Review** section.
- **Webhooks:** template variables; pre-call, post-call and post-analysis URLs (the inputs appear in that order); parameters. Replace any keys/tokens with `<redacted>`.
- **Review:** a read-only summary. Use it to cross-check every on/off state. Do NOT click "Save changes".

## Step 3 — Read linked tool definitions
For each linked custom tool:
1. `navigate` to `https://app.nabrah.ai/en/agents/workspaces/<workspace_id>/tools`.
2. Find the tool's view link (read-only JS: list `main a` hrefs + text). Use the **view** URL, not `/edit`.
3. `navigate` to it and run `get_page_text`. Capture the method, URL, timeout, description, and every parameter (name, type, location header/query/body, required, mode `constant`/`llm_input`/`variable`, default, description, nested fields).

Tool **outputs** aren't defined in the UI. Infer the expected output and the agent's success/failure behaviour from the tool description and the workflow, and label it "expected (from prompt)". Never call the tool to find out.

Close your tab when done (`tabs_close_mcp`).

## Step 4 — Analyse (in your head; nothing is written to Nabrah)
From the captured text, work out:
- **Use cases:** each distinct caller intent the agent handles (e.g. product FAQ, pricing, book demo, transfer to human, support ticket, not interested), with trigger, outcome and tools used.
- **Conversation flow:** stages and branches from the Workflow field (greeting → intent → FAQ loop → interest check → branches → close), including tool calls, success/failure paths, retries and end-call points.
- **Tool I/O:** for each tool, what goes in (LLM-filled vs constant vs variable), when it's called, what comes back, and what the agent says next.

## Step 5 — Write `agent_overview.md`
Write it in the working dir with the Write tool. Mirror the editor exactly: same section names and order, same field labels as on screen, values copied **verbatim** (full Arabic text, original line breaks, no summarising). Long text goes in fenced code blocks; short values go in tables. Empty fields: `—`. Keys and tokens: `<redacted>`.

```markdown
# <Display name> — Agent Overview
- URL: <edit url>
- Captured: <date time, Asia/Riyadh> (read-only)
- Editor version: <v1…>

## 1. Identity & persona
### Basics
| Field | Value |
|---|---|
| Display name | … |
| Agent type | … |
| Voice | … |
| Languages | Arabic ✅ · English ❌ · … (every option with its state) |
| Agent speaks first | Yes/No |
| Allow caller interruptions | Yes/No |
### Persona & script
#### First sentence
#### Identity
#### Purpose and boundaries
#### Workflow
(each in a ``` block, verbatim)
### Model & speech
| Model stack | Speech speed |
### Call limits
| Maximum call duration |

## 2. Knowledge
### Reference knowledge (<n> chars)
``` verbatim ```
### Knowledge bases

## 3. Audio & language
| Background ambience (on/off, volume) | Thinking sound (on/off, volume) |

## 4. Tags
| Enable tag extraction | Tagging instructions | Tags |

## 5. Tools & analysis
### Custom tools (every tool listed, ✅/❌ linked)
### Analysis groups (every group listed, ✅/❌ linked)
### Built-in tools (every tool, ✅/❌; states from Review)
#### Call transfer settings: when to use · transfer type · destination mode · destination (E.164) · SIP outbound number
### Ticketing: enable ticket creation · ticket creation instructions

## 6. Webhooks
### Template variables
### Pre-call webhook: callback URL · request parameters
### Post-call webhook: callback URL · request parameters
### Post-analysis webhook: callback URL · request parameters

## 7. Tool definitions (linked custom tools, from the Tools page)
### <ToolName> — `<METHOD> <url>` (<timeout>)
Description: > verbatim
| # | Param | Type | In | Req | Mode | Default/Value | Description |
(nested params as 2.1, 2.2 …)
Linked agents: …
```

No issues section, no "not captured" section.

## Step 6 — Build and publish the Overview artifact
Call `mcp__claude-artifacts__guide` (topics `pages`, `design`, `diagrams`) before writing. Build ONE self-contained HTML file in the working dir: `agent-<name>-overview.html`. RTL-aware: quote Arabic as-is with `dir="auto"`. Keep Arabic text out of SVG labels where possible (quote marks render out of order in mixed text); put Arabic quotes in the cards and tables instead.

Sections, in order:
1. **Header:** agent name, type, voice, languages, model, speed, max duration, captured date, a "read-only snapshot" note.
2. **What this agent does:** 2–3 sentences.
3. **Use cases:** cards, each with intent, example caller line, outcome, tools used.
4. **Conversation flow diagram:** hand-drawn **inline SVG** (no Mermaid; it won't render). Top-to-bottom flow with stages as boxes, decisions as diamonds, tool calls as a distinct shape/colour, and labelled arrows ("interested", "slot free", "booking failed ×2", "wants human"). Mark end-call nodes. Add a legend, and wrap the SVG in `<figure>` with a `<figcaption>`.
5. **Tool sequence diagram (inline SVG):** Caller ↔ Agent ↔ Tool lanes for the main tool path (e.g. GetAvailability → BookDemo → post-analysis webhook), with labelled request (solid) and response (dashed) arrows.
6. **Tools — inputs & outputs:** one block per tool covering endpoint, method, timeout and description, then a params table (param, in, mode, required, default, description), then "called when / expected output / agent then". Also cover built-in tools (transfer: when, type, destination), ticketing, and webhooks.
7. **Other settings:** audio, tags, KBs, analysis groups, webhooks/variables.

No issues section, no "not captured" section, no source footer.

Tip: generate the SVGs with a small Python script (box/diamond/path helpers on a fixed grid) and inject them into the HTML template; take one headless-Chrome screenshot to check, then publish.

Publish with `mcp__claude-artifacts__publish_files` (title: `<agent name> Overview`, icon: `diagram`). Re-running for the same agent: republish to the existing artifact (slug + base_version) instead of creating a new one.

## Step 7 — Deliver and reply
1. `SendUserFile` with `agent_overview.md`.
2. The Overview artifact card shows automatically after publishing.
3. Reply in two or three lines: what the agent is, its main use cases, and "read-only, nothing was changed". Don't repeat the artifact link. Offer next steps only as offers (e.g. audit/patch with `nabrah-voice-agent-builder` using `agent_overview.md` as the source); never act on them unasked.