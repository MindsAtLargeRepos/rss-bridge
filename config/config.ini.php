[system]
enabled_bridges[] = *

[cache]
type = "file"
; enable file caching

[authentication]
enable   = ${AUTH_ENABLE}
username = "${AUTH_USER}"
password = "${AUTH_PASS}"

;-- optionally:
;token = "your_token_here"

[proxy]
url = ""
name = ""
by_bridge = false
