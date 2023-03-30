<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xr="http://xml.rocks"
                exclude-result-prefixes="xr"
                version="2.0">

    <xsl:function name="xr:prepareIshconditionValue">
        <xsl:param name="string"/>
        <xsl:sequence select="xr:removeSingleQuotes(xr:escapeSpace($string))"/>
    </xsl:function>

    <xsl:function name="xr:removeSingleQuotes">
        <xsl:param name="string"/>
        <xsl:variable name="apos">'</xsl:variable>
        <xsl:sequence select="replace($string, $apos, '')"/>
    </xsl:function>

    <xsl:function name="xr:escapeSpace">
        <xsl:param name="string"/>
        <xsl:variable name="nbsp">&amp;nbsp;</xsl:variable>

        <xsl:variable name="result">
            <xsl:if test="normalize-space($string)">
                <xsl:analyze-string select="$string" regex="'[^']+'">
                    <xsl:matching-substring>
                        <xsl:value-of select="replace(., ' ', '&amp;nbsp;')"/>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:value-of select="."/>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:if>
        </xsl:variable>

        <xsl:sequence select="$result"/>
    </xsl:function>

</xsl:stylesheet>