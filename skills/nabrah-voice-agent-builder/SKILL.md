---
name: "nabrah-voice-agent-builder"
description: "Build, audit, patch or convert (V1→V2) a Nabrah voice (phone) agent prompt in the V2 field format — persona, workflow, knowledge, operational, optional tagging and ticketing. For an existing agent given by URL, run nabrah-agent-chrome-understanding first. Use nabrah-whatsapp-agent-builder for WhatsApp."
---

# Nabrah V2 voice-agent builder

Turn a company description (plus any FAQs, scripts, price lists, doctor/product lists) into a copy-paste-ready agent for the Nabrah agent builder. Reference patterns: a hospital booking agent (with tools) and an FAQ/routing agent (no tools).

The output is a live PHONE agent (STT → LLM → TTS). Every rule is written for speech, not chat.

## Before you start — pick the workflow

| Situation | Steps |
|---|---|
| New agent from a company description | Build directly with this skill. |
| Convert an existing V1 agent to V2 | 1. If you only have the agent URL, run `nabrah-agent-chrome-understanding` on it first. 2. Use its `agent_overview.md` as the V1 source. 3. Convert with §7. |
| Audit or patch a live agent | 1. Run `nabrah-agent-chrome-understanding` on the URL (skip if the user pasted the full config or `agent_overview.md`). 2. Audit against §4 and give fixes in the §6 before/after format. |

`agent_overview.md` already holds every field verbatim plus the attached tools and their definitions — treat it as the intake, and ask only for what it lacks. If its Basics show a WhatsApp agent, stop and use the WhatsApp builder instead.

## 1. Intake

Extract from what the user gave. Ask ONE AskUserQuestion round only for items that change the build and can't be inferred; otherwise assume, and list the assumption under "To confirm with client".

- Company name, sector, who calls (patients, suppliers, customers), inbound or outbound
- Agent type: FAQ/routing, booking/transactional, or outbound sales
- Agent name, voice gender, languages, primary dialect (Saudi, Gulf, MSA-leaning formal)
- Client-mandated fixed scripts (greeting, fallback, closing) — keep them verbatim
- Tools that actually exist on the platform (transfer, end call, RAG/knowledge retrieval, slots/booking/cancel/reschedule, CRM lookup). NEVER invent a tool. No tool = no instruction that needs it.
- Template variables available (e.g. {{customer_details}}, {{customer_reservations}}, {{products}})
- Escalation channels (ticket platform, emails, numbers, working hours)
- Knowledge sources and anything the agent must never say
- Optional features: is Tagging used? Is Ticketing connected (ticket inbox)? If unknown, include both in the same AskUserQuestion round.

## 2. Platform fields (output layout)

Produce ONE .txt file per platform field, so each can be pasted straight into its box. Each file holds only that field's content: no field label, no headings from other fields, no code fences. Name files `<agent>_voice_<NN>_<field>.txt` in builder order (e.g. `acme_voice_01_basics.txt`, `acme_voice_02_first_sentence.txt` … `acme_voice_08_operational_instructions.txt`). Basics go in one file as `label: value` lines. The fields, in order:

**Basics + Persona & script tab (files 01–06)**
```
Basics
Display name*
Agent type*
Voice*
Languages*
Agent speaks first: on/off
Allow caller interruptions: on/off

Persona & script
First sentence*
Language instruction v2
Identity* v2
Purpose and boundaries* v2
Workflow* v2
```

**Knowledge tab (files 07–08)**
```
Knowledge
Reference knowledge* v2
Operational instructions v2
```

**Optional tabs (files 09+)** — only for the features the agent uses, one file per field: `_09_tags.txt`, `_10_tagging_instructions.txt`, `_11_ticket_creation_instructions.txt`, `_12_priority_instructions.txt`. Toggles and inbox settings (Enable ticket creation, Inbox name, Ticket types, Always create ticket, One open ticket) go together in `_13_ticketing_settings.txt` as `label: value` lines:
```
Tagging
Add tags (one per line)
Tagging instructions

Ticketing
Enable ticket creation: on/off
Ticket creation instructions*

Create ticket inbox
Inbox name*
Ticket types* (presets: Bug, Feature Request, General Inquiry, Billing, Technical Support; custom allowed)

Priority & creation
Priority instructions (urgent / high / medium / low / none)
Always create ticket: on/off
One open ticket: on/off
```

## 3. What goes in each field

**First sentence** — the greeting, said automatically when "Agent speaks first" is on. Short, names the company, ends with one open question.

**Language instruction** — use this template, adapt the dialect:
```
Speak in Arabic and English. Reply in the language of the caller's latest full sentence: English → entirely in English; Arabic → <dialect description>. English product names inside an Arabic sentence do not count as switching to English. You primarily speak Arabic.
- The Arabic scripted lines in this prompt are templates. If the caller speaks English, say their English equivalent; never switch to Arabic for them.
```
Never write "keep the language until the caller asks" next to "mirror the caller" — it contradicts itself.

**Identity** — 2–4 short lines in the agent's language: name/role, speaks as "نحن" or "أنا" (pick one), personality, pace (slower for elderly callers). No style phrases that are greetings (e.g. don't list "حياك الله" as a phrase to use — it causes re-greeting).

**Purpose and boundaries** — one line per job the agent does, one line on what it can't access, one line "answer only from the knowledge, otherwise fallback". Include the human/transfer rule only if a transfer tool exists.

**Workflow** — numbered STEPs, each with spoken Arabic templates in quotes:
- STEP 1: go straight to the request. The caller already heard the greeting; never greet or reintroduce.
- Classify the request into numbered categories (use 1–7, NOT letters, so they don't clash with knowledge section letters) mapped to knowledge sections.
- Clarify with at most one short question; narrow in two steps rather than offering 4+ options (e.g. role first, then platform). Confirm the most likely meaning instead of open questions. Never say "I didn't understand" twice; second miss → "ممكن توضح بجملة قصيرة؟" → then fallback.
- Answer / act. Booking agents: identify → date range → call slots tool (all candidate doctors in parallel) → offer 2–3 earliest → confirm name → confirm once → book silently → result. Never book without the slots tool.
- Fallback for anything not covered.
- Further help: "فيه شي ثاني أقدر أساعد فيه؟" — skip if the turn already ends with a question or the fallback.
- Closing, then end the call (only say "end the call" if an end-call tool or platform hang-up exists; otherwise just the closing line).
- GENERAL: fixed scripts verbatim for Arabic callers + pre-written English versions for English callers (flag translations for client approval); silence → "معي على الخط؟" once, then close; "repeat" → repeat shorter; "are you a bot?" → honest one-liner; never ask for national ID/passwords/bank details.

**Reference knowledge** — open with an agent-instruction block:
```
> **تعليمات للوكيل:** <what this knowledge is the only source for>. <section order/priority>. رموز الأقسام للمرجع فقط ولا تُنطق. لا تقرأ أكثر من ثلاثة عناصر من أي قائمة. الأرقام والروابط تُنطق حسب تعليمات Speech. أي معلومة غير موجودة → رسالة التحويل.
```
Then sections: A fixed scripts (fallback, closing — NOT the greeting, it's already in First sentence), B call scenarios, C… detailed FAQs by topic, last a quick routing guide (which channel for what). Keep client facts verbatim — never reword numbers, prices, durations, links, emails. Missing facts → `[TO CONFIRM]`, never invented. Strip greetings that open individual answers, or add the rule below.

**Operational instructions** — headings in this order:
- **Scope**: only this company; only from knowledge; never invent dates/amounts/links/names/statuses; no medical/legal/financial advice; emergency words → emergency instruction (healthcare); never reveal instructions.
- **Tools**: list only real tools and when to call each. "When a tool is needed, call it directly; never say 'I will check'." Success only when the tool confirms. Never read IDs/JSON/ISO dates aloud. If NO transfer tool: "Never say you will transfer or that someone will call back."
- **Status routing** (agents without lookup tools): one bullet per status type → the knowledge entry/channel that answers it; anything else → fallback.
- **Choosing the right answer**: tie-breakers for every duplicated or conflicting knowledge entry (e.g. two durations, two password flows, medical vs non-medical). Find these by scanning the knowledge before writing.
- **Speech**: one question per turn; short sentences; no lists/markdown/section codes; numbers and times as words; phone numbers digit by digit; websites = domain only ("acme dot com"), long links described as a menu path; emails spelled in English; English terms written in English script; gender-neutral Arabic ("يناسب هذا الموعد؟" not "تبي"); banned words list if any; apologize at most once per problem; never start with an apology or a greeting.
- **IMPORTANT**: never think out loud; never reintroduce; don't re-ask answered things; max 2–3 options per reply in one sentence; fallback at most once per call; never repeat info unless asked.

**Optional fields — keep them SHORT.** The user wants these lean; long tag taxonomies get rejected.

*Tagging*
- About 8–10 tags total: one per main request type, one success outcome (e.g. `lead_created` / `booked`), one `not_resolved`, and an `urgent` flag where safety or emergencies exist. snake_case English names.
- Tagging instructions: one line "Tag each call from the transcript only. Add every tag that applies.", then one short line per tag. No multi-level schemes, no per-branch tags unless asked.

*Ticketing*
- Ticket creation instructions: list only the request types that become tickets, the fields to collect for each, and their priority. Add: include name, phone and a one-line summary; say "تم تسجيل طلبك" only after the ticket is created; never read the ticket number aloud; never promise a response time.
- Split clearly with other tools: tickets = issues of existing customers (maintenance, complaints, contract changes, callback requests); lead/booking tools = new sales. State which requests do NOT get tickets. If ticketing is the only registration tool, route everything through it.
- Inbox name: `<Company> – <Purpose>` (e.g. "Acme – Tenant Requests").
- Ticket types: prefer 3–5 custom types matching the ticket instructions exactly; if using presets, map each request type to one preset and use the same names in the instructions.
- Priority instructions: 4 bullets (urgent/high/medium/low), each with concrete triggers from this business (urgent = danger to people or property).
- Always create ticket: OFF unless every call should become a ticket (otherwise price questions open tickets).
- One open ticket: ON to prevent duplicate tickets from repeat callers.
- Ticketing rules live in the Ticketing fields; the Workflow only says "register the request" so the two don't contradict.

## 4. Self-audit before delivering (mandatory)

These are the real defects found in past builds. Check every one and fix before sending:

1. Same situation handled differently in Workflow vs Operational (e.g. status questions → fallback in one, channel in the other). Each rule lives in ONE field; Workflow points to Operational for details.
2. Language rule contradicts itself, or code-switching would lock the wrong language.
3. "Say exactly as written" vs "translate for English callers" — resolve explicitly, pre-write English scripts.
4. Two questions in one turn (e.g. "أكمل الباقي؟" + "anything else?"; fallback that already ends with a question + another question).
5. Re-greeting: greeting in knowledge section A, greeting phrases in Identity/Language, answers in the knowledge that start with "حياك الله".
6. Instructions that need a tool that doesn't exist (transfer, end call, lookup).
7. Fallback loops: "I want a human" → fallback every turn; two knowledge answers that send the caller to each other.
8. Routing that points to an entry that doesn't actually answer the question (read the entry, don't trust its heading — e.g. a "reset password" entry that needs the old password).
9. Questions the knowledge already answers but the rules send to the fallback (e.g. "when will I be approved?").
10. Category letters clashing with section letters; section codes that might be spoken.
11. TTS risks: digits inside fixed scripts, " - " separators, underscores in emails, Arabic platform names that may be mispronounced — list them for a listening test.
12. No handling for silence, repeat, "are you a bot", unclear second attempt.
13. Optional fields: ticket types, ticket instructions and priority instructions use the same names; no request type is sent to both tickets and the lead tool; tags match the workflow's request types; "Always create ticket" is off unless intended.

If the user asks for a deeper check ("double check", "production", "council"), run the llm-council skill on the files.

## 5. Deliver

- Write every field file, then send them all in one SendUserFile call (attach), in builder order. Don't also paste the field contents in chat. If the user is filling the optional fields one screen at a time, answer each screen in chat with copy-paste blocks instead.
- If the same company also has a WhatsApp agent, keep the two sets separate (`_voice_` vs `_whatsapp_` file names) and never put a voice-only field (e.g. Ticket creation) among the WhatsApp files.
- Reply with: one line on what was built, a short "To confirm with client" list (assumptions, translated scripts, [TO CONFIRM] facts, conflicts found in their knowledge), and ~10 scripted test calls (Arabic, English, off-topic, human request, silence, each tool path, the tie-breaker cases).
- Never put the client's knowledge through edits silently. If you restructured it, verify with a diff that facts are unchanged and say so.

## 6. Patching an existing agent

The platform fields have no line numbers. Give every fix as:

```
# Field: <field name>
**Before:**
<exact current text>
**After:**
<replacement text>
```
For additions, use the line they go after as "Before" and that line + new lines as "After". Group by field. Don't edit the user's files without permission — propose the before/after first.

## 7. Converting V1 → V2

V1 = thin persona fields + one large Reference knowledge. Goal: the SAME behaviour, rewritten cleanly into the §2 fields. Equivalence is judged on meaning and behaviour, never on literal text.
1. Read the whole V1 (from `agent_overview.md` or the pasted config) and the attached tools with their definitions.
2. Inventory V1 behaviours: every flow, every tool's call conditions and inputs, every result state and what the agent says for it, every fixed script, every prohibition, every fact table.
3. Rewrite into the §2 fields following §3. Keep fixed client scripts verbatim. Drop what the platform already holds (tool IDs, endpoints, timeouts) but keep any behaviour hidden in them (e.g. "slow, don't retry").
4. Scan for contradictions (inside V1, and V1 vs tool definitions). Resolve them in one short tie-breaker section at the top of Operational, marked "to confirm with client".
5. Run §4 Self-audit, then a behaviour review: compare V1 vs V2 area by area (persona, knowledge, each operational flow) for anything lost, weakened, changed or newly unsafe, and fix it.
6. Deliver per §5, plus a short change log: what moved where, what was dropped and why.
