
# Shortcut on Desktop to Eval Centerround
$wsShell = New-Object -ComObject WScript.Shell
$shortcut = $wsShell.CreateShortcut("$HOME\Desktop\EvalCenter.lnk")
$shortcut.TargetPath = "https://techcommunity.microsoft.com/t5/windows-11/accessing-trials-and-kits-for-windows-eval-center-workaround/m-p/3361125"
$shortcut.Save()