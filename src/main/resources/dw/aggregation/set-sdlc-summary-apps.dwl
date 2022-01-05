%dw 2.0
output application/java
---
{
	repos: p('sdlc.summaryView.repos') default "",
	tasks: p('sdlc.summaryView.tasks') default "",
	builds: p('sdlc.summaryView.builds') default "",
	documents: p('sdlc.summaryView.documents') default ""
}