
proc reset*(clean: bool) = echo "resetting system" & (if clean: " and cleaning out all data." else: ".")
proc listBackup*(filename: string) = echo "getting info about " & (if filename != "nil": "backup " & filename else: "all backups") & "."
proc newBackup*(filename: string) = echo "creating a new backup" & (if filename != "nil": " in '" & filename & "'." else: ".")
proc delBackup*(filename: string) = echo "delete " & (if filename != "nil": "backup " & filename else: "all backups") & "."
proc restoreBackup*(filename: string) = echo "restore " & (if filename != "nil": "backup" & filename else: "latest backup") & "."