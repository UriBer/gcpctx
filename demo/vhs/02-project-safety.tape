# VHS tape for Scenario 2: Project Safety

Output demo/gifs/02-project-safety.gif

Set FontSize 14
Set Width 1200
Set Height 600
Set Theme "Dracula"
Set TypingSpeed 50ms
Set PlaybackSpeed 0.8

Type "# gcpctx: Production Safety Features"
Enter
Sleep 1s

Type "gcpctx protect prod"
Enter
Sleep 1.5s

Type "gcpctx use prod"
Enter
Sleep 2s

Type "gcpctx assert --context dev --project my-dev-project"
Enter
Sleep 2s

Type "gcpctx assert --context prod"
Enter
Sleep 2s

Type "# 🛡️ Assertions prevent production accidents!"
Enter
Sleep 2s
