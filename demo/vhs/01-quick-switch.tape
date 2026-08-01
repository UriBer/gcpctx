# VHS tape for Scenario 1: Quick Context Switch
# Install vhs: brew install vhs
# Run: vhs 01-quick-switch.tape

Output demo/gifs/01-quick-switch.gif

Set FontSize 14
Set Width 1200
Set Height 600
Set Theme "Dracula"
Set TypingSpeed 50ms
Set PlaybackSpeed 0.8

Type "# gcpctx: Switch GCP contexts instantly"
Enter
Sleep 1s

Type "gcpctx current"
Enter
Sleep 1s

Type "gcpctx list"
Enter
Sleep 2s

Type "gcpctx use staging"
Enter
Sleep 2s

Type "gcpctx current --json"
Enter
Sleep 3s

Type "# ✨ Context switched safely in seconds!"
Enter
Sleep 2s
