Run these exact bash commands and nothing else:
`touch ~/.claude/tts-enabled && jq '.hooks.Stop = [{"hooks": [{"type": "command", "command": "/Users/snesjhon/Developer/nr-local/capture.sh"}]}]' ~/.claude/settings.json > /tmp/.nr_settings && mv /tmp/.nr_settings ~/.claude/settings.json`
Then reply: "TTS enabled — Claude responses will now appear at http://localhost:8787"
