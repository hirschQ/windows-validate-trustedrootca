# Download CAB with latest list of Microsoft-trusted root CAs:
invoke-webrequest -uri http://ctldl.windowsupdate.com/msdownload/update/v3/static/trustedr/en/authrootstl.cab -OutFile .\authrootstl.cab 


# Confirm download of CAB:
if (-not (Test-Path -Path .\authrootstl.cab)){ "CAB file not downloaded, exiting." ; return } 


# Extract STL file from CAB:
$shell = new-object -com Shell.Application
$filepath = dir .\authrootstl.cab | select -ExpandProperty fullname
$folderpath = dir .\authrootstl.cab | select -ExpandProperty DirectoryName

$cab = $shell.NameSpace( $filepath )

foreach($item in $cab.items())
{
    $shell.Namespace($folderpath).copyhere($item)
}


# Confirm extraction of STL file:
if (-not (Test-Path -Path .\authroot.stl)){ "STL file not extracted, exiting." ; return } 


# Construct file path for output:
$outfile = "Microsoft-Trusted-Root-CA-Certs.txt"


# Select SHA-1 hashes of trusted root CA certs from STL file:
certutil.exe -dump .\authroot.stl | Select-String -Pattern 'Subject Identifier:' | foreach { $_ -split 'Subject Identifier: ' } | select-string -pattern '...' | foreach { $_.line.toupper() } | Out-File -FilePath $outfile 


# Say something useful...
"`nFile saved as $outfile `n"


# Clean up temp files:
del .\authrootstl.cab -ErrorAction SilentlyContinue
del .\authroot.stl -ErrorAction SilentlyContinue



