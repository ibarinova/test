<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="xs"
                version="2.0">

    <xsl:import href="plugin:com.oxygenxml.webhelp.responsive:xsl/search/createSearchExcludesFile.xsl"/>

    <xsl:template match="bookmap">
        <xsl:variable name="tempDir" select="substring-before(translate(base-uri(.), '\', '/'), tokenize(translate(base-uri(.), '\', '/'), '/')[last()])"/>
        <xsl:variable name="jobXmlFilePath" select="concat($tempDir, '.job.xml')"/>
        <xsl:variable name="resourceOnlyTopics">
            <xsl:choose>
                <xsl:when test="doc-available($jobXmlFilePath)">
                    <xsl:copy-of select="document($jobXmlFilePath)/descendant::file[@resource-only = 'true']"/>
                </xsl:when>
                <xsl:otherwise>
                    <dummy/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:text>dummy.xml
</xsl:text>

        <xsl:for-each select="$resourceOnlyTopics/descendant::file">
            <xsl:choose>
                <xsl:when test="ends-with(@path, $OUT_EXTENSION)">
                    <xsl:value-of select="@path"/>
                </xsl:when>
                <xsl:when test="ends-with(@path, '.xml')">
                    <xsl:value-of select="concat(substring-before(@path, '.xml'), $OUT_EXTENSION)"/>
                </xsl:when>
                <xsl:when test="ends-with(@path, '.dita')">
                    <xsl:value-of select="concat(substring-before(@path, '.dita'), $OUT_EXTENSION)"/>
                </xsl:when>
            </xsl:choose>
            <xsl:text>
</xsl:text>
        </xsl:for-each>

        <xsl:apply-templates/>
    </xsl:template>

</xsl:stylesheet>