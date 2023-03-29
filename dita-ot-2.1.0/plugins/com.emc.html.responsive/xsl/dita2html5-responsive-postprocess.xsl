<?xml version='1.0' encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:ia="http://intelliarts.com"
                xmlns:ditaarch="http://dita.oasis-open.org/architecture/2005/"
                xmlns:Xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="xs ia"
                version="2.0">

    <xsl:output indent="yes" encoding="UTF-8"/>

    <xsl:param name="propertiesXml"/>

    <xsl:variable name="properties-doc" select="document(concat('file:/', translate($propertiesXml, '\', '/')))"/>

    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="dita[not(@xml:lang)]">
        <xsl:copy>
            <xsl:variable name="xmlLang" select="descendant::*[@xml:lang][1]/@xml:lang"/>
            <xsl:attribute name="xml:lang" select="$xmlLang"/>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' map/topicref ') and not(ancestor::*[contains(@class, ' map/reltable ')])]/@href">
        <xsl:attribute name="href">
            <xsl:value-of select="ia:convertHref(.)"/>
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/link ')]/@href">
        <xsl:attribute name="href">
            <xsl:value-of select="ia:convertHref(.)"/>
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/xref ')]/@href">
        <xsl:attribute name="href">
            <xsl:value-of select="ia:convertHref(.)"/>
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/topic ')]/@id">
        <xsl:variable name="id" select="."/>
        <xsl:variable name="hash" select="$properties-doc/descendant::*[@topicGUID = $id][1]/@hash"/>
        <xsl:attribute name="id">
            <xsl:choose>
                <xsl:when test="string-length($hash) &gt; 0">
                    <xsl:value-of select="$hash"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$id"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>

    <xsl:function name="ia:convertHref">
        <xsl:param name="href"/>

        <xsl:variable name="filename" select="substring-before($href, '#')"/>

        <xsl:variable name="rootElementId">
            <xsl:choose>
                <xsl:when test="contains($href, '/')">
                    <xsl:value-of select="substring-before(substring-after($href, '#'), '/')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="substring-after($href, '#')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="rootElementHash">
            <xsl:choose>
                <xsl:when test="$properties-doc/descendant::*[@topicGUID = $rootElementId]">
                    <xsl:value-of select="concat('#', $properties-doc/descendant::*[@topicGUID = $rootElementId][1]/@hash)"/>
                </xsl:when>
                <xsl:when test="string-length($rootElementId) &gt; 0">
                    <xsl:value-of select="concat('#', $rootElementId)"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="descendantElementId" select="substring-after($href, '/')"/>

        <xsl:variable name="descendantElementHash">
            <xsl:choose>
                <xsl:when test="$properties-doc/descendant::*[@topicGUID = $descendantElementId]">
                    <xsl:value-of select="concat('/', $properties-doc/descendant::*[@topicGUID = $descendantElementId][1]/@hash)"/>
                </xsl:when>
                <xsl:when test="string-length($descendantElementId) &gt; 0">
                    <xsl:value-of select="concat('/', $descendantElementId)"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="correctHref">
            <xsl:choose>
                <xsl:when test="starts-with($href, 'http')">
                    <xsl:value-of select="$href"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat($filename, $rootElementHash, $descendantElementHash)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:sequence select="$correctHref"/>
    </xsl:function>
</xsl:stylesheet>
