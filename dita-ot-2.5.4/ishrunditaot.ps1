# ishrunditaot.cmd is called from the IshRunDITAOT publishpostprocess plugin

#
# READING SCRIPT ARGUMENTS
#  
param
(
	[Parameter(Position=0)]
	$MapFileLocation,
	[Parameter(Position=1)]
	$OutputFolder,
	[Parameter(Position=2)]
	$TempFolder,
	[Parameter(Position=3)]
	$LogFileLocation,
	[Parameter(Position=4)]
	$DITAOTTransType, # e.g. ishditadelivery
	[Parameter(Position=5)]
	$DraftComments, # yes/no
	[Parameter(Position=6)]
	$Compare, # yes/no
	[Parameter(Position=7)]
	$CombinedLanguages, # yes/no
	[Parameter(Position=8)]
	$PublishPostProcessContextFileLocation
)

Write-Host "*********************************"
Write-Host "ISHRUNDITAOT.ps1"
Write-Host "*********************************"

$DebugPreference   = "SilentlyContinue"   # Continue or SilentlyContinue
$VerbosePreference = "SilentlyContinue"   # Continue or SilentlyContinue
$WarningPreference = "Continue"           # Continue or SilentlyContinue or Stop
$ProgressPreference= "SilentlyContinue"   # Continue or SilentlyContinue
$ErrorActionPreference = "Stop"           # Treat all errors as terminating errors

#
# LOAD MODULES
#
Write-Host "Loading Modules..."	
Import-Module ./config.psm1
# Custom modules
Import-Module ./config.custom.psm1
Import-Module ./dita-ot-ishhtmlhelp.psm1
Import-Module ./dita-ot-dellemc.psm1

$Dvalidate = "yes"
	If ($Compare -eq "yes")
	{
		# If "Compare=yes" set validate to "no" as the input files for DITA-OT contains the comparison result and may not be valid DITA anymore
		$Dvalidate = "no"
	}

if ($DITAOTTransType -eq "ishhtmlhelp" -or $DITAOTTransType -eq "html5-webhelp-emc")
{
	RunAnt_IshHtmlHelp $MapFileLocation $OutputFolder $TempFolder $LogFileLocation $DITAOTTransType $DraftComments $Compare $CombinedLanguages $PublishPostProcessContextFileLocation
}

elseif ($DITAOTTransType -eq "dell-webhelp-responsive" -or $DITAOTTransType -eq "dellemc-webhelp-responsive.draft" -or $DITAOTTransType -eq "dellemc-webhelp-responsive.rsa")
{
	RunAnt_DellEMCWEB $MapFileLocation $OutputFolder $TempFolder $LogFileLocation $DITAOTTransType $DraftComments $Compare $CombinedLanguages $PublishPostProcessContextFileLocation
}

elseif ($DITAOTTransType -eq "dell-webhelp-responsive.draft" -or $DITAOTTransType -eq "html5-webhelp-emc-draft" -or $DITAOTTransType -eq "html5-webhelp-rsa-draft" -or $DITAOTTransType -eq "webhelp-draft" -or $DITAOTTransType -eq "webhelp-mobile-draft" -or $DITAOTTransType -eq "webhelp-mobile-rsa-draft" -or $DITAOTTransType -eq "webhelp-rsa-draft" -or $DITAOTTransType -eq "webhelp-single-draft" -or $DITAOTTransType -eq "xhtml-emc-draft" -or $DITAOTTransType -eq "xhtml-mozy-draft" -or $DITAOTTransType -eq "webhelp-responsive.rsa.draft" -or $DITAOTTransType -eq "dellemc-webhelp-responsive.draft" -or $DITAOTTransType -eq "dellemc-webhelp-responsive.rsa.draft")
{
	$DraftComments = "yes"
    RunAnt_DellEMCWEB $MapFileLocation $OutputFolder $TempFolder $LogFileLocation $DITAOTTransType $DraftComments $Compare $CombinedLanguages $PublishPostProcessContextFileLocation
}

elseif ($DITAOTTransType -eq "atl" -or $DITAOTTransType -eq "html5-responsive" -or $DITAOTTransType -eq "emc-visualizer")
{
	RunAnt_DellEMCGeneric $MapFileLocation $OutputFolder $TempFolder $LogFileLocation $DITAOTTransType $DraftComments $Compare $CombinedLanguages $PublishPostProcessContextFileLocation
}

elseif ($DITAOTTransType -eq "qa")
{
	RunAnt_DellEMCQA $MapFileLocation $OutputFolder $TempFolder $LogFileLocation $DITAOTTransType $DraftComments $Compare $CombinedLanguages $PublishPostProcessContextFileLocation
}

elseif ($DITAOTTransType -eq "pdf-emc" -or $DITAOTTransType -eq "emcpdf")
{
	RunAnt_pdfemcRetainTopic $MapFileLocation $OutputFolder $TempFolder $LogFileLocation $DITAOTTransType $DraftComments $Compare $CombinedLanguages $PublishPostProcessContextFileLocation
}

elseif ($DITAOTTransType -eq "pdf-insert-emc")
{
	RunAnt_pdfemc $MapFileLocation $OutputFolder $TempFolder $LogFileLocation $DITAOTTransType $DraftComments $Compare $CombinedLanguages $PublishPostProcessContextFileLocation
}

elseif ($DITAOTTransType -eq "word-emc" -or $DITAOTTransType -eq "word-solgen")
{
	RunAnt_pdfemc $MapFileLocation $OutputFolder $TempFolder $LogFileLocation $DITAOTTransType $DraftComments $Compare $CombinedLanguages $PublishPostProcessContextFileLocation
}

elseif ($DITAOTTransType -eq "plainhtml")
{
	RunAnt_DellSUPPORTHTML $MapFileLocation $OutputFolder $TempFolder $LogFileLocation $DITAOTTransType $DraftComments $Compare $CombinedLanguages $PublishPostProcessContextFileLocation
}
elseif ($DITAOTTransType -eq "aemhtml")
{
	RunAnt_DellAEM $MapFileLocation $OutputFolder $TempFolder $LogFileLocation $DITAOTTransType $DraftComments $Compare $CombinedLanguages $PublishPostProcessContextFileLocation
}
elseif ($DITAOTTransType -eq "json")
{
	RunAnt_Json $MapFileLocation $OutputFolder $TempFolder $LogFileLocation $DITAOTTransType $DraftComments $Compare $CombinedLanguages $PublishPostProcessContextFileLocation
}

else
{
	# If "Compare<>yes" set validate to "yes" as the input files for DITA-OT should contain valid DITA xml

	$command = "ant.bat -Dtranstype=""$DITAOTTransType"" -Dargs.input=""$MapFileLocation"" -Doutput.dir=""$OutputFolder"" -Ddita.temp.dir=""$TempFolder"" -Dargs.draft=""$DraftComments"" -Dclean.temp=no -Dvalidate=$Dvalidate -logfile ""$LogFileLocation"""
	Write-Host "Running command ""$command"""
	& ant.bat "-Dtranstype=$DITAOTTransType" "-Dargs.input=""$MapFileLocation""" "-Doutput.dir=""$OutputFolder""" "-Ddita.temp.dir=""$TempFolder""" "-Dargs.draft=$DraftComments" "-Dclean.temp=no" "-Dvalidate=$Dvalidate" -logfile "$LogFileLocation"
	$exitCode = $LASTEXITCODE
	Write-Host "ant completed with exit code $exitCode"
	exit $exitCode
}