set-strictmode -version 2.0

function PrintAndValidatePath
{
	param
	(
		[String]$key,
		[String]$value
	)
	
	If ($value -eq "")
	{
		Write-Host "$key is empty"
	}
	Else
	{
		If (-not (Test-Path $value))
		{
			Write-Host "*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*"
			Write-Host "*-* Config.psm1::VALUE OF PARAMETER $key IS NOT A FOLDER"
			Write-Host "*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*"
		}
		Write-Host "$key=$value"
	}
}

function PrintAndValidateFilePath
{
	param
	(
		[String]$key,
		[String]$value
	)
	
	If ($value -eq "")
	{
		Write-Host "$key is empty"
	}
	Else
	{
		If (-not (Test-Path $value))
		{
			Write-Host "*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*"
			Write-Host "*-* Config.psm1::VALUE OF PARAMETER $key IS NOT A FILE"
			Write-Host "*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*"
		}
		Write-Host "$key=$value"
	}
}

function PrintParameter
{
	param
	(
		[String]$key,
		[String]$value
	)
	
	If ($value -eq "")
	{
		Write-Host "$key is empty!"
	}
	Else
	{
		Write-Host "$key=$value"
	}
}

Write-Host "Config.psm1::Initialising InstallTool values"
$ENV:PS_BASEPATH="E:\InfoShare\Data\PublishingService"
$ENV:PS_TOOLPATH="E:\InfoShare\App\Utilities\PublishingService\Tools"
$ENV:PS_ERROROBJECTLOCATION="E:\InfoShare\App\Utilities\PublishingService\Resources"
$ENV:PS_DITAOT=(Get-Location).Path
$ENV:PS_UTILITIES="E:\InfoShare\App\Utilities"
# 2020-04-13 Dana removing this declaration to force DITAOT to take the Java version specified in BackgroundTaskIso.exe.config
#$ENV:JAVA_HOME="C:\Program Files\Java\jdk1.8.0_144"
$ENV:JHHOME="C:\javahelp\jh2.0"
$ENV:AXF_DIR="C:\Program Files\Antenna House\AHFormatterV71"
$ENV:AXF_OPT="E:\InfoShare\App\Utilities\AntennaHouse\XSLFormatter\XfoSettings.xml"
# $ENV:XEP_DIR="C:\Program Files\Antenna House\AHFormatterV65"
# $ENV:PE_DIR="C:\Program Files\Antenna House\AHFormatterV65"
$ENV:HHCDIR="C:\Program Files (x86)\HTML Help Workshop"
$ENV:PDF_FORMATTER="ah"

$ENV:ANT_HOME=$ENV:PS_DITAOT
$ENV:PATH="$ENV:JAVA_HOME\bin;$ENV:ANT_HOME\bin;$ENV:PATH"

$ENV:CLASSPATH="$ENV:PS_DITAOT\lib\ant-launcher.jar;$ENV:CLASSPATH"

If ($ENV:PROCESSOR_ARCHITECTURE -eq "AMD64")
{
  $ENV:ANT_OPTS="-Xmx4096m -Xss20m $ENV:ANT_OPTS"
}
Else
{
  $ENV:ANT_OPTS="-Xmx1500m -Xss20m $ENV:ANT_OPTS"
}
$ENV:ANT_OPTS="$ENV:ANT_OPTS -Djavax.xml.transform.TransformerFactory=net.sf.saxon.TransformerFactoryImpl"

PrintAndValidatePath "PS_BASEPATH" $ENV:PS_BASEPATH
PrintAndValidatePath "PS_UTILITIES" $ENV:PS_UTILITIES
PrintAndValidatePath "PS_TOOLPATH" $ENV:PS_TOOLPATH
PrintAndValidatePath "PS_ERROROBJECTLOCATION" $ENV:PS_ERROROBJECTLOCATION
PrintAndValidatePath "PS_DITAOT" $ENV:PS_DITAOT
PrintAndValidatePath "JAVA_HOME" $ENV:JAVA_HOME
PrintAndValidatePath "ANT_HOME" $ENV:ANT_HOME
PrintAndValidatePath "JHHOME" $ENV:JHHOME
PrintAndValidatePath "AXF_DIR" $ENV:AXF_DIR
PrintAndValidateFilePath "AXF_OPT" $ENV:AXF_OPT
PrintAndValidatePath "XEP_DIR" $ENV:XEP_DIR
PrintAndValidatePath "PE_DIR" $ENV:PE_DIR
PrintAndValidatePath "HHCDIR" $ENV:HHCDIR
PrintParameter "PDF_FORMATTER" $ENV:PDF_FORMATTER
PrintParameter "PATH" $ENV:PATH
PrintParameter "CLASSPATH" $ENV:CLASSPATH
PrintParameter "ANT_OPTS" $ENV:ANT_OPTS
PrintParameter "TEMP" $ENV:TEMP
PrintParameter "TMP" $ENV:TMP
PrintParameter "PROCESSOR_ARCHITECTURE" $ENV:PROCESSOR_ARCHITECTURE
PrintParameter "DOMAIN\USERNAME" $ENV:USERDOMAIN\$ENV:USERNAME
