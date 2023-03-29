<?xml version="1.0"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                version="2.0">

    <xsl:template match="*[@outputclass = 'pagebreak'][count(ancestor-or-self::*[contains(@class, 'table')]) = 0]" priority="9">
        <xsl:choose>
            <xsl:when test="contains(@class,' topic/title ') and parent::*[contains(@class, ' topic/fig ')]">
                <xsl:next-match/>
            </xsl:when>
            <xsl:when test="contains(@class,' topic/li ')">
                <xsl:next-match>
                    <xsl:with-param name="pagebreak" tunnel="yes">yes</xsl:with-param>
                </xsl:next-match>
            </xsl:when>
            <xsl:when test="self::*[contains(@class, ' topic/fig ')][child::*[contains(@class, ' topic/title ')][@outputclass = 'pagebreak']]">
                <fo:block break-before="page">
                    <xsl:next-match/>
                </fo:block>
            </xsl:when>
            <xsl:otherwise>
                <fo:block break-before="page">
                    <xsl:next-match/>
                </fo:block>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[contains(@outputclass, 'nopagebreak')][count(ancestor-or-self::*[contains(@class, 'table')]) = 0]" priority="9">
        <xsl:choose>
            <xsl:when test="contains(@class,' topic/title ') and parent::*[contains(@class, ' topic/fig ')]">
                <xsl:next-match/>
            </xsl:when>
            <xsl:when test="contains(@class,' topic/li ')">
                <xsl:next-match>
                    <xsl:with-param name="pagebreak" tunnel="yes">nopagebreak</xsl:with-param>
                </xsl:next-match>
            </xsl:when>
            <xsl:when test="self::*[contains(@class, ' topic/fig ')][child::*[contains(@class, ' topic/title ')][contains(@outputclass, 'nopagebreak')]]">
                <fo:block keep-together.within-page="5">
                    <xsl:next-match/>
                </fo:block>
            </xsl:when>
            <xsl:otherwise>
                <fo:block keep-together.within-page="5">
                    <xsl:next-match/>
                </fo:block>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>