%dw 2.0
output application/json
var bitbucketData = payload[0].payload default []
var confluenceData = payload[1].payload default []
var jenkinsData = payload[2].payload default []
var jiraData = payload[3].payload[0].payload default []
var jiraBacklogData = payload[3].payload[1].payload default []
var splunkData = payload[4].payload default []
var azureDevOpsBacklogData = payload[5].payload[0].payload default []
var azureDevOpsSprintData = payload[5].payload[1].payload default []
var azureDevOpsBuildData = payload[5].payload[2].payload default []
var azureDevOpsRepoData = payload[5].payload[3].payload default []
---
{
    documents:
        if (vars.sdlcSummary.documents == "confluence") {
			totalPages: confluenceData.size default null,
			pagesCreatedInLast30Days : sizeOf(confluenceData.results filter ($.history.createdDate as String {format: "yyyy-MM-dd'T'HH:mm:ss.SSS"} as Date) > now() - |P30D|) default null,
			pagesUpdatedInLast30Days : sizeOf(confluenceData.results filter ($.history.lastUpdated.when as String {format: "yyyy-MM-dd'T'HH:mm:ss.SSS"} as Date) > now() - |P30D|) default null,
			topContributorsInLast30Days : ((confluenceData.results filter ($.history.createdDate as String {format: "yyyy-MM-dd'T'HH:mm:ss.SSS"} as Date) > now() - |P30D| groupBy $.history.createdBy.publicName) mapObject {
				($$) : sizeOf($)
			} orderBy (-$)) default null
        } else null,
    repositories: 
        if (vars.sdlcSummary.repos == "bitbucket") {
            repositoryCount: bitbucketData.size default 0
        } else if (vars.sdlcSummary.repos == "azuredevops") {
            repositoryCount: azureDevOpsRepoData.size default 0
        } else null,
    builds: 
        if (vars.sdlcSummary.builds == "bitbucket") {
            totalJobs: "",
            failedJobs: "",
            successJobs: "",
            unexecutedJobs: ""
        } else if (vars.sdlcSummary.builds == "azuredevops") {
            totalJobs: sizeOf(azureDevOpsBuildData),
            failedJobs: sizeOf(azureDevOpsBuildData filter() -> $.result == "failed"),
            successJobs: sizeOf(azureDevOpsBuildData filter() -> $.result == "succeeded"),
            unexecutedJobs: sizeOf(azureDevOpsBuildData filter() -> $.result == "no runs")
        } else if (vars.sdlcSummary.builds == "jenkins") {
            totalJobs: sizeOf(jenkinsData.jobs)  default null,
            failedJobs: sizeOf(jenkinsData.jobs filter $.color == "red") default null,
            successJobs: sizeOf(jenkinsData.jobs filter $.color == "blue")  default null,
            unexecutedJobs: sizeOf(jenkinsData.jobs filter $.color == "notbuilt")  default null
        } else null,
    tasks:
        if (vars.sdlcSummary.tasks == "jira") {
            tasksInBacklog: totalJiraTasksInBacklog: jiraBacklogData.total default null,
            tasksInSprint: jiraData.total,
            tasksInSprintByType: (jiraData.issues groupBy $.fields.issuetype.name) mapObject  {($$) : sizeOf($)} default null,
            tasksInSprintByStatus: (jiraData.issues groupBy $.fields.status.name) mapObject  {($$) : sizeOf($)} default null
        } else if (vars.sdlcSummary.tasks == "azuredevops") {
            tasksInBacklog: sizeOf(azureDevOpsBacklogData) default null,
            tasksInSprint: sizeOf(azureDevOpsSprintData) default null,
            tasksInSprintByType: (azureDevOpsSprintData groupBy $.taskType) mapObject  {($$) : sizeOf($)} default null,
            tasksInSprintByStatus: (azureDevOpsSprintData groupBy $.status) mapObject  {($$) : sizeOf($)} default null
        } else null
}