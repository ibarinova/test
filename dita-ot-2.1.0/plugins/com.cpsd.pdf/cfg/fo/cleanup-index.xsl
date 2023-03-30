<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:opentopic-index="http://www.idiominc.com/opentopic/index"
    exclude-result-prefixes="xs opentopic-index xsl"
    version="2.0">
    
    <xsl:output method="xml" standalone="yes"/>
    
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- mckimn 07-Oct-2016: Resort index subentries to put EN terms first -->
    <xsl:template match="opentopic-index:index.entry">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="node()[not(self::opentopic-index:index.entry)]"/>
            <xsl:for-each-group select="opentopic-index:index.entry" 
                group-by="opentopic-index:formatted-value">
                <xsl:sort select="lower-case(opentopic-index:formatted-value)"/>
                <xsl:copy-of select="." copy-namespaces="no"/>
            </xsl:for-each-group>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>