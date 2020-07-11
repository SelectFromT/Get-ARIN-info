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


Execute the script via your preferred method, VSCode, PowerShell, PowerShell ISE, etc. 
<br /><img src='https://github.com/SelectFromT/Get-ARIN-info/blob/master/SampleData/InputChoice.jpg'>

All options will complete by adding the destination output file to the clip board. This allows easy use of ii (Invoke-Item) to be called and the path pasted in for faster opening. 
<br /><img src='https://github.com/SelectFromT/Get-ARIN-info/blob/master/SampleData/Invoke-ItemExample.jpg'>

A single IP can be entered, there is minor validation against the IP to ensure bad values are not entered:
<br /><img src='https://github.com/SelectFromT/Get-ARIN-info/blob/master/SampleData/singleIP.jpg'>

Choosing a text file, CSV, or to parse a file will open a file select box, where you can navigate then chose the correlating file. Choosing Text will limit results in the open window to .txt files, CSV will limit to .csv files. Choosing to attempt to parse a file will allow any file to be selected, however, this does not guarantee PowerShell will be able to parse the file.
<br /><img src='https://github.com/SelectFromT/Get-ARIN-info/blob/master/SampleData/FileSelect.jpg'>

Selecting a CSV file will then prompt the user to select which column contains the IP addresses:
<br /><img src='https://github.com/SelectFromT/Get-ARIN-info/blob/master/SampleData/CSVColumnSelect1.jpg'><br />

Highlight the correct column and click <b>"IP Selected"</b>
<br /><img src='https://github.com/SelectFromT/Get-ARIN-info/blob/master/SampleData/CSVColumnSelect2.jpg'>

Once compelted, the script indicates this with the following output for both <b>.txt and .csv</b> files:
<br /><img src='https://github.com/SelectFromT/Get-ARIN-info/blob/master/SampleData/Text-CSV_LookupComplete.jpg'>

Choosing to attempt to parse a file is not guaranteed the file can be parsed. With this in mind, the script will update you as it proceeds with the parse. It updates when the file is being imported, and again when it begins to parse the data.
<br /><img src='https://github.com/SelectFromT/Get-ARIN-info/blob/master/SampleData/ParseFile.jpg'>


Once the script has compelted, youc an use Invoke-Item (ii) to opent he CSV output, or navigate to the default save location to open the file (C:\temp\YYYYmmdd_hh-mm-ss.csv)
<br />Output includes several useful columns including:
<br />IP Searched
<br />IP range start
<br />IP range end
<br />Registration Date
<br />Last update date on file
<br />Registered company name, address, city, state, and zipcode, country, ARIN info web link, the block name and Net Reference.
<br /><img src='https://github.com/SelectFromT/Get-ARIN-info/blob/master/SampleData/ExampleOutput.jpg'>

