<?xml version='1.0' encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">

    <xsl:param name="outputDir"/>
    <xsl:param name="timeStamp"/>

    <xsl:variable name="pub" select="/descendant::pub[1]"/>
    <xsl:variable name="pubGUID" select="$pub/@pubGuid"/>
    <xsl:variable name="pubFtitle" select="$pub/@pubFTITLE"/>
    <xsl:variable name="pubLanguage" select="$pub/@pubLanguage"/>
    <xsl:variable name="pubVersion" select="$pub/@pubVersion"/>
    <xsl:variable name="pubAccessLevel" select="$pub/@pubAccessLevel"/>
    <xsl:variable name="pubType" select="$pub/@pubType"/>

    <xsl:template match="/">
        <xsl:variable name="file-name" select="concat($pubGUID, '=', $pubVersion, '=', $pubLanguage, '-', $timeStamp, '.tab')"/>
        <xsl:variable name="file-href" select="concat('file:/', translate($outputDir, '\', '/'), '/', $file-name)"/>
        <xsl:result-document omit-xml-declaration="yes" method="text"
                href="{$file-href}" >
            <xsl:call-template name="insertHeader"/>
            <xsl:apply-templates select="/descendant::file"/>
        </xsl:result-document>
    </xsl:template>

    <xsl:template match="file">
        <xsl:value-of select="@hash"/>
        <xsl:text>&#x9;</xsl:text>
        <xsl:value-of select="@topicGUID"/>
        <xsl:text>&#x9;</xsl:text>
        <xsl:value-of select="@topicFTITLE"/>
        <xsl:text>&#x9;</xsl:text>
        <xsl:value-of select="@topicLanguage"/>
        <xsl:text>&#x9;</xsl:text>
        <xsl:value-of select="@topicVersion"/>
        <xsl:text>&#x9;</xsl:text>
        <xsl:value-of select="@topicCreateDate"/>
        <xsl:text>&#x9;</xsl:text>
        <xsl:value-of select="@topicModifiedDate"/>
        <xsl:text>&#x9;</xsl:text>
        <xsl:value-of select="@topicAuthor"/>
        <xsl:text>&#x9;</xsl:text>
        <xsl:value-of select="@topicAccessLevel"/>
        <xsl:text>&#x9;</xsl:text>
        <xsl:value-of select="@topicContentType"/>
        <xsl:text>&#x9;</xsl:text>
        <xsl:value-of select="$pubGUID"/>
        <xsl:text>&#x9;</xsl:text>
        <xsl:value-of select="$pubFtitle"/>
        <xsl:text>&#x9;</xsl:text>
        <xsl:value-of select="$pubLanguage"/>
        <xsl:text>&#x9;</xsl:text>
        <xsl:value-of select="$pubVersion"/>
        <xsl:text>&#x9;</xsl:text>
        <xsl:value-of select="$pubAccessLevel"/>
        <xsl:text>&#x9;</xsl:text>
        <xsl:value-of select="$pubType"/>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>

    <xsl:template name="insertHeader">
        <xsl:text>## SC	SiteCatalyst SAINT Import File	v:2.1</xsl:text>
        <xsl:text>&#10;</xsl:text>
        <xsl:text>## SC	'## SC' indicates a SiteCatalyst pre-process header. Please do not remove these lines.</xsl:text>
        <xsl:text>&#10;</xsl:text>
        <xsl:text>## SC	D:2015-11-24 10:15:37	A:134844:1046</xsl:text>
        <xsl:text>&#10;</xsl:text>
        <xsl:text>Key</xsl:text>
        <xsl:text>&#9;</xsl:text>
        <xsl:text>topicGUID</xsl:text>
        <xsl:text>&#9;</xsl:text>
        <xsl:text>topicFtitle</xsl:text>
        <xsl:text>&#9;</xsl:text>
        <xsl:text>topicLanguage</xsl:text>
        <xsl:text>&#9;</xsl:text>
        <xsl:text>topicVersion</xsl:text>
        <xsl:text>&#9;</xsl:text>
        <xsl:text>topicCreateDate</xsl:text>
        <xsl:text>&#9;</xsl:text>
        <xsl:text>topicModifiedDate</xsl:text>
        <xsl:text>&#9;</xsl:text>
        <xsl:text>topicAuthor</xsl:text>
        <xsl:text>&#9;</xsl:text>
        <xsl:text>topicAccessLevel</xsl:text>
        <xsl:text>&#9;</xsl:text>
        <xsl:text>topicContentType</xsl:text>
        <xsl:text>&#9;</xsl:text>
        <xsl:text>pubGUID</xsl:text>
        <xsl:text>&#9;</xsl:text>
        <xsl:text>pubFtitle</xsl:text>
        <xsl:text>&#9;</xsl:text>
        <xsl:text>pubLanguage</xsl:text>
        <xsl:text>&#9;</xsl:text>
        <xsl:text>pubVersion</xsl:text>
        <xsl:text>&#9;</xsl:text>
        <xsl:text>pubAccessLevel</xsl:text>
        <xsl:text>&#9;</xsl:text>
        <xsl:text>pubType</xsl:text>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>
</xsl:stylesheet>
