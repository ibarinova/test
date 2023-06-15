<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:xs="http://www.w3.org/2001/XMLSchema"
				exclude-result-prefixes="xs" version="2.0"
				xmlns:d="http://docbook.org/ns/docbook" xmlns:toc="http://www.oxygenxml.com/ns/webhelp/toc"
				xmlns:index="http://www.oxygenxml.com/ns/webhelp/index"
				xmlns:oxygen="http://www.oxygenxml.com/functions">

	<xsl:import href="plugin:com.oxygenxml.webhelp.responsive:xsl/mainFiles/createLocalizationFiles.xsl"/>

	<xsl:param name="DITA_OT_PLUGINS_FILE_PATH"/>

	<xsl:template name="copyExtensionPluginStrings">
		<xsl:param name="language"/>

		<!-- URL to DITA-OT plugins file. Ussualy located in resources folder -->
		<xsl:variable name="ditaotPluginsURL" select="oxygen:makeURL($DITA_OT_PLUGINS_FILE_PATH)"/>

		<xsl:message>!!!!!!!DITA_OT_PLUGINS_FILE_PATH: <xsl:value-of select="$DITA_OT_PLUGINS_FILE_PATH"/></xsl:message>
		<xsl:message>ditaotPluginsURL: <xsl:value-of select="$ditaotPluginsURL"/></xsl:message>
		<xsl:message>doc-available($ditaotPluginsURL): <xsl:value-of select="doc-available($ditaotPluginsURL)"/></xsl:message>

		<xsl:choose>
			<xsl:when test="doc-available($ditaotPluginsURL)">
				<xsl:variable name="allPluginsDoc" select="doc($ditaotPluginsURL)"/>
				<xsl:variable
						name="xslStringsExtensionsFile"
						select="$allPluginsDoc//plugin[@id = 'com.dellemc.common.resources'][1]/feature[@extension='dita.xsl.strings'][1]/@file"/>

				<xsl:message>xslStringsExtensionsFile <xsl:value-of select="$xslStringsExtensionsFile"/></xsl:message>

				<xsl:choose>
					<xsl:when
							test="exists($xslStringsExtensionsFile)">
						<!-- There is an extensions plugins that contributes strings -->
						<xsl:variable
								name="extensionPluginBaseURL"
								select="$allPluginsDoc//plugin[@id = 'com.dellemc.common.resources'][feature/@extension='dita.xsl.strings']/@xml:base"/>
						<xsl:message>!!!!!!! xml:base: <xsl:value-of select="$extensionPluginBaseURL"/></xsl:message>

						<xsl:variable name="extensionPluginURL"
									  select="resolve-uri(
                            $extensionPluginBaseURL,
                            $ditaotPluginsURL)"/>

						<xsl:message>extensionPluginURL = <xsl:value-of select="$extensionPluginURL"/> </xsl:message>
						<xsl:variable name="extensionsStringURL"
									  select="resolve-uri(
                            $xslStringsExtensionsFile,
                            $extensionPluginURL)"/>

						<xsl:message>extensionsStringURL = <xsl:value-of select="$extensionsStringURL"/> </xsl:message>
						<xsl:message>doc-available($extensionsStringURL) = <xsl:value-of select="doc-available($extensionsStringURL)"/> </xsl:message>

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