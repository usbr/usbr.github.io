Dim fso: Set fso = CreateObject("Scripting.FileSystemObject")
Dim downloadLocation
downloadLocation = fso.GetParentFolderName(Wscript.ScriptFullName) & "\"

Set fso = CreateObject ("Scripting.FileSystemObject")
Set stdout = fso.GetStandardStream (1)
stdout.WriteLine "Downloading files to " & downloadLocation

today = Date()
yesterday = DateAdd("d",-1,Date())
tomorrow = DateAdd("d",1,today)
todayMinus30 = DateAdd("d",-30,today)
todayPlus30 = DateAdd("d",30,today)
todayMinus2 = DateAdd("d",-2,today)
todayPlus3 = DateAdd("d",3,today)
mondayThisWeek = DateAdd("d",-1*Weekday(today,2)+1,Date())
sunday2Weeks = DateAdd("d",(-1*Weekday(today,2)+1) + 20,Date())

obsTableURL =  "http://ibr3lcrsrv01.bor.doi.net:8080/HDB_CGI.com?svr=lchdb2&sdi=1930,1863,2100,2166,2101,2146&tstp=DY&t1=" & mondayThisWeek & "&t2="& yesterday & "&format=88"
projTableURL =  "http://ibr3lcrsrv01.bor.doi.net:8080/HDB_CGI.com?svr=lchdb2&sdi=1930,1863,2100,2166,2101,2146&tstp=DY&t1=" & today & "&t2="& sunday2Weeks & "&table=M&mrid=4&format=88"
obsURL =  "http://ibr3lcrsrv01.bor.doi.net:8080/HDB_CGI.com?svr=lchdb2&sdi=1930,1863,2100,2166,2101,2146&tstp=DY&t1=" & todayMinus30 & "&t2="& yesterday & "&format=88"
projURL = "http://ibr3lcrsrv01.bor.doi.net:8080/HDB_CGI.com?svr=lchdb2&sdi=1930,1863,2100,2166,2101,2146&tstp=DY&t1=" & today & "&t2="& todayPlus30 & "&table=M&mrid=4&format=88"
obsURLHourly =  "http://ibr3lcrsrv01.bor.doi.net:8080/HDB_CGI.com?svr=lchdb2&sdi=2166,2146&tstp=HR&t1=" & todayMinus2 & "&t2="& tomorrow & "&format=88"
projURLHourly = "http://ibr3lcrsrv01.bor.doi.net:8080/HDB_CGI.com?svr=lchdb2&sdi=2166,2146&tstp=HR&t1=" & today & "&t2="& todayPlus3 & "&table=M&mrid=2&format=88"

GetHdbData obsTableURL,downloadLocation,"observedTableData.txt"
GetHdbData projTableURL,downloadLocation,"projectedTableData.txt"
GetHdbData obsURL,downloadLocation,"observedReservoirData.txt"
GetHdbData projURL,downloadLocation,"projectedReservoirData.txt"
GetHdbData obsURLHourly,downloadLocation,"observedReservoirDataHourly.txt"
GetHdbData projURLHourly,downloadLocation,"projectedReservoirDataHourly.txt"

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Combine Observed and Projected Data into 1 array for the Daily Graphs
' Read Observed Data
set objFile=fso.OpenTextFile("observedReservoirData.txt",1)
oldContent=objFile.ReadAll
' Insert NaNs at the end for the modeled data
observed=replace(oldContent,vbLf,",NaN,NaN,NaN,NaN,NaN,NaN" + vbLf,1,-1,0)
' Read Projected Data
set objFile=fso.OpenTextFile("projectedReservoirData.txt",1)
oldContent=objFile.ReadAll
' Insert NaNs after dates for the projected data
projected=replace(oldContent,"            4,","NaN,NaN,NaN,NaN,NaN,NaN,",1,-1,0)
' Combine content into 1 file for the chart web page
set objFile=fso.OpenTextFile("reservoirData.html",2)
' Write header
objFile.WriteLine "Date,Mead Observed Elevation,Hoover Observed Release,Mohave Observed Elevation,Davis Observed Release,Havasu Observed Elevation,Parker Observed Release,Mead Projected Elevation,Hoover Projected Release,Mohave Projected Elevation,Davis Projected Release,Havasu Projected Elevation,Parker Projected Release" 
WriteToCombinedGraphFile observed, objFile, True, False
WriteToCombinedGraphFile projected, objFile, False, False 
objFile.Close

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Combine Observed and Projected Data into 1 array for the Hourly Graphs
' Read Observed Data
set objFile=fso.OpenTextFile("observedReservoirDataHourly.txt",1)
oldContent=objFile.ReadAll
' Insert NaNs at the end for the modeled data
observed=replace(oldContent,vbLf,",NaN,NaN" + vbLf,1,-1,0)
' Read Projected Data
set objFile=fso.OpenTextFile("projectedReservoirDataHourly.txt",1)
oldContent=objFile.ReadAll
' Insert NaNs after dates for the projected data
projected=replace(oldContent,"            2,","NaN,NaN,",1,-1,0)
' Combine content into 1 file for the chart web page
set objFile=fso.OpenTextFile("reservoirDataHourly.html",2)
' Write header
objFile.WriteLine "Date,Davis Observed Release,Parker Observed Release,Davis Projected Release,Parker Projected Release" 
WriteToCombinedGraphFile observed, objFile, True, True
WriteToCombinedGraphFile projected, objFile, False, True 
objFile.Close

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Combine Observed and Projected Data into 1 array for the Daily Table
' Read Observed Data
set objFile=fso.OpenTextFile("observedTableData.txt",1)
observed=objFile.ReadAll
' Read Projected Data
set objFile=fso.OpenTextFile("projectedTableData.txt",1)
projected=objFile.ReadAll
' Combine content into 1 file for the table web page
set objFile=fso.OpenTextFile("tableData.html",2)
' Write header
objFile.WriteLine "<table><tr><th>Date</th><th><a href=""https://www.usbr.gov/lc/region/g4000/riverops/HOVR_FB_CurrentYear_Daily.html"">Lake Mead Elevation (ft)</a></th><th><a href=""https://www.usbr.gov/lc/region/g4000/riverops/HOVR_QD_CurrentYear_Daily.html"">Hoover Dam Average Release (cfs)</a></th><th><a href=""https://www.usbr.gov/lc/region/g4000/riverops/DAVS_FB_CurrentYear_Daily.html"">Lake Mohave Elevation (ft)</a></th><th><a href=""https://www.usbr.gov/lc/region/g4000/riverops/DAVS_QD_CurrentYear_Daily.html"">Davis Dam Average Release (cfs)</a></th><th><a href=""https://www.usbr.gov/lc/region/g4000/riverops/PRKR_FB_CurrentYear_Daily.html"">Lake Havasu Elevation (ft)</a></th><th><a href=""https://www.usbr.gov/lc/region/g4000/riverops/PRKR_QD_CurrentYear_Daily.html"">Parker Dam Average Release (cfs)</a></th></tr>"
dataResult = WriteTableDataArray(observed, projected)
WriteToTableFile dataResult, objFile
objFile.Close


''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Delete interim text files
fso.DeleteFile "observedTableData.txt"
fso.DeleteFile "projectedTableData.txt"
fso.DeleteFile "observedReservoirData.txt"
fso.DeleteFile "projectedReservoirData.txt"
fso.DeleteFile "observedReservoirDataHourly.txt"
fso.DeleteFile "projectedReservoirDataHourly.txt"

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' FUNCTIONS

' GENERIC FUNCTION TO REQUEST DATA FROM THE CGI DATA SERVICE
Function GetHdbData(urlIn,downloadLocation,fileName)
	Set fso = CreateObject ("Scripting.FileSystemObject")
	Set stdout = fso.GetStandardStream (1)
	stdout.WriteLine "     " & fileName
	dim xHttp: Set xHttp = createobject("Microsoft.XMLHTTP")
	dim bStrm: Set bStrm = createobject("Adodb.Stream")
	downloadUrl = urlIn
	downloadText = downloadLocation & fileName
	xHttp.Open "GET", downloadUrl, False
	xHttp.Send
	
	with bStrm
		.type = 1 '//binary
		.open
		.write xHttp.responseBody
		.savetofile downloadText, 2 '//overwrite
	end with
End Function

' WRITES THE HTML FILE USED BY THE GRAPHS
Function WriteToCombinedGraphFile(data, objFile, isObs, isHourly)
	arrLines = Split(data, vbLf)
	ithHourOffset = 0
	uboundOffset = 0
	If (isHourly) Then	' THESE CONSTANTS ARE CALIBRATED TO THE CGI OUTPUTS SO THAT THE GRAPH CURVES OVERLAP
		If (isObs) Then
			uboundOffset = Hour(Now()) - 3
		Else
			ithHourOffset = Hour(Now()) - 1
		End If
	End If
	For i = 1 + ithHourOffset to (Ubound(arrLines) - 1 - uboundOffset)
		' For the last line of the OBS file, copy the values over to the PROJ array so  the lines overlap on the chart
		If ((isObs) And (i = (Ubound(arrLines)-1))) Then 
			lineVals = Mid(arrLines(i), 17, 84)
			objFile.WriteLine Replace(arrLines(i), ",NaN,NaN,NaN,NaN,NaN,NaN", lineVals)
		Else 
			objFile.WriteLine arrLines(i)
		End If
	Next
End Function

' CALCULATES THE WEEKLY AVERAGES GIVEN THE DATA
Function WriteTableDataArray(dataObs, dataProj)
	Dim dataArray(20)
	obsLines = Split(dataObs, vbLf)
	For k = 1 to (Ubound(obsLines)-1)
		ithLine = RoundNumericTableLine(obsLines(k))
		dataArray(k-1) = ithLine & "obs"
	Next
	projLines = Split(dataProj, vbLf)
	For k = 1 to (Ubound(projLines)-1)
		ithLine = RoundNumericTableLine(Replace(projLines(k),"            4,",""))
		dataArray(Ubound(obsLines)-1+k-1) = ithLine & "mod"
	Next
	Dim avgArray(9)	
	runningAverages = Array(0,0,0,0,0,0)
	v1 = 0
	For k=0 to (Ubound(dataArray))	
			dataVals = Split(dataArray(k),",")
			For j=1 to (Ubound(dataVals)-1)
				runningAverages(j-1) = runningAverages(j-1) + dataVals(j)
			Next
			If k<6 Then
				avgArray(k) = dataArray(k)
			End If
			If k=6 Then
				avgArray(k) = dataArray(k)
				avgArray(7) = "Average," & " " & "," & Round(runningAverages(1)/7,0) & "," & " " & "," & Round(runningAverages(3)/7,0) & "," & " " & "," & Round(runningAverages(5)/7,0) & ",mod"
				runningAverages = Array(0,0,0,0,0,0)
			Else 
				If k=13 Then
					avgArray(8) = "Next Week," & dataVals(1) & "," & Round(runningAverages(1)/7,0) & "," & dataVals(3) & "," & Round(runningAverages(3)/7,0) & "," & dataVals(5) & "," & Round(runningAverages(5)/7,0) & ",mod"		
					runningAverages = Array(0,0,0,0,0,0)
				Else
					avgArray(9) = "2 Weeks Out," & dataVals(1) & "," & Round(runningAverages(1)/7,0) & "," & dataVals(3) & "," & Round(runningAverages(3)/7,0) & "," & dataVals(5) & "," & Round(runningAverages(5)/7,0) & ",mod"
				End If
			End If
	Next	
	'For k=0 to (Ubound(avgArray))
	'	stdout.WriteLine avgArray(k)
	'Next
	WriteTableDataArray = avgArray
End Function

' WRITES THE HTML TABLE FILE
Function WriteToCombinedTableFile(data, objFile, isObs)
	arrLines = Split(data, vbLf)
	For i = 1 to (Ubound(arrLines)-1)
		ithLine = RoundNumericTableLine(Replace(arrLines(i),"            4,",""))
		If (isObs) Then
			ithLine = "<tr><td><font color=""#244A9F"">" & Replace(ithLine,",","<font color=""#244A9F""></td><td><font color=""#244A9F"">") & "</font></tr>"
		Else
			ithLine = "<tr><td><font color=""#CB9F5B"">" & Replace(ithLine,",","<font color=""#CB9F5B""></td><td><font color=""#CB9F5B"">") & "</font></tr>"
		End If
		objFile.WriteLine ithLine
	Next
	If Not (isObs) Then
		objFile.WriteLine "</table>"
	End If
End Function

' WRITES THE HTML TABLE FILE
Function WriteToTableFile(data, objFile)
	'arrLines = Split(data, vbLf)
	For i = 0 to (Ubound(data))
		ithLine = data(i)
		ithVals = Split(ithLine,",")
		If i  > 6 Then
			objFile.WriteLine "<tr><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td></tr>"
		End If
		If (ithVals(7) = "obs") Then
			ithLine = "<tr><td><font color=""#244A9F"">" & Replace(ithLine,",","<font color=""#244A9F""></td><td><font color=""#244A9F"">") & "</font></tr>"
		Else
			ithLine = "<tr><td><font color=""#CB9F5B"">" & Replace(ithLine,",","<font color=""#CB9F5B""></td><td><font color=""#CB9F5B"">") & "</font></tr>"
		End If
		ithLine = Replace(ithLine,"obs","")
		ithLine = Replace(ithLine,"mod","")
		objFile.WriteLine ithLine
	Next
	If Not (isObs) Then
		objFile.WriteLine "</table>"
	End If
End Function

' ROUNDS DATA VALUES AND CLEANS UP THE DATETIME STRING
Function RoundNumericTableLine(line) 
	RoundNumericTableLine = ""
	lineVals = Split(line,",")
	For j = 0 to (Ubound(lineVals))		
		If (j=0) Then
			RoundNumericTableLine = Replace(lineVals(j)," 00:00","")  & ","
		Else
			If (j=1 or j=3 or j=5) Then
				RoundNumericTableLine = RoundNumericTableLine  & Replace(FormatNumber(Round(Trim(lineVals(j)),1),1),",","")  & ","
			Else
				RoundNumericTableLine = RoundNumericTableLine  & Replace(FormatNumber(Round(Trim(lineVals(j)),0),0),",","")  & ","
			End If
		End If
	Next	
End Function
