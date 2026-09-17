-- Handover: Apple Mail rule action. Saves each matching message as a text
-- file in the Handover drop folder, where the assistant proposes it as a
-- capture. Installed by: .agent/sync.sh mail-rule
using terms from application "Mail"
	on perform mail action with messages theMessages for rule theRule
		set dropFolder to "DROP_PATH"
		repeat with m in theMessages
			set body to (subject of m) & linefeed & "From: " & (sender of m) & linefeed & "Received: " & ((date received of m) as string) & linefeed & linefeed & (content of m)
			set stamp to do shell script "date +%Y%m%d-%H%M%S"
			set fname to dropFolder & "/mail-" & stamp & ".txt"
			set f to open for access (POSIX file fname) with write permission
			write body to f as «class utf8»
			close access f
		end repeat
	end perform mail action with messages
end using terms from
