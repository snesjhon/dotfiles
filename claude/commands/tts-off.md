Run these exact bash commands and nothing else:
`rm -f ~/.claude/tts-enabled && jq 'del(.hooks)' ~/.claude/settings.json > /tmp/.nr_settings && mv /tmp/.nr_settings ~/.claude/settings.json`
Then reply: "TTS disabled."
