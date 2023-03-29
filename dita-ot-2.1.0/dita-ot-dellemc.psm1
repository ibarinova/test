set-strictmode -version 2.0
	[xml]$xmlContextFile = Get-Content -Path $PublishPostProcessContextFileLocation
	$Languages = $xmlContextFile.SelectSingleNode("/publishpostprocesscontext/languages").InnerText
function RunAnt_DellEMCGeneric
{
	param
	(
		[String]$MapFileLocation,
		[String]$OutputFolder,
		[String]$TempFolder,
		[String]$LogFileLocation,
		[String]$DITAOTTransType, # e.g. ishditadelivery
		[String]$DraftComments, # yes/no
		[String]$Compare, # yes/no
		[String]$CombinedLanguages, # yes/no
		[String]$PublishPostProcessContextFileLocation
	)

	Write-Host "Running RunAnt_DellEMCGeneric..."  
	
	$command = "ant.bat -Dtranstype=""$DITAOTTransType"" -Dargs.input=""$MapFileLocation"" -Doutput.dir=""$OutputFolder"" -Ddita.temp.dir=""$TempFolder"" -Dargs.draft=""$DraftComments"" -Dclean.temp=no -Dvalidate=$Dvalidate -Dargs.language=""$Languages"" -logfile ""$LogFileLocation"""
	Write-Host "Running command ""$command"""
	& ant.bat "-Dtranstype=$DITAOTTransType" "-Dargs.input=""$MapFileLocation""" "-Doutput.dir=""$OutputFolder""" "-Ddita.temp.dir=""$TempFolder""" "-Dargs.draft=$DraftComments" "-Dclean.temp=no" "-Dvalidate=$Dvalidate" -logfile "$LogFileLocation"
}

function RunAnt_DellEMCQA
{
	param
	(
		[String]$MapFileLocation,
		[String]$OutputFolder,
		[String]$TempFolder,
		[String]$LogFileLocation,
		[String]$DITAOTTransType, # e.g. ishditadelivery
		[String]$DraftComments, # yes/no
		[String]$Compare, # yes/no
		[String]$CombinedLanguages, # yes/no
		[String]$PublishPostProcessContextFileLocation
	)

	Write-Host "Running RunAnt_DellEMCQA..."  
	
	$command = "ant.bat -Dtranstype=""$DITAOTTransType"" -Dargs.input=""$MapFileLocation"" -Doutput.dir=""$OutputFolder"" -Ddita.temp.dir=""$TempFolder"" -Dargs.draft=""$DraftComments"" -Dclean.temp=no -Dvalidate=$Dvalidate -Dargs.language=""$Languages"" -logfile ""$LogFileLocation"""
	Write-Host "Running command ""$command"""
	& ant.bat "-Dtranstype=$DITAOTTransType" "-Dargs.input=""$MapFileLocation""" "-Doutput.dir=""$OutputFolder""" "-Ddita.temp.dir=""$TempFolder""" "-Dargs.draft=$DraftComments" "-Dclean.temp=no" "-Dvalidate=false" -logfile "$LogFileLocation"
}

function RunAnt_DellEMCWEB
{
	param
	(
		[String]$MapFileLocation,
		[String]$OutputFolder,
		[String]$TempFolder,
		[String]$LogFileLocation,
		[String]$DITAOTTransType, # e.g. ishditadelivery
		[String]$DraftComments, # yes/no
		[String]$Compare, # yes/no
		[String]$CombinedLanguages, # yes/no
		[String]$PublishPostProcessContextFileLocation
	)

	Write-Host "Running RunAnt_DellEMCWEB..."  
	
	$command = "ant.bat -Dtranstype=""$DITAOTTransType"" -Dargs.input=""$MapFileLocation"" -Doutput.dir=""$OutputFolder"" -Ddita.temp.dir=""$TempFolder"" -Dargs.draft=""$DraftComments"" -Dclean.temp=no -Dvalidate=$Dvalidate -Dargs.language=""$Languages"" -logfile ""$LogFileLocation"""
	Write-Host "Running command ""$command"""
	& ant.bat "-Dtranstype=$DITAOTTransType" "-Dargs.input=""$MapFileLocation""" "-Doutput.dir=""$OutputFolder""" "-Ddita.temp.dir=""$TempFolder""" "-Dclean.temp=no" "-Dvalidate=false" -logfile "$LogFileLocation"
}

function RunAnt_pdfemcRetainTopic
{
	param
	(
		[String]$MapFileLocation,
		[String]$OutputFolder,
		[String]$TempFolder,
		[String]$LogFileLocation,
		[String]$DITAOTTransType, # e.g. ishditadelivery
		[String]$DraftComments, # yes/no
		[String]$Compare, # yes/no
		[String]$CombinedLanguages, # yes/no
		[String]$PublishPostProcessContextFileLocation
	)

	Write-Host "Running RunAnt_pdf2..."

	# If "Compare<>yes" set validate to "yes" as the input files for DITA-OT should contain valid DITA xml
	$Dvalidate = "yes"
	If ($Compare -eq "yes")
	{
		# If "Compare=yes" set validate to "no" as the input files for DITA-OT contains the comparison result and may not be valid DITA anymore
		$Dvalidate = "no"
	}

	[xml]$xmlContextFile = Get-Content -Path $PublishPostProcessContextFileLocation
	$outputformatfileLocation = $xmlContextFile.SelectSingleNode("/publishpostprocesscontext/outputformatfile").InnerText
	[xml]$outputformatfile = Get-Content -Path $outputformatfileLocation
	$customDir = $outputformatfile.SelectSingleNode("//ishfield[@name='FPDF2CUSTOMIZATIONDIR' and @level='none']").InnerText	

	
	IF([string]::IsNullOrEmpty($customDir)) {            
    Write-Host "NO CUSTOMIZATION DIR SPECIFIED"
	$command = "ant.bat -Dtranstype=""$DITAOTTransType"" -Dargs.input=""$MapFileLocation"" -Doutput.dir=""$OutputFolder"" -Ddita.temp.dir=""$TempFolder"" -Dargs.draft=""$DraftComments"" -Dclean.temp=no -Dvalidate=$Dvalidate -logfile ""$LogFileLocation"""
	Write-Host "Running command ""$command"""	 
    & ant "-Dtranstype=$DITAOTTransType" "-Dargs.input=""$MapFileLocation""" "-Doutput.dir=""$OutputFolder""" "-Ddita.temp.dir=""$TempFolder""" "-Dargs.draft=$DraftComments" "-Dclean.temp=no" "-Dvalidate=$Dvalidate" "-Dcustomization.dir=""$customDir""" -logfile "$LogFileLocation" "-Dretain.topic.fo=yes"
           
	} else {  
	Write-Host "CUSTOMIZATION DIR $customDir SPECIFIED"
    $command = "ant.bat -Dtranstype=""$DITAOTTransType"" -Dargs.input=""$MapFileLocation"" -Doutput.dir=""$OutputFolder"" -Ddita.temp.dir=""$TempFolder"" -Dargs.draft=""$DraftComments"" -Dclean.temp=no -Dvalidate=$Dvalidate -Dcustomization.dir=""$customDir"" -logfile ""$LogFileLocation"""
	Write-Host "Running command ""$command"""
	& ant "-Dtranstype=$DITAOTTransType" "-Dargs.input=""$MapFileLocation""" "-Doutput.dir=""$OutputFolder""" "-Ddita.temp.dir=""$TempFolder""" "-Dargs.draft=$DraftComments" "-Dclean.temp=no" "-Dvalidate=$Dvalidate" "-Dcustomization.dir=""$customDir""" -logfile "$LogFileLocation" "-Dretain.topic.fo=yes"
           
	}
	
	
}

function RunAnt_pdfemc
{
	param
	(
		[String]$MapFileLocation,
		[String]$OutputFolder,
		[String]$TempFolder,
		[String]$LogFileLocation,
		[String]$DITAOTTransType, # e.g. ishditadelivery
		[String]$DraftComments, # yes/no
		[String]$Compare, # yes/no
		[String]$CombinedLanguages, # yes/no
		[String]$PublishPostProcessContextFileLocation
	)

	Write-Host "Running RunAnt_pdf2..."

	# If "Compare<>yes" set validate to "yes" as the input files for DITA-OT should contain valid DITA xml
	$Dvalidate = "yes"
	If ($Compare -eq "yes")
	{
		# If "Compare=yes" set validate to "no" as the input files for DITA-OT contains the comparison result and may not be valid DITA anymore
		$Dvalidate = "no"
	}

	[xml]$xmlContextFile = Get-Content -Path $PublishPostProcessContextFileLocation
	$outputformatfileLocation = $xmlContextFile.SelectSingleNode("/publishpostprocesscontext/outputformatfile").InnerText
	[xml]$outputformatfile = Get-Content -Path $outputformatfileLocation
	$customDir = $outputformatfile.SelectSingleNode("//ishfield[@name='FPDF2CUSTOMIZATIONDIR' and @level='none']").InnerText	

	
	IF([string]::IsNullOrEmpty($customDir)) {            
    Write-Host "NO CUSTOMIZATION DIR SPECIFIED"
	$command = "ant.bat -Dtranstype=""$DITAOTTransType"" -Dargs.input=""$MapFileLocation"" -Doutput.dir=""$OutputFolder"" -Ddita.temp.dir=""$TempFolder"" -Dargs.draft=""$DraftComments"" -Dclean.temp=no -Dvalidate=$Dvalidate -logfile ""$LogFileLocation"""
	Write-Host "Running command ""$command"""	 
    & ant "-Dtranstype=$DITAOTTransType" "-Dargs.input=""$MapFileLocation""" "-Doutput.dir=""$OutputFolder""" "-Ddita.temp.dir=""$TempFolder""" "-Dargs.draft=$DraftComments" "-Dclean.temp=no" "-Dvalidate=$Dvalidate" "-Dcustomization.dir=""$customDir""" -logfile "$LogFileLocation" 
           
	} else {  
	Write-Host "CUSTOMIZATION DIR $customDir SPECIFIED"
    $command = "ant.bat -Dtranstype=""$DITAOTTransType"" -Dargs.input=""$MapFileLocation"" -Doutput.dir=""$OutputFolder"" -Ddita.temp.dir=""$TempFolder"" -Dargs.draft=""$DraftComments"" -Dclean.temp=no -Dvalidate=$Dvalidate -Dcustomization.dir=""$customDir"" -logfile ""$LogFileLocation"""
	Write-Host "Running command ""$command"""
	& ant "-Dtranstype=$DITAOTTransType" "-Dargs.input=""$MapFileLocation""" "-Doutput.dir=""$OutputFolder""" "-Ddita.temp.dir=""$TempFolder""" "-Dargs.draft=$DraftComments" "-Dclean.temp=no" "-Dvalidate=$Dvalidate" "-Dcustomization.dir=""$customDir""" -logfile "$LogFileLocation" 
           
	}
	
	
}

function RunAnt_Wordemc
{
	param
	(
		[String]$MapFileLocation,
		[String]$OutputFolder,
		[String]$TempFolder,
		[String]$LogFileLocation,
		[String]$DITAOTTransType, # e.g. ishditadelivery
		[String]$DraftComments, # yes/no
		[String]$Compare, # yes/no
		[String]$CombinedLanguages, # yes/no
		[String]$PublishPostProcessContextFileLocation
	)

	Write-Host "Running RunAnt_pdf2..."

	# If "Compare<>yes" set validate to "yes" as the input files for DITA-OT should contain valid DITA xml
	$Dvalidate = "yes"
	If ($Compare -eq "yes")
	{
		# If "Compare=yes" set validate to "no" as the input files for DITA-OT contains the comparison result and may not be valid DITA anymore
		$Dvalidate = "no"
	}

	[xml]$xmlContextFile = Get-Content -Path $PublishPostProcessContextFileLocation
	$outputformatfileLocation = $xmlContextFile.SelectSingleNode("/publishpostprocesscontext/outputformatfile").InnerText
	[xml]$outputformatfile = Get-Content -Path $outputformatfileLocation
	$StationaryWord = $outputformatfile.SelectSingleNode("//ishfield[@name='FWEBWORKSSTATIONARY' and @level='none']").InnerText	
    $TargetWord = $outputformatfile.SelectSingleNode("//ishfield[@name='FWEBWORKSTARGET' and @level='none']").InnerText	
    	
	
    $command = "ant.bat -Dtranstype=""$DITAOTTransType"" -Dargs.input=""$MapFileLocation"" -Doutput.dir=""$OutputFolder"" -Ddita.temp.dir=""$TempFolder"" -Dargs.draft=""$DraftComments"" -Dclean.temp=no -Dvalidate=$Dvalidate -Dcustomization.dir=""$customDir"" -logfile ""$LogFileLocation"""
	Write-Host "Running command ""$command"""	
    & ant "-Dtranstype=$DITAOTTransType" "-Dargs.input=""$MapFileLocation""" "-Doutput.dir=""$OutputFolder""" "-Ddita.temp.dir=""$TempFolder""" "-Dargs.draft=$DraftComments" "-Dclean.temp=no" "-Dvalidate=$Dvalidate" "-Dargs.stationery=""$StationaryWord""" "-Dargs.target=""$TargetWord""" -logfile "$LogFileLocation" "-Dargs.word.template.path=plugins/com.emc.word/templates/gimsword.dot"
	
}