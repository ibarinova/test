<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xr="http://xml.rocks"
                exclude-result-prefixes="xr"
                version="2.0">

    <xsl:output indent="yes" omit-xml-declaration="yes" />

    <xsl:param name="ishcondition-structure-json"/>

    <xsl:variable name="ishcondition-structure-json-uri" select="concat('file:///', translate($ishcondition-structure-json, '\', '/'))"/>

    <xsl:template match="/">
        <xsl:value-of select="/descendant::*[@name = 'ishcondition-structure-json-variable']"/>
        <xsl:value-of disable-output-escaping="yes" select="unparsed-text($ishcondition-structure-json-uri)"/>
        <xsl:text>;</xsl:text>
    </xsl:template>

</xsl:stylesheet>
