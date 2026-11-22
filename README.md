# nabrah-skills

Claude skills for building and reviewing Nabrah agents.

| Skill | What it does |
|---|---|
| `nabrah-voice-agent-builder` | Build or audit a production voice-agent prompt in the Nabrah V2 field format |
| `nabrah-whatsapp-agent-builder` | Build, audit or convert (V1→V2) a Nabrah WhatsApp chat-agent prompt |
| `nabrah-agent-chrome-understanding` | Read an agent's full config from a Nabrah agent URL in Chrome (read-only) → `agent_overview.md` + overview |

## Install (Claude Code)

```
/plugin marketplace add MagdiWaleed/nabrah-skills
/plugin install nabrah-skills@nabrah-skills
```

Restart Claude Code, then run `/skills` to check they're there.

Update later with:

```
/plugin marketplace update nabrah-skills
```

## Install (Claude app — claude.ai / desktop)

1. Run `./build-zips.sh` — it creates one zip per skill in `dist/`.
2. Go to **Settings → Capabilities → Skills → Upload skill** and upload each zip.

## Usage

Just ask naturally, e.g.:
- "Build a voice agent prompt for <company> …"
- "Convert this WhatsApp agent to V2 …"
- "Understand this agent: https://app.nabrah.ai/…" (needs Claude in Chrome)
