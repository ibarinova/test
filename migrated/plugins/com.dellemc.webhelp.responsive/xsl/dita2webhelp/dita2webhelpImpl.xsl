<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				exclude-result-prefixes="#all"
				version="2.0">

	<xsl:import href="dita2xhtml.xsl"/>

	<xsl:import href="fixup.xsl"/>
	<xsl:import href="../template/topicComponentsExpander.xsl"/>

	<xsl:import href="tables.xsl"/>
	<xsl:import href="simpletable.xsl"/>
	<xsl:import href="topic.xsl"/>
	<xsl:import href="task.xsl"/>
	<xsl:import href="reference.xsl"/>
	<xsl:import href="rel-links.xsl"/>

	<xsl:template name="replace-extension">
		<xsl:param name="filename"/>
		<xsl:param name="extension"/>
		<xsl:param name="ignore-fragment" select="false()"/>
		<xsl:param name="forceReplace" select="false()"/>
		<xsl:variable name="file-path">
			<xsl:choose>
				<xsl:when test="contains($filename, '#')">
					<xsl:value-of select="substring-before($filename, '#')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$filename"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="f">
			<xsl:call-template name="substring-before-last">
				<xsl:with-param name="text" select="$file-path"/>
				<xsl:with-param name="delim" select="'.'"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="fxml" select="concat($f, '.xml')"/>
		<xsl:variable name="original-extension">
			<xsl:call-template name="substring-after-last">
				<xsl:with-param name="text" select="$file-path"/>
				<xsl:with-param name="delim" select="'.'"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="string($f)">
			<xsl:choose>
				<xsl:when test="$properties-xml-doc/descendant::*[@name = $fxml][1][normalize-space(@new-name)]">
					<xsl:variable name="new-name" select="$properties-xml-doc/descendant::*[@name = $fxml][1]/@new-name"/>
					<xsl:value-of select="concat(substring-before($new-name, '.'), $extension)"/>
				</xsl:when>
				<xsl:when test="$forceReplace or $original-extension = 'xml' or $original-extension = 'dita'">
					<xsl:value-of select="concat($f, $extension)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat($f, '.', $original-extension)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<xsl:if test="not($ignore-fragment) and contains($filename, '#')">
			<xsl:value-of select="concat('#', substring-after($filename, '#'))"/>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>