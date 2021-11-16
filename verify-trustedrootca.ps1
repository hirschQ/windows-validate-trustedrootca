# Extract hashes of "Trusted Root Certification Authorities" for the current user.
$usertrusted  = dir cert:\currentuser\root | foreach { $_ | select-object Thumbprint,Subject} 



# Extract hashes of "Third-Party Trusted Root Certification Authorities" for the current user.
$usertrusted += dir cert:\currentuser\authroot | foreach { $_ | select-object Thumbprint,Subject} 



# Extract hashes of "Trusted Root Certification Authorities" for the computer.
$computertrusted = dir cert:\localmachine\root | foreach { $_ | select-object Thumbprint,Subject} 



# Extract hashes of "Third-Party Trusted Root Certification Authorities" for the computer.
$computertrusted += dir cert:\localmachine\authroot | foreach { $_ | select-object Thumbprint,Subject} 



# Combine all the user and computer CA hashes and exclude the duplicates.
$combined = ($usertrusted + $computertrusted) | sort Thumbprint -unique



# Read in the hashes from the reference list of thumbprints.
$reference = get-content -path C:\Microsoft-Trusted-Root-CA-Certs.txt

$PathToFile = 'C:\Microsoft-Trusted-Root-CA-Certs.txt'


# Get list of locally-trusted hashes which are NOT in the reference file.
$additions = @( $combined | foreach { if ($reference -notcontains $_.Thumbprint) { $_ } } ) 



# Save the list to a CSV file to the output path, where the name of the file is
# ComputerName+UserName+TickCount.csv, which permits the use of the tick count for sorting
# many files by time and extraction of a timestamp for when the file was created.
# To convert a timestamp number into a human-readable date and time:  get-date 634890196060064770
$PathToFile = 'C:\' + $env:computername + "+" + $env:username + "+" + $(get-date).ticks + ".csv"



# Save an empty file if there are no CA additions; otherwise, save the CSV list.
if ($additions.count -ge 1)
{
    $additions | export-csv -notypeinfo -literalpath $($PathToFile)
}
else
{
    $null | set-content -path $PathToFile
}



# Write the list to the local Application event log for archival:
new-eventlog -LogName Application -Source RootCertificateAudit -ErrorAction SilentlyContinue
#
$GoodMessage = "All of the root CA certificates trusted by $env:userdomain\$env:username are on the reference list of certificate hashes obtained from " + $FilePath

$BadMessage = "WARNING: The following root CA certificates are trusted by $env:userdomain\$env:username, but these certificates are NOT on the reference list of certificate hashes obtained from " + $PathtoFile + $($additions | format-list | out-string)

if ($additions.count -eq 0)
{ write-eventlog -logname Application -source RootCertificateAudit -eventID 9017 -message $GoodMessage -EntryType Information }
else
{ write-eventlog -logname Application -source RootCertificateAudit -eventID 9017 -message $BadMessage -EntryType Warning } 
