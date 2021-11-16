# windows-verify-trustedrootca
powershell script to compare trusted root ca's to microsofts current trusted root ca's

execute on c:\ or change $reference and $pathtofile in verify-trustedrootca.ps1

1. c:\get-microsoftrootcalist.ps1
2. c:\verify-trustedrootca.ps1

results are saved as csv to c:\

can be collected for log managemnet: eventID 9017
