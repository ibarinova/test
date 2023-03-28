<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:xs="http://www.w3.org/2001/XMLSchema"
				exclude-result-prefixes="xs" version="2.0"
				xmlns:d="http://docbook.org/ns/docbook" xmlns:toc="http://www.oxygenxml.com/ns/webhelp/toc"
				xmlns:index="http://www.oxygenxml.com/ns/webhelp/index"
				xmlns:oxygen="http://www.oxygenxml.com/functions">

	<xsl:import href="plugin:com.oxygenxml.webhelp.responsive:xsl/mainFiles/createLocalizationFiles.xsl"/>

	<xsl:param name="WEBHELP_FEEDBACK_ENABLED"/>
	<xsl:param name="DITA_OT_PLUGINS_FILE_URL"/>

	<xsl:template name="copyExtensionPluginStrings">
		<xsl:param name="language"/>

		<!-- URL to DITA-OT plugins file. Ussualy located in resources folder -->
		<xsl:variable name="ditaotPluginsURL" select="oxygen:makeURL($DITA_OT_PLUGINS_FILE_URL)"/>

		<xsl:choose>
			<xsl:when test="doc-available($ditaotPluginsURL)">
				<xsl:variable name="allPluginsDoc" select="doc($ditaotPluginsURL)"/>
				<xsl:variable
						name="xslStringsExtensionsFile"
						select="$allPluginsDoc//plugin[require/@plugin='com.oxygenxml.webhelp.responsive']/feature[@extension='dita.xsl.strings'][1]/@file"/>
				<xsl:choose>
					<xsl:when
							test="exists($xslStringsExtensionsFile)">
						<!-- There is an extensions plugins that contributes strings -->
						<xsl:variable
								name="extensionPluginBaseURL"
								select="$allPluginsDoc//plugin[require/@plugin='com.oxygenxml.webhelp.responsive'][feature/@extension='dita.xsl.strings']/@xml:base"/>
						<!--<xsl:message>xml:base: <xsl:value-of select="$extensionPluginBaseURL"/></xsl:message>-->

						<xsl:variable name="extensionPluginURL"
									  select="resolve-uri(
                            $extensionPluginBaseURL,
                            $ditaotPluginsURL)"/>

						<xsl:variable name="extensionsStringURL"
									  select="resolve-uri(
                            $xslStringsExtensionsFile,
                            $extensionPluginURL)"/>

						<xsl:choose>
							<xsl:when test="doc-available($extensionsStringURL)">
								<!-- Strings file for language -->
								<xsl:variable
										name="stringFileName"
										select="doc($extensionsStringURL)//lang[lower-case(@xml:lang) = lower-case($language)]/@filename"/>


								<xsl:variable name="stringFileURL"
											  select="resolve-uri($stringFileName, $extensionsStringURL)"/>

								<xsl:choose>
									<xsl:when test="doc-available($stringFileURL)">
										<xsl:sequence select="doc($stringFileURL)/*"/>
									</xsl:when>
								</xsl:choose>
							</xsl:when>
						</xsl:choose>
					</xsl:when>
				</xsl:choose>

			</xsl:when>
			<xsl:otherwise>
				<xsl:message>ERROR: The 'resources/plugins.xml' resource is not available.</xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>