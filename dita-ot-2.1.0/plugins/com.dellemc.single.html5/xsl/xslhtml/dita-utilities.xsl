<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
                exclude-result-prefixes="xs dita-ot">

    <xsl:template name="getLowerCaseLang">
        <xsl:variable name="ancestorlangUpper">
            <!-- the current xml:lang value (en-us if none found) -->
            <xsl:choose>
                <xsl:when test="name() = 'dita'">
                    <xsl:value-of select="/descendant::*[@xml:lang][1]/@xml:lang"/>
                </xsl:when>
                <xsl:when test="ancestor-or-self::*/@xml:lang">
                    <xsl:value-of select="ancestor-or-self::*[@xml:lang][1]/@xml:lang"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$DEFAULTLANG"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="lower-case($ancestorlangUpper)"/>
    </xsl:template>

</xsl:stylesheet>