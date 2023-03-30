<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ot-placeholder="http://suite-sol.com/namespaces/ot-placeholder"
    xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
    exclude-result-prefixes="xs dita-ot">
    
    <xsl:template match="*[contains(@class,' bookmap/chapter ')][not(@href)] | *[contains(@class,' bookmap/appendix ')][not(@href)]" mode="build-tree">
        <topic id="{generate-id()}" class="- topic/topic ">
            <title class="- topic/title ">
                <xsl:choose>
                    <xsl:when test="*[contains(@class,' map/topicmeta ')]/*[contains(@class,' topic/navtitle ')] and @locktitle = 'yes'">
                        <xsl:copy-of select="*[contains(@class,' map/topicmeta ')]/*[contains(@class,' topic/navtitle ')]/node()"/>
                    </xsl:when>
                    <xsl:when test="@navtitle">
                        <xsl:value-of select="@navtitle"/>
                    </xsl:when>
                    <xsl:otherwise>UNKNOWN</xsl:otherwise>
                </xsl:choose>
            </title>
            <body class=" topic/body "/>
            <xsl:apply-templates mode="build-tree"/>
        </topic>
    </xsl:template>
    
</xsl:stylesheet>