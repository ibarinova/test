<?xml version='1.0' encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ia="http://intelliarts.com"
                version="2.0"
                exclude-result-prefixes="ia">

    <xsl:import href="dita2html5-responsive-common-functions.xsl"/>
    <xsl:import href="dita2html5-responsive-common.xsl"/>

    <xsl:param name="outputDir"/>
    <xsl:param name="inputDir"/>
    <xsl:param name="properties-xml"/>
    <xsl:param name="out-extension" select="'.html'"/>

    <xsl:variable name="properties-xml-doc" select="doc(concat('file:/', translate($properties-xml, '\', '/')))"/>

    <xsl:variable name="input-dir-path" select="concat('file:/', translate($inputDir, '\', '/'), '/')"/>

    <xsl:variable name="language">
        <xsl:choose>
            <xsl:when test="/*/@xml:lang">
                <xsl:value-of select="/*/@xml:lang"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'EN-US'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:template match="/">
        <xsl:variable name="file-href" select="concat('file:/', translate($outputDir, '\', '/'), '/map.js')"/>
        <xsl:result-document omit-xml-declaration="yes" method="text"
                href="{$file-href}" >
            <xsl:call-template name="insertContent"/>
        </xsl:result-document>
    </xsl:template>

    <xsl:template name="insertContent">
        <xsl:call-template name="insertLocale"/>
        <xsl:call-template name="insertTopComment"/>
        <xsl:call-template name="insertLandingPagePair"/>
        <xsl:call-template name="insertResourceIDs"/>
        <xsl:call-template name="insertDummyPair"/>
        <xsl:text>};</xsl:text>
    </xsl:template>

    <xsl:template name="insertLocale">
        <xsl:text>if (EMCKickstart === undefined) {
                var EMCKickstart = {};
            }
        </xsl:text>
        <xsl:text>EMCKickstart.webhelpLocales = {"</xsl:text>
        <xsl:value-of select="$language"/>
        <xsl:text>": true};</xsl:text>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>

    <xsl:template name="insertTopComment">
        <xsl:text>/**
 To add a topic, just add a line like:
 "key" : "url",
 That's the key in quotes, a colon, the url in quotes, followed by a comma.
 You can add comments by prefixing the line with double slash (//).
 **/</xsl:text>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>

    <xsl:template name="insertLandingPagePair">
        <xsl:text>EMCKickstart.webhelpMap = {</xsl:text>
        <xsl:text>&#10;</xsl:text>
        <xsl:text>&#09;// Main Help File</xsl:text>
        <xsl:text>&#10;</xsl:text>
        <xsl:text>&#09;"main": "</xsl:text>
        <xsl:value-of select="ia:getLandingPageName($properties-xml, base-uri())"/>
        <xsl:text>",&#10;</xsl:text>
    </xsl:template>

    <xsl:template name="insertResourceIDs">
        <xsl:variable name="resourceIDs">
            <xsl:for-each select="descendant::*[contains(@class, '- map/topicref ')][@href][not(ancestor::*[contains(@class, ' map/reltable ')])]">
                <xsl:call-template name="getResourceIDs">
                    <xsl:with-param name="rootFile" select="ancestor::*[@copy-to][1]/@copy-to"/>
                </xsl:call-template>
            </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="resourceIDs-sorted">
            <xsl:for-each select="$resourceIDs/resourceid">
                <xsl:sort select="@id"/>
                <xsl:variable name="id" select="@id"/>
                <xsl:if test="not(preceding-sibling::*/@id = $id)">
                    <xsl:copy-of select="."/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>

        <xsl:for-each select="$resourceIDs-sorted/resourceid">
            <xsl:variable name="topic-id" select="@topic-id"/>
            <xsl:variable name="topic-hash" select="$properties-xml-doc/descendant::*[@topicGUID = $topic-id][1]/@hash"/>
            <xsl:text>&#09;"</xsl:text>
            <xsl:value-of select="@id"/>
            <xsl:text>": "</xsl:text>
            <xsl:value-of select="@rootFile"/>
            <xsl:if test="normalize-space($topic-hash)">
                <xsl:value-of select="concat('#', $topic-hash)"/>
            </xsl:if>
            <xsl:text>",</xsl:text>
            <xsl:text>&#10;</xsl:text>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="getResourceIDs">
        <xsl:param name="rootFile"/>

        <xsl:variable name="topic" select="concat($input-dir-path, @href)"/>
        <xsl:variable name="topic-doc" select="document($topic)"/>
        <xsl:variable name="topic-id" select="$topic-doc/descendant::*[@id][1]/@id"/>

        <xsl:for-each select="$topic-doc/descendant::*[contains(@class, ' topic/resourceid ')]">
            <resourceid id="{@id}" rootFile="{$rootFile}" topic-id="{$topic-id}"/>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="insertDummyPair">
        <xsl:text>
    // this is here so you don't have to worry about trailing commas
    "dummy": "/"</xsl:text>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>
</xsl:stylesheet>
