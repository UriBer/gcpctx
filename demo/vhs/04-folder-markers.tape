# VHS tape for Scenario 4: Folder Markers

Output demo/gifs/04-folder-markers.gif

Set FontSize 14
Set Width 1200
Set Height 650
Set Theme "Nord"
Set TypingSpeed 50ms
Set PlaybackSpeed 0.8

Type "# gcpctx: Automatic context per directory"
Enter
Sleep 1s

Type "cd ~/projects/frontend-app"
Enter
Sleep 0.5s

Type "cat .gcpctx"
Enter
Sleep 2s

Type "gcpctx activate"
Enter
Sleep 1.5s

Type "env | grep GOOGLE_"
Enter
Sleep 2s

Type "gcloud config list"
Enter
Sleep 2s

Type "# 📁 Your repo knows its GCP context!"
Enter
Sleep 2s
