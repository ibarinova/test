<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:ia="http://intelliarts.com"
                version="2.0"
                exclude-result-prefixes="xs ia">

    <xsl:output indent="yes"/>

    <xsl:param name="INPUT-DIR"/>
    <xsl:variable name="INPUT-DIR-path" select="concat('file:///', translate($INPUT-DIR, '\', '/'), '/')"/>
    <xsl:variable name="doctype" select="ia:gen-doctype(unparsed-text(document-uri(.)))"/>

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/">
        <xsl:value-of select="$doctype" disable-output-escaping="yes"/>
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' bookmap/bookmap ')]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="chunk" select="'to-content'"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="*/@chunk" priority="10"/>

    <xsl:template match="*/@ishlabelxpath" priority="10"/>
    <xsl:template match="*/@ishlinkxpath" priority="10"/>
    <xsl:template match="*/@ishtype" priority="10"/>
    <xsl:template match="*/@domains" priority="10"/>
    <xsl:template match="*/@class" priority="10"/>

    <xsl:template match="*[contains(@class, ' bookmap/backmatter ')]" priority="10"/>
    <xsl:template match="*[contains(@class, ' bookmap/preface ')]" priority="10"/>

    <xsl:template match="*[contains(@class, ' map/topicref ')]
                        [contains(@class, ' bookmap/chapter ') or contains(@class, ' bookmap/appendix ')]
                        [not(@toc='no')][not(@processing-role='resource-only')][@href]/@href">
        <xsl:variable name="file-path" select="concat($INPUT-DIR-path, normalize-space(.))"/>
         <xsl:choose>
            <xsl:when test="doc-available($file-path) and (doc($file-path)/*/@class = '- topic/topic ')"/>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@* | node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:function name="ia:gen-doctype" as="xs:string">
        <xsl:param name="unparsed-topic-text" as="xs:string"/>

        <xsl:variable name="doctype" select="replace(
                                                $unparsed-topic-text,
                                                '.*?&lt;!DOCTYPE([^>\[]*(\[[^\]]*\])?)?>.*',
                                                '&#xA;&lt;!DOCTYPE$1&gt;',
                                                's'
                                                )"/>
        <xsl:sequence select="translate($doctype, '&#x9;&#xD;&#xA;', ' ')"/>
    </xsl:function>

</xsl:stylesheet>