<?xml version='1.0' encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ia="http://intelliarts.com"
                version="2.0"
                exclude-result-prefixes="ia">

    <xsl:import href="../dell-webhelp-functions.xsl"/>
    <xsl:output method="text"/>

    <xsl:param name="OUTEXT" select="'.html'"/>

    <xsl:variable name="base-name" select="tokenize(base-uri(),'/')[last()]"/>
    <xsl:variable name="base-dir" select="substring-before(base-uri(),$base-name)"/>

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
        <xsl:call-template name="insertContent"/>
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
        <xsl:text>&#09;"main": "index.html",&#10;</xsl:text>
    </xsl:template>

    <xsl:template name="insertResourceIDs">
        <xsl:variable name="resourceIDs">
            <xsl:for-each select="descendant::*[contains(@class, '- map/topicref ')][@href][not(ancestor::*[contains(@class, ' map/reltable ')])][not(contains(@class, ' bookmap/backmatter '))]">
                <xsl:variable name="href-filename" select="ia:getFileNameFromHref(@href)"/>
                <xsl:call-template name="getResourceIDs">
                    <xsl:with-param name="rootFile" select="$href-filename"/>
                    <xsl:with-param name="copy-to" select="@copy-to"/>
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
            <xsl:text>&#09;"</xsl:text>
            <xsl:if test="@appname != ''">
                <xsl:value-of select="@appname"/>
                <xsl:value-of select="':'"/>
            </xsl:if>
            <xsl:value-of select="@id"/>
            <xsl:text>": "</xsl:text>
            <xsl:value-of select="@rootFile"/>
            <xsl:text>",</xsl:text>
            <xsl:text>&#10;</xsl:text>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="getResourceIDs">
        <xsl:param name="rootFile"/>
        <xsl:param name="copy-to"/>

        <xsl:variable name="topic" select="resolve-uri($rootFile, $base-dir)"/>
        <xsl:variable name="topic-doc" select="document($topic)"/>
        <xsl:variable name="topic-id" select="$topic-doc/descendant::*[@id][1]/@id"/>

        <xsl:variable name="root-html">
            <xsl:choose>
                <xsl:when test="normalize-space($copy-to)">
                    <xsl:value-of select="$copy-to"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$topic-id"/>
                    <xsl:value-of select="$OUTEXT"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!--<xsl:variable name="root-html" select="concat(substring-before($rootFile, '.'), '.html')"/>-->

        <xsl:for-each select="$topic-doc/descendant::*[contains(@class, ' topic/resourceid ')]">
            <resourceid id="{@id}" appname="{@appname}" rootFile="{$root-html}" topic-id="{$topic-id}"/>
        </xsl:for-each>
        <xsl:for-each select="$topic-doc/descendant::*[contains(@class, ' topic/data ')][@name = 'context']">
            <resourceid id="{@value}" rootFile="{$root-html}" topic-id="{$topic-id}"/>
        </xsl:for-each>

        <xsl:if test="$topic-doc/descendant::*[contains(@class, '- map/topicref ')][@href][not(ancestor::*[contains(@class, ' map/reltable ')])]">
            <xsl:for-each select="$topic-doc/descendant::*[contains(@class, '- map/topicref ')][@href][not(ancestor::*[contains(@class, ' map/reltable ')])]">
                <xsl:variable name="href-filename" select="ia:getFileNameFromHref(@href)"/>
                <xsl:call-template name="getResourceIDs">
                    <xsl:with-param name="rootFile" select="$href-filename"/>
                    <xsl:with-param name="copy-to" select="@copy-to"/>
                </xsl:call-template>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>

    <xsl:template name="insertDummyPair">
        <xsl:text>
    // this is here so you don't have to worry about trailing commas
    "dummy": "/"</xsl:text>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>


    <xsl:function name="ia:getFileNameFromHref">
        <xsl:param name="href"/>

        <xsl:variable name="href-path" select="if(contains($href, '#'))
                                                        then(substring-before($href, '#'))
                                                        else($href)"/>
        <xsl:variable name="href-filename">
            <xsl:choose>
                <xsl:when test="$href-path = ''">
                    <xsl:choose>
                        <xsl:when test="contains($href, '/')">
                            <xsl:value-of select="concat(substring-after(substring-before($href, '/'), '#'), '.xml')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat(substring-after($href, '#'), '.xml')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="contains($href-path, '/')">
                    <xsl:value-of select="tokenize($href-path,'/')[last()]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$href-path"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:sequence select="$href-filename"/>
    </xsl:function>

</xsl:stylesheet>
