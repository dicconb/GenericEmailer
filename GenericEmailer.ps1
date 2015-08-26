Param (
    $recipients = @('joe.bloggs@somedomain.co.uk')
)

# Start runtime timer
$starttime = Get-Date

#### Email Information Block Parameters ####

$scriptname = "SomeScript"
$scriptversion = "1.0"
$scriptwritten = "26/08/2015"
$scriptby = "Your Name Here"
$scriptserver = $env:computername
$scriptlocation = $Myinvocation.MyCommand.Definition
$sender = "suitablefromaddress@somedomain.co.uk"
$smtpserver = "a-email.corp.local"
$scriptaccount = "$($env:userdomain)\$($env:username)"
$subject = "Suitable subject line here - $(Get-Date -UFormat "%d/%m/%y")"

#### Your script logic here ####

$tabledata = get-process | select -first 10 | select Id, ProcessName, Handles, CPU | sort-object Id

#### Email output formatting ####

[array]$bodycontent = $null
# Add HTML Heading here
$bodycontent+="<h3>Title</h3>"

# Add HTML table containing data
$bodycontent+= $tabledata | ConvertTo-Html -fragment | out-string

$finishtime = Get-Date

# Add CSS styles here
$headercontent = @('<style type="text/css">
body {font-family: calibri;font-size: 0.8em;}
th {font-weight: bold;border-style: solid;border-width: 1px;border-color: gray;padding: 3px;}
table {border: 1;border-collapse: collapse;}
td {border-style: solid;border-width: 1px;padding: 3px;border-color: gray;}
tr {padding:3px;}
#footer {color:gray;}
.goodnews {color:green;}
.badnews {color:red;}
.sitext {font-style:italic;}
</style>')

# Add entries in grey "script details" footer here
$footer = '<p id=footer>Script: '+$scriptname+'<br/>Version: ' + $scriptversion + '<br/>Written: ' + $scriptwritten + '<br/>By: ' + $scriptby + '<br/>Server: '+$scriptserver +'<br/>Script run as: '+$scriptaccount+'<br/>Script Path: '+$scriptlocation+'<br/>Run time: '+($finishtime - $starttime)+'</p>'
$postcontent=$footer

$msgHTML = ConvertTo-Html -head $headercontent -Body $bodycontent -postcontent $postcontent | Out-String
$msghtml = $msghtml -replace '<table>
</table>', ''

# Send email using SMTP
Send-MailMessage -To $recipients -BodyAsHtml -Body $msgHTML -From $sender -SmtpServer $smtpserver -Subject $subject
