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

## Workflows

| Goal | Skills, in order | Example prompt |
|---|---|---|
| New agent | voice **or** WhatsApp builder | "Build a voice agent for <company>, here's their FAQ …" |
| Convert V1 → V2 | understanding → voice/WhatsApp builder | "Convert this agent to V2: https://app.nabrah.ai/…/edit" |
| Audit / patch a live agent | understanding → voice/WhatsApp builder | "Audit this agent and give me fixes: https://app.nabrah.ai/…/edit" |
| Just understand an agent | understanding | "Explain this agent: https://app.nabrah.ai/…/edit" |

You don't need to call skills by name — give the URL and the goal, and Claude runs the understanding skill first, then picks the builder from the agent's channel. The understanding skill reads the agent in Chrome, so it needs [Claude in Chrome](https://claude.com/chrome) and a signed-in Nabrah session. It never changes the agent.
