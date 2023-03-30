<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xr="http://xml.rocks"
                exclude-result-prefixes="xr"
                version="2.0">

    <xsl:output indent="yes" omit-xml-declaration="yes" />

    <xsl:template match="/">
        <xsl:apply-templates />
    </xsl:template>

    <xsl:template match="node">
        <xsl:variable name="children" select="*[name() = 'children']"/>
        <xsl:variable name="id" select="if(normalize-space(@id)) then(@id) else('dummy')"/>
        <xsl:variable name="ancestor-hrefs">
            <xsl:choose>
                <xsl:when test="not(ancestor::*)">
                    <xsl:value-of select="ancestor-or-self::*[@root-name][1]/@root-name"/>
                    <xsl:value-of select="'#'"/>
                    <xsl:value-of select="$id"/>
                </xsl:when>
                <xsl:when test="not(ancestor::href)">
                    <xsl:value-of select="'#'"/>
                    <xsl:value-of select="$id"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="matches(ancestor::href[1]/@href, '#')">
                            <xsl:value-of select="substring-before(ancestor::href[1]/@href, '#')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="ancestor::href[1]/@href"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:value-of select="'#'"/>
                    <xsl:value-of select="ancestor::href[1]/@ref-id"/>
                    <xsl:if test="not(ancestor::href[1]/@ref-id = $id)">
                        <xsl:value-of select="'/'"/>
                        <xsl:value-of select="$id"/>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        {
        <xsl:text>"name" : "</xsl:text><xsl:value-of select="@name"/><xsl:text>",</xsl:text>
        <xsl:text>"id" : "</xsl:text><xsl:value-of select="@id"/><xsl:text>",</xsl:text>
        <xsl:text>"fullHref" : "</xsl:text><xsl:value-of select="$ancestor-hrefs"/><xsl:text>",</xsl:text>
        <xsl:text>"ishcondition" : "</xsl:text><xsl:value-of disable-output-escaping="yes" select="@ishcondition"/><xsl:text>",</xsl:text>
        <xsl:text>"children" : [</xsl:text>
            <xsl:apply-templates select="$children/*"/>
        <xsl:text>]</xsl:text>
        }
        <xsl:if test="following-sibling::*">
            <xsl:text>,</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template match="href">
        {
        <xsl:text>"href" : "</xsl:text><xsl:value-of select="@href"/><xsl:text>",</xsl:text>
        <xsl:text>"refId" : "</xsl:text><xsl:value-of select="@ref-id"/><xsl:text>",</xsl:text>
        <xsl:text>"children" : [</xsl:text>
            <xsl:apply-templates select="*"/>
        <xsl:text>]</xsl:text>
        }
        <xsl:if test="following-sibling::*">
            <xsl:text>,</xsl:text>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
