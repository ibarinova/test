<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xr="http://xml.rocks"
                exclude-result-prefixes="xr"
                version="2.0">

    <xsl:output indent="yes" omit-xml-declaration="yes" />

    <xsl:param name="dita-json"/>
    <xsl:param name="merged-map"/>

    <xsl:variable name="dita-json-uri" select="concat('file:///', translate($dita-json, '\', '/'))"/>
    <xsl:variable name="merged-map-uri" select="concat('file:///', translate($merged-map, '\', '/'))"/>
    <xsl:variable name="merged-map-doc" select="doc($merged-map-uri)"/>

    <xsl:template match="/">
        <xsl:call-template name="insertPublicationTitle"/>
        <xsl:call-template name="insertSetOfIshconditions"/>
        <xsl:value-of select="/descendant::*[@name = 'dita-json-variable']"/>
        <xsl:value-of disable-output-escaping="yes" select="unparsed-text($dita-json-uri)"/>
        <xsl:text>;</xsl:text>
    </xsl:template>

    <xsl:template name="insertPublicationTitle">
        <xsl:variable name="title">
            <xsl:choose>
                <xsl:when test="$merged-map-doc/descendant::node[1]/@title != ''">
                    <xsl:value-of select="xr:escapeCharacters($merged-map-doc/descendant::node[1]/@title)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'Untitled'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="/descendant::*[@name = 'publication-title-variable']"/>
        <xsl:text>"</xsl:text>
            <xsl:value-of disable-output-escaping="yes" select="$title"/>
        <xsl:text>";
        </xsl:text>
    </xsl:template>

    <xsl:template name="insertSetOfIshconditions">
        <xsl:value-of select="/descendant::*[@name = 'set-of-ishconditions']"/>
        <xsl:text>[</xsl:text>
        <xsl:call-template name="getAllIshconditions"/>
        <xsl:text>];
        </xsl:text>
    </xsl:template>

    <xsl:template name="getAllIshconditions">
        <xsl:variable name="ishconditions">
            <xsl:for-each select="$merged-map-doc/descendant::*[not(normalize-space(@ishcondition) = '')]">
                <ishcondition><xsl:value-of select="normalize-space(@ishcondition)"/> </ishcondition>
            </xsl:for-each>
            <xsl:for-each select="$merged-map-doc/descendant::*[name() = 'ishcondition']">
                <ishcondition><xsl:value-of select="normalize-space(.)"/> </ishcondition>
            </xsl:for-each>
        </xsl:variable>
        <xsl:for-each select="$ishconditions/ishcondition">
            <xsl:variable name="current-value" select="normalize-space(.)"/>
            <xsl:if test="not(preceding-sibling::ishcondition/normalize-space(.) = $current-value)">
                <xsl:text>{</xsl:text>
                <xsl:text>"ishcondition" : "</xsl:text><xsl:value-of disable-output-escaping="yes" select="."/><xsl:text>"</xsl:text>
                <xsl:text>}</xsl:text>
                <xsl:if test="following-sibling::ishcondition[normalize-space(.) != $current-value]">
                    <xsl:text>,</xsl:text>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:function name="xr:escapeCharacters">
        <xsl:param name="string"/>

        <xsl:variable name="quot" select="'&quot;'"/>
        <xsl:variable name="escape-quot" select="'&amp;quot;'"/>
        <xsl:variable name="lt" select="'&lt;'"/>
        <xsl:variable name="escape-lt" select="'&amp;lt;'"/>
        <xsl:variable name="gt" select="'&gt;'"/>
        <xsl:variable name="escape-gt" select="'&amp;gt;'"/>
        <xsl:variable name="apos" select="'&amp;apos;'"/>
        <xsl:variable name="escape-apos" select="'\\&amp;apos;'"/>
        <xsl:variable name="bckslash" select="'\\'"/>
        <xsl:variable name="escape-bckslash" select="'\\\\'"/>

        <xsl:sequence select="replace(replace(replace(replace(replace($string, $quot, $escape-quot), $apos, $escape-apos), $bckslash, $escape-bckslash), $lt, $escape-lt), $gt, $escape-gt)"/>
    </xsl:function>

</xsl:stylesheet>
