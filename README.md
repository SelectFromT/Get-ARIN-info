# Get-ARIN-info
PowerShell script to take an IP or group of IPs and looks up the ARIN data for them. 

Script can be saved and run directly from PowerShell.

At time of publishing, this script was tested with a IP pool size of approximately 1,800 IPs. The API limit was not reached, however, the error handling should be adequate the handle a limit, pause for 60 seconds, and proceed with continued queries. 

Input file types:
<br />  Single IP
<br />  IP list text file, Line delimited
<br />  CSV, IPs in single column
<br />  *Parse file* - this option will attempt to parse a file for IPs.

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


Once the script has compelted, you can use Invoke-Item (ii) to opent he CSV output, or navigate to the default save location to open the file (C:\temp\YYYYmmdd_hh-mm-ss.csv)
<br />Output includes several useful columns including:
<br />IP Searched
<br />IP range start
<br />IP range end
<br />Registration Date
<br />Last update date on file
<br />Registered company name, address, city, state, and zipcode, country, ARIN info web link, the block name and Net Reference.
<br /><img src='https://github.com/SelectFromT/Get-ARIN-info/blob/master/SampleData/ExampleOutput.jpg'>

<B>But What about that Elasticsearch option?</B>
You can now choose Elasticsearch as an output method. This allows faster pivoting through Kibana, and can allow easier seaching as well as visualizations. After choosing your input file type, choose our output as CSV or Elasticsearch:
<br /><img src='https://github.com/SelectFromT/Get-ARIN-info/blob/master/SampleData/ElasticOption.JPG'>

You are prompted for your Elasticsearch server, in this example localhost, however it might be yourcompany-elastic.com
<br /> as well as the Port you have your database on (Default 9200):
<br /><img src='https://github.com/SelectFromT/Get-ARIN-info/blob/master/SampleData/ElasticServer-Port.JPG'>

What about IPs you have already searched for? Well, I handle that for you too. If the IP exists, it skips that and writes it to an output file. This allows you to maintain a running list of duplicates in case you track that information:
<br /><img src='https://github.com/SelectFromT/Get-ARIN-info/blob/master/SampleData/DuplicateIPs.JPG'>

Once complete, you get the message that states the search is completed: 
<br /><img src='https://github.com/SelectFromT/Get-ARIN-info/blob/master/SampleData/ElasticComplete.JPG'>

Personally, I do not prefer filtering on date for this instance. This allows me to look at all IPs I have looked up, then search for key terms, such as country. Here is an example of my filter preference when the Index Pattern is first created:
<br /><img src='https://github.com/SelectFromT/Get-ARIN-info/blob/master/SampleData/PersonalFilterPreference.JPG'>

It might sound nice, but what does it look like? Well, here is an example of what it might look like:
<br /><img src='https://github.com/SelectFromT/Get-ARIN-info/blob/master/SampleData/ExampleDashboard.JPG'>
