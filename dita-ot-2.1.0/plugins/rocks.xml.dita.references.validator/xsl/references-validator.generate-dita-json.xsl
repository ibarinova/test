<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xr="http://xml.rocks"
                exclude-result-prefixes="xr"
                version="2.0">
    <xsl:output indent="yes" omit-xml-declaration="yes"/>

    <xsl:template match="/">
        <xsl:apply-templates />
    </xsl:template>

    <xsl:template match="node">
        <xsl:variable name="meta" select="*[name() = 'meta']"/>
        <xsl:variable name="nested-ishconditions" select="*[name() = 'nested-ishconditions']"/>
        <xsl:variable name="children" select="*[name() = 'children']"/>
        {
        <xsl:text>"type" : "</xsl:text><xsl:value-of select="@type"/><xsl:text>",</xsl:text>
        <xsl:text>"id" : "</xsl:text><xsl:value-of select="@id"/><xsl:text>",</xsl:text>
        <xsl:text>"ltype" : "</xsl:text><xsl:value-of select="@ltype"/><xsl:text>",</xsl:text>
        <xsl:text>"tooltip" : "</xsl:text><xsl:value-of disable-output-escaping="yes" select="xr:escapeCharacters(@tooltip)"/><xsl:text>",</xsl:text>
        <xsl:text>"href" : "</xsl:text><xsl:value-of select="@href"/><xsl:text>",</xsl:text>
        <xsl:text>"fullHref" : "</xsl:text><xsl:value-of select="@full-href"/><xsl:text>",</xsl:text>
        <xsl:text>"title" : "</xsl:text><xsl:value-of disable-output-escaping="yes" select="xr:escapeCharacters(@title)"/><xsl:text>",</xsl:text>
        <xsl:text>"ishcondition" : "</xsl:text><xsl:value-of disable-output-escaping="yes" select="@ishcondition"/><xsl:text>",</xsl:text>
        <xsl:text>"meta" : {</xsl:text>
            <xsl:apply-templates select="$meta"/>
        <xsl:text>},</xsl:text>
        <xsl:text>"nested-ishconditions" : [</xsl:text>
            <xsl:apply-templates select="$nested-ishconditions/*"/>
        <xsl:text>],</xsl:text>
        <xsl:text>"children" : [</xsl:text>
            <xsl:apply-templates select="$children/*"/>
        <xsl:text>]</xsl:text>
        }
        <xsl:if test="following-sibling::node">
            <xsl:text>,</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template match="meta">
        <xsl:text>"ftitle" : "</xsl:text><xsl:value-of select="@ftitle"/><xsl:text>",</xsl:text>
        <xsl:text>"shortdesc" : "</xsl:text><xsl:value-of disable-output-escaping="yes" select="xr:escapeCharacters(@shortdesc)"/><xsl:text>",</xsl:text>
        <xsl:text>"LCAversion" : "</xsl:text><xsl:value-of select="@LCAversion"/><xsl:text>",</xsl:text>
        <xsl:text>"LCArevision" : "</xsl:text><xsl:value-of select="@LCArevision"/><xsl:text>",</xsl:text>
        <xsl:text>"LCAstatus" : "</xsl:text><xsl:value-of select="@LCAstatus"/><xsl:text>"</xsl:text>
    </xsl:template>

    <xsl:template match="ishcondition">
        {
        <xsl:text>"ishcondition" : "</xsl:text><xsl:value-of disable-output-escaping="yes" select="."/><xsl:text>"</xsl:text>
        }
        <xsl:if test="following-sibling::ishcondition">
            <xsl:text>,</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:function name="xr:escapeCharacters">
        <xsl:param name="string"/>

        <xsl:variable name="quot" select="'&quot;'"/>
        <xsl:variable name="escape-quot" select="'&amp;quot;'"/>
        <xsl:variable name="lt" select="'&lt;'"/>
        <xsl:variable name="escape-lt" select="'&amp;lt;'"/>
        <xsl:variable name="gt" select="'&gt;'"/>
        <xsl:variable name="escape-gt" select="'&amp;gt;'"/>
        <xsl:variable name="apos" select="'&quot;'"/>
        <xsl:variable name="escape-apos" select="'&amp;apos;'"/>
        <xsl:variable name="bckslash" select="'\\'"/>
        <xsl:variable name="escape-bckslash" select="'\\\\'"/>

        <xsl:sequence select="replace(replace(replace(replace(replace($string, $quot, $escape-quot), $apos, $escape-apos), $bckslash, $escape-bckslash), $lt, $escape-lt), $gt, $escape-gt)"/>
    </xsl:function>
</xsl:stylesheet>
