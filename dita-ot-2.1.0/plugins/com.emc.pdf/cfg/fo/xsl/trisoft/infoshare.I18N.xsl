<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!-- ============================================================== -->
	<xsl:param name="DEFAULTLANG">en</xsl:param>
	<xsl:variable name="jobTicketLngValue">
	  	<xsl:call-template name="getJobTicketParam">
		  	<xsl:with-param name="varname">language</xsl:with-param>
		  	<xsl:with-param name="default"></xsl:with-param>
	  	</xsl:call-template>	
	</xsl:variable>
	<xsl:param name="language">
    		<xsl:call-template name="get.current.language" />
	</xsl:param>
	<!-- ============================================================== -->
	<xsl:template name="get.original.language">
		<xsl:choose>
			<xsl:when test="string-length(ancestor-or-self::*[1]/@xml:lang) > 0">
				<!--xsl:message>following language found on ancestor-or-self: <xsl:value-of select="ancestor-or-self::*/@xml:lang"/></xsl:message-->
				<xsl:value-of select="ancestor-or-self::*/@xml:lang"/>
			</xsl:when>
			<xsl:when test="string-length($jobTicketLngValue) > 0">
				<!--xsl:message>following language found on within JobTicket: <xsl:value-of select="$jobTicketLngValue"/></xsl:message-->
				<xsl:value-of select="$jobTicketLngValue"/>
			</xsl:when>
			<xsl:otherwise>
				<!--xsl:message>no language found - used default language: <xsl:value-of select="$DEFAULTLANG"/></xsl:message-->
				<xsl:value-of select="$DEFAULTLANG"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- ============================================================== -->
	<xsl:template name="get.current.language">
		<xsl:variable name="original.language">
			<xsl:call-template name="get.original.language" />
		</xsl:variable>
		<xsl:call-template name="getRegionalSetting">
			<xsl:with-param name="language" select="$original.language"></xsl:with-param>
			<xsl:with-param name="name">LanguageCode</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	<!-- ============================================================== -->
	<xsl:template name="get.language-region">
		<xsl:variable name="original.language">
			<xsl:call-template name="get.original.language" />
		</xsl:variable>
		<xsl:call-template name="getRegionalSetting">
			<xsl:with-param name="language" select="$original.language"></xsl:with-param>
			<xsl:with-param name="name">LanguageRegion</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	<!-- ============================================================== -->
	<xsl:template name="getNumber">
		<xsl:param name="language"/>
		<xsl:param name="number"/>
		<xsl:choose>
			<!-- arabic numbering format -->
			<xsl:when test="$language = 'ar'">
			  <xsl:text disable-output-escaping="yes">&amp;#x</xsl:text><xsl:value-of select="660 + $number"/><xsl:text>;.</xsl:text>
			</xsl:when>
			<!-- latin numbering format -->			
			<xsl:otherwise>
			  <xsl:number format="1." />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- ============================================================== -->
	<xsl:template name="getRegionalSetting">
		<xsl:param name="regionalSettingsFileList">../resources/RegionalSettings.xml</xsl:param>
		<xsl:param name="language"/>
		<xsl:param name="name"/>
		
		<!-- Determine which file holds the regional settings for the current language -->
		<xsl:variable name="regionalSettingsFile">
			<xsl:value-of select="document($regionalSettingsFileList)/*/RegionalSettings[@xml:lang=$language][1]/@filename"/>
		</xsl:variable>
		<xsl:if test="string-length($regionalSettingsFile) > 0">
			<xsl:variable name="setting" select="document($regionalSettingsFile,document($regionalSettingsFileList))/RegionalSettings/setting[@name=$name]"/>
			<xsl:choose>
				<xsl:when test="string-length($setting) > 0">
					<xsl:value-of select="$setting"/>
				</xsl:when>
				<!-- If the current language is not the default language, try the default -->
				<xsl:when test="$language!=$DEFAULTLANG">
					<!-- Determine which file holds the defaults; then get the default translation. -->
					<xsl:variable name="backupstringfile">
						<xsl:value-of select="document($regionalSettingsFileList)/*/RegionalSettings[@xml:lang=$DEFAULTLANG]/@filename"/>
					</xsl:variable>	
					<xsl:variable name="setting-default" 	 select="document($backupstringfile,document($regionalSettingsFileList))/RegionalSettings/setting[@name=$name]"/>
					<!-- If a default was found, use it.-->
					<xsl:if test="string-length($setting-default)>0">
						<xsl:value-of select="$setting-default"/>
					</xsl:if>
				</xsl:when>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	<!-- ============================================================== -->
	<xsl:template name="getString">
		<xsl:param name="stringName"/>
		<xsl:param name="stringFileList">../resources/strings.xml</xsl:param>
		<xsl:param name="stringFile">#none#</xsl:param>
		<xsl:param name="language" />
		<xsl:choose>
			<xsl:when test="$stringFile != '#none#'">
				<!-- Use the old getString template interface -->
				<!-- Get the translated string -->
				<xsl:variable name="str" select="$stringFile/strings/str[@name=$stringName][lang($language)]"/>
				<xsl:choose>
					<!-- If the string was found, use it. Cannot test $str, because value could be empty. -->
					<xsl:when test="$stringFile/strings/str[@name=$stringName][lang($language)]">
						<xsl:value-of select="$str"/>
					</xsl:when>
					<!-- If the current language is not the default language, try the default -->
					<xsl:when test="$language!=$DEFAULTLANG">
						<!-- Determine which file holds the defaults; then get the default translation. -->
						<xsl:variable name="str-default" select="$stringFile/strings/str[@name=$stringName][lang($DEFAULTLANG)]"/>
						<xsl:choose>
							<!-- If a default was found, use it, but warn that fallback was needed.-->
							<xsl:when test="string-length($str-default)>0">
								<xsl:value-of select="$str-default"/>
							</xsl:when>
							<!-- Translation was not even found in the default language. -->
							<xsl:otherwise>
								<xsl:value-of select="$stringName"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<!-- The current language is the default; no translation found at all. -->
					<xsl:otherwise>
						<xsl:value-of select="$stringName"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<!-- Use the new getString template interface -->
				<!-- Determine which file holds translations for the current language -->
				<xsl:variable name="stringfile">
					<xsl:value-of select="document($stringFileList)/*/lang[@xml:lang=$language][1]/@filename"/>
				</xsl:variable>
				<!-- Get the translated string -->
				<xsl:variable name="str" select="document($stringfile,document($stringFileList))/strings/str[@name=$stringName]"/>
				<xsl:choose>
					<!-- If the string was found, use it. Cannot test $str, because value could be empty. -->
					<xsl:when test="document($stringfile,document($stringFileList))/strings/str[@name=$stringName]">
						<xsl:value-of select="$str"/>
					</xsl:when>
					<!-- If the current language is not the default language, try the default -->
					<xsl:when test="$language!=$DEFAULTLANG">
						<!-- Determine which file holds the defaults; then get the default translation. -->
						<xsl:variable name="backupstringfile">
							<xsl:value-of select="document($stringFileList)/*/lang[@xml:lang=$DEFAULTLANG]/@filename"/>
						</xsl:variable>
						<xsl:variable name="str-default" select="document($backupstringfile,document($stringFileList))/strings/str[@name=$stringName]"/>
						<xsl:choose>
							<!-- If a default was found, use it, but warn that fallback was needed.-->
							<xsl:when test="string-length($str-default)>0">
								<xsl:value-of select="$str-default"/>
							</xsl:when>
							<!-- Translation was not even found in the default language. -->
							<xsl:otherwise>
								<xsl:value-of select="$stringName"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<!-- The current language is the default; no translation found at all. -->
					<xsl:otherwise>
						<xsl:value-of select="$stringName"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
  <!-- ============================================================== -->
</xsl:stylesheet>













