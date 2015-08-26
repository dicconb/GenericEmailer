Param (
    $recipients = @('joe.bloggs@somedomain.co.uk')
)

# Start runtime timer
$starttime = Get-Date

#### Email Information Block Parameters (appears at bottom of email) ####
[array]$emailinfoblockparams = $null
$emailinfoblockparams += @{"name"="Script";"value"="SomeScript"}
$emailinfoblockparams += @{"name"="Version";"value"="1.0"}
$emailinfoblockparams += @{"name"="Written";"value"="26/08/2015"}
$emailinfoblockparams += @{"name"="By";"value"="Your Name Here"}
$emailinfoblockparams += @{"name"="Execution Server";"value"=$env:computername}
$emailinfoblockparams += @{"name"="Script Path";"value"=$Myinvocation.MyCommand.Definition}
$emailinfoblockparams += @{"name"="Script run as";"value"="$($env:userdomain)\$($env:username)"}

#### Email parameters ####
$sender="suitablefromaddress@somedomain.co.uk"
$smtpserver = "a-email.corp.local"
$subject = "Suitable subject line here - $(Get-Date -UFormat "%d/%m/%y")"



#### Your script logic here ####



$foo = get-process
$bar = $foo | Get-Random -count 10
$foobar = $bar  | select Id, ProcessName, Handles, CPU | sort-object Id


# Data to be output in the email
$tabledata = $foobar





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

[array]$footer = $null
$footer += '<p id=footer>'
$footer += $emailinfoblockparams | Foreach-Object {"$($_.name): $($_.value)<br/>"}
$footer += "Run time: $($finishtime - $starttime)</p>"

# Assemble into an HTML document
$msgHTML = ConvertTo-Html -head $headercontent -Body $bodycontent -postcontent $footer | Out-String

# Remove any empty table objects (cosmetic)
$msghtml = $msghtml -replace '<table>
</table>', ''

# Send email using SMTP
Send-MailMessage -To $recipients -BodyAsHtml -Body $msgHTML -From $sender -SmtpServer $smtpserver -Subject $subject
