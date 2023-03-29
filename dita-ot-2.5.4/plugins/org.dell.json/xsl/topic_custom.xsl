<?xml version="1.0" encoding="UTF-8"?>
<!--
This file is part of the DITA Open Toolkit project.
See the accompanying LICENSE file for applicable license.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
                xmlns:dita2html="http://dita-ot.sourceforge.net/ns/200801/dita2html"
                xmlns:ditamsg="http://dita-ot.sourceforge.net/ns/200704/ditamsg"
                version="2.0">

    <xsl:import href="front_matter.xsl"/>
    <xsl:import href="recommendation.xsl"/>
    <xsl:import href="list.xsl"/>
    <xsl:import href="table_custom.xsl"/>

    <xsl:strip-space elements="*"/>

<!--get the topic title for folder and topic title-->
    <xsl:template match="/">
	    <xsl:variable name="folder">
            <xsl:value-of select="*[contains(@class, ' topic/topic ')]/*[contains(@class, ' topic/title ')]"/>
    </xsl:variable>

        <xsl:result-document href="{$folder}.json">
            <xsl:choose>
                <xsl:when test="*[contains(@class, 'topic/topic')][contains(@outputclass, 'array')]">
                    <xsl:apply-templates/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>{</xsl:text>
                    <xsl:apply-templates/>
                    <xsl:text>}</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:result-document>
    </xsl:template>
<!--Processing image for vairous instances-->
    <xsl:template match="*[contains(@class, ' topic/image ')]">
        <xsl:choose>
            <xsl:when test="parent::*[contains(@class, ' topic/entry ')] and ancestor::*[contains(@class, ' topic/topic ')][contains(@outputclass, 'recinner')]">
                <xsl:text>"/</xsl:text><xsl:value-of select="concat(substring-before(@href, '=GUID'),'.', substring-after(lower-case(@href), '.'))"/>"
            </xsl:when>
            <xsl:when test="parent::*[contains(@class, ' topic/dd ')]">
                <xsl:text>/</xsl:text><xsl:value-of select="concat(substring-before(@href, '=GUID'),'.', substring-after(lower-case(@href), '.'))"/>
            </xsl:when>
            <xsl:when test="ancestor::*[not(contains(@class, ' topic/table '))] and (ancestor::*[contains(@class, ' topic/topic ')][contains(@outputclass, 'recinner')])">
                <xsl:text>"/</xsl:text><xsl:value-of select="concat(substring-before(@href, '=GUID'),'.', substring-after(lower-case(@href), '.'))"/>"
            </xsl:when>

            <xsl:otherwise>
                <xsl:text>"/</xsl:text><xsl:value-of select="normalize-space(.)"/><xsl:text>"</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
<!--Remove default related links content-->
<xsl:template match="*[contains(@class, ' topic/related-links ')]"/>
<!--process xref for json and other content-->
<xsl:template  name="xref" match="*[contains(@class, ' topic/xref ')]">
    <xsl:choose>
	<xsl:when test="contains(@format,'nondita')">
	<xsl:text>/</xsl:text><xsl:value-of select="normalize-space(.)"/>
	</xsl:when>
	<xsl:otherwise>
	<xsl:value-of select="."/>
	</xsl:otherwise>
	</xsl:choose>
</xsl:template>
<xsl:template match="text()"/>
</xsl:stylesheet>