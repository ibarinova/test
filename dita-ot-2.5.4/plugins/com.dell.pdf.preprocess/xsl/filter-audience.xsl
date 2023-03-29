<?xml version="1.0" encoding="UTF-8" ?>

<xsl:stylesheet version="2.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:param name="combine-languages" select="'no'"/>

    <xsl:variable name="isMultilingual" select="if(lower-case($combine-languages) = 'yes') then(true()) else(false())" as="xs:boolean"/>

    <xsl:template match="@* | node()" priority="-1">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="*[not($isMultilingual)][contains(@class, ' topic/topic ')][@id]">
        <xsl:variable name="topicref" select="/descendant::*[contains(@class, ' map/topicref ')][@id = current()/@id][1]"/>

        <xsl:choose>
            <xsl:when test="$topicref[@audience]">
                <xsl:variable name="topicrefLang" select="if($topicref/ancestor-or-self::*[@xml:lang]) then($topicref/ancestor-or-self::*[@xml:lang][1]/@xml:lang) else('en-us')"/>
                <xsl:variable name="processElement">
                    <xsl:for-each select="tokenize(replace(normalize-space(replace(replace($topicref/@audience, '\sand\s', ','), '_', ',')), '\s', ','), ',')">
                        <xsl:if test="normalize-space(.) = $topicrefLang">true</xsl:if>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:if test="$processElement = 'true'">
                    <xsl:next-match/>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[not($isMultilingual)][@audience]" priority="1">
        <xsl:variable name="lang" select="if(ancestor-or-self::*[@xml:lang]) then(ancestor-or-self::*[@xml:lang][1]/@xml:lang) else('en-us')"/>
        <xsl:variable name="processElement">
            <xsl:for-each select="tokenize(replace(normalize-space(replace(replace(@audience, '\sand\s', ','), '_', ',')), '\s', ','), ',')">
                <xsl:if test="normalize-space(.) = $lang">true</xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:if test="$processElement = 'true'">
            <xsl:next-match/>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
