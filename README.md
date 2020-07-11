# Get-ARIN-info
PowerShell script to take an IP or group of IPs and looks up the ARIN data for them. 

Script can be saved and run directly from PowerShell.

At time of publishing, this script was tested with a IP pool size of approximately 1,800 IPs. The API limit was not reached, however, the error handling should be adequate the handle a limit, pause for 60 seconds, and proceed with continued queries. 

Input file types:
  Single IP
  IP list text file, Line delimited
  CSV, IPs in single column
  *Parse file* - this option will attempt to parse a file for IPs.

This was created out of a desire for similar Linux functionality in a base Windows build. Output is a CSV file which includes the IP, the given IP range of the registered company, the company information, etc.

