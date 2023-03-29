<?xml version='1.0' encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:ia="http://intelliarts.com"
                exclude-result-prefixes="xs ia"
                version="2.0">

    <xsl:param name="temp-dir"/>
    <xsl:param name="input-dir"/>

    <xsl:template match="/">
        <xsl:for-each select="/descendant::file[@type = 'chapter' and @href]">
            <xsl:call-template name="process-chapters"/>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="process-chapters">
        <xsl:variable name="original-file-href" select="concat('file:/', translate($input-dir, '\', '/'), '/', @href)"/>
        <xsl:variable name="file-href" select="concat('file:/', translate($temp-dir, '\', '/'), '/', @href)"/>

        <xsl:variable name="original-doc" select="document($original-file-href)"/>

        <xsl:if test="$original-doc/child::*[1][name() = 'topic'][contains(@class, ' topic/topic ')]">
            <xsl:result-document href="{$file-href}" indent="yes" encoding="UTF-8">
                <xsl:variable name="topic-doctype" select="ia:gen-topic-doctype(unparsed-text($original-file-href))"/>
                <xsl:value-of select="$topic-doctype" disable-output-escaping="yes"/>


                <xsl:apply-templates select="$original-doc" mode="process-chapter"/>
            </xsl:result-document>
        </xsl:if>
    </xsl:template>

    <xsl:function name="ia:gen-topic-doctype" as="xs:string">
        <xsl:param name="unparsed-topic-text" as="xs:string"/>

        <xsl:variable name="doctype" select="replace(
                                                $unparsed-topic-text,
                                                '.*?&lt;!DOCTYPE([^>\[]*(\[[^\]]*\])?)?>.*',
                                                '&#xA;&lt;!DOCTYPE$1&gt;',
                                                's'
                                                )"/>
        <xsl:sequence select="translate($doctype, '&#x9;&#xD;&#xA;', ' ')"/>
    </xsl:function>

    <xsl:template match="*[contains(@class, ' topic/titlealts ')]" mode="process-chapter"/>
    <xsl:template match="*[contains(@class, ' topic/abstract ')]" mode="process-chapter"/>
    <xsl:template match="*[contains(@class, ' topic/body ')]" mode="process-chapter"/>
    <xsl:template match="*[contains(@class, ' topic/related-links ')]" mode="process-chapter"/>
    <xsl:template match="*[contains(@class, ' topic/no-topic-nesting ')]" mode="process-chapter"/>
    <xsl:template match="*[contains(@class, ' topic/topic ')][ancestor::*[contains(@class, ' topic/topic ')]]" mode="process-chapter"/>

    <xsl:template match="@*|node()" mode="process-chapter">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="process-chapter"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
