---
name: "nabrah-whatsapp-agent-builder"
description: "Build, audit, or convert (V1→V2) a Nabrah WhatsApp chat agent prompt in the V2 field format — text-channel rules, not phone-call rules. Use for WhatsApp agents; use nabrah-voice-agent-builder for calls."
---

# Nabrah V2 WhatsApp-agent builder

WhatsApp agents are TEXT agents. The customer reads, scrolls, copies, taps links, and may reply hours later. Do not apply voice rules (numbers as words, no lists, no URLs). Reference pattern: a car-dealer sales/service agent (≈50 tools, pre_callback, identity + OTP, bookings, purchases, payments).

## 0. Writing standard (non-negotiable)

- Write every instruction in clear, concise English, the same quality as the voice skill's output. Arabic appears ONLY inside quotes as customer-facing scripts, each with an English equivalent where the customer may write in English.
- Plain text only: no emojis, no ✓ / ⚠️ / ✗ / ➔ symbols, no box-drawing or ═══ banners, no ASCII tables, no shouting caps. Use short headings, numbered sections and "-" bullets.
- One rule, one place. Say it once, precisely; never repeat a rule in several sections for emphasis.
- Keep client facts exact (numbers, codes, prices, hours, links, mandatory legal/payment notes) but rewrite all instructions in your own words.
- Never paste a V1 guide into a field verbatim. A field dump of the old prompt is a failed build.

## 1. Intake

Extract from what the user gave; ask ONE AskUserQuestion round only for items that change the build:
- Company, sector, who messages (customers, suppliers), inbound only or also outbound templates
- Attached tools — copy the exact list from the agent's "Custom tools" screen and their platform descriptions. Never invent a tool. Tools in the workspace but not attached to this agent are NOT available.
- Pre-call data (pre_callback / template variables): what fields arrive before the first message
- Human handoff: is there a transfer/assign mechanism, which department, its working hours
- Mandatory client scripts (welcome, payment notes, legal lines) — keep verbatim
- Knowledge bases attached to the agent
- Tagging / Ticketing used? (same lean rules as the voice skill)

## 2. Field layout (same as voice V2)

Produce ONE .txt file per platform field, so each can be pasted straight into its box. Each file holds only that field's content: no field label, no headings from other fields, no code fences. Name files `<agent>_whatsapp_<NN>_<field>.txt` in builder order:
- `_01_basics.txt` (Display name, Agent type, Voice, Languages, Agent speaks first, Allow interruptions, as `label: value` lines)
- `_02_first_sentence.txt`
- `_03_language_instruction.txt`
- `_04_identity.txt`
- `_05_purpose_and_boundaries.txt`
- `_06_workflow.txt`
- `_07_reference_knowledge.txt`
- `_08_operational_instructions.txt`
- Optional, only if used, one file per field: `_09_tags.txt`, `_10_tagging_instructions.txt`, `_11_ticket_creation_instructions.txt`, `_12_priority_instructions.txt`, `_13_ticketing_settings.txt` (toggles and inbox settings as `label: value` lines).
- If the agent hands off to a human instead of creating tickets, there is no ticket file.

What goes where:
- **Language instruction**: language detection per latest message, switching rules, unclear-language case, Arabic style. Only language rules.
- **Identity**: name, role, personality, tone ("who are you" answer).
- **Purpose and boundaries**: services grouped by data needed (none / identity / no account / human), unavailable services, scope.
- **Workflow**: recognition (pre_callback), welcome variants, intent classification, data-collection rules, privacy rules, end-to-end paths.
- **Reference knowledge**: facts and lookup tables only (data formats, hours, locations, service codes, branch info).
- **Operational instructions**: mandatory/override rules FIRST, then tie-breakers, then per-tool usage, error handling, communication rules, never-do list.

## 3. WhatsApp-specific rules (differ from phone)

- Formatting: short messages; bullets or numbered options are fine (max 3–5 items); one question per message; end with one question that leads the next step.
- Numbers: digits with thousands separators (79,865 ريال); dates/times use the tool's ready labels (label_ar, time_label_ar) — never ISO strings.
- Links: send checkout/payment/map links exactly as returned, never shortened or rebuilt; only when the tool returned one.
- Reference numbers (booking, order, complaint) ARE shown to the customer; internal IDs (custID, seq, guid, serviceId, flowId unless the client requires it) are never shown.
- Emojis only if the customer uses them first (unless the client says otherwise).
- Codes (OTP) are typed by the customer: a message with only digits right after a code request = call the verify tool immediately.
- Language is decided by the LATEST message every time; customers switch after pauses. Never ask which language.
- Async: the customer may come back later — re-confirm previously collected data before irreversible actions; never assume silence = consent.
- First sentence: on WhatsApp the customer usually writes first. If welcomes vary by pre_callback (name, language), say so in Workflow and flag the static First sentence for double-greeting risk.
- Handoff: if a transfer mechanism exists, always state when a human will reply (department hours). Never promise "right now". Never re-transfer because the customer says nobody replied.
- Money and irreversible actions: full summary → separate explicit confirmation question → only then the tool. A yes to an earlier question is not confirmation. Unknown result (null) → never retry, never confirm, hand over.
- Never ask for card numbers, CVV, bank passwords; payment happens on the provider page or SADAD.

## 4. Converting V1 → V2 (production agents)

V1 = thin persona fields + one giant Reference knowledge. Goal: SAME behaviour, rewritten cleanly in the right fields. Equivalence is judged on meaning and behaviour, never on literal text.
1. Read the whole V1 (all parts) and the attached tool list + descriptions.
2. Inventory V1 behaviours: every service/flow, every tool's call conditions, inputs and sources, every result state and the message for it, every mandatory script, every prohibition, every fact/code table.
3. Rewrite into the §2 fields following §0. Drop what the platform already holds (Tool IDs, endpoints, methods, timeouts) but keep any behaviour hidden in them (e.g. "slow, don't retry").
4. Scan for contradictions (inside V1, and V1 vs tool descriptions). Resolve them in ONE short tie-breaker section at the top of Operational, stating which source wins. Mark each "to confirm with client".
5. Behaviour review: spawn Sonnet reviewers in parallel, one per area (persona fields; reference facts; Operational split by service groups). Each compares V1 vs V2 on meaning and behaviour only (lost, weakened, changed, contradicted, or unsafe new behaviour) and returns exact fixes. Apply the fixes; re-review anything marked NOT EQUIVALENT.
6. If the user asks for "council", run llm-council on the final package.

## 5. Self-audit

0. §0 writing standard met: English instructions, Arabic only in quoted scripts, no emojis/symbols/box art, no verbatim V1 dumps.
1. Each rule lives in one field; others point to it by section number.
2. Language rules not contradicted by headers or other fields; unclear-language case handled.
3. Every tool mentioned is attached; every attached tool needed is covered.
4. Tool description vs prompt conflicts resolved in tie-breakers.
5. Irreversible/money flows: summary → separate confirmation → tool → read result flag (true/false/null).
6. No double greeting (First sentence vs dynamic welcome).
7. Handoff wording includes working hours; no re-transfer loops.
8. Privacy: pre-call data used only when the customer asks; phone number is not identity.
9. Cross-references all resolve.

## 6. Deliver

- Write every field file, then send them all in one SendUserFile call (attach), in builder order. Don't also paste the field contents in chat.
- If the same company also has a voice agent, keep the two sets separate (`_whatsapp_` vs `_voice_` file names) and never put a voice-only field (e.g. Ticket creation) among the WhatsApp files.
- Reply with: one line on what changed, the behaviour-review verdicts, a short "To confirm with client" list (tie-breakers, double-greeting, missing tools), and ~10 test chats (Arabic, English, language switch mid-chat, registered vs unregistered, OTP digits-only message, payment flow with a premature "yes", handoff out of hours, each tie-breaker).
- Patches to existing agents: Before/After per field, never edit without permission.