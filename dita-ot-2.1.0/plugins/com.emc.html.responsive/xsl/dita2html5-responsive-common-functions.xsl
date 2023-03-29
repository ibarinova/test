<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:ia="http://intelliarts.com"
                version="2.0"
                exclude-result-prefixes="xs ia">

    <xsl:function name="ia:getNameFromMetaFile">
        <xsl:param name="base-uri"/>
        <xsl:param name="xmlFileName"/>

        <xsl:variable name="base-name" select="tokenize($base-uri,'/')[last()]"/>
        <xsl:variable name="base-dir" select="substring-before($base-uri,$base-name)"/>

        <xsl:variable name="meta-file-name" select="ia:getMetaFileName($xmlFileName)"/>
        <xsl:variable name="meta-file-doc" select="document(concat($base-dir, $meta-file-name))"/>
        <xsl:variable name="file-name" select="$meta-file-doc/descendant::*[@name = 'FTITLE'][1]"/>

        <xsl:variable name="correct-filename" select="ia:prepareFileName($file-name)"/>

        <xsl:sequence select="$correct-filename"/>
    </xsl:function>

    <xsl:function name="ia:getMetaFileName">
        <xsl:param name="xmlFileName"/>

        <xsl:variable name="correctFileName">
            <xsl:choose>
                <xsl:when test="contains($xmlFileName, '#')">
                    <xsl:value-of select="substring-before($xmlFileName, '#')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$xmlFileName"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="meta-file-name" select="concat(substring-before($correctFileName, '.'), '.met')"/>

        <xsl:sequence select="$meta-file-name"/>
    </xsl:function>

    <xsl:function name="ia:prepareFileName">
        <xsl:param name="fileName"/>

        <xsl:variable name="correctFileName"
                      select="ia:addHTMExtension(replace(lower-case($fileName), '\W|_|\^|\$|\||&lt;|&gt;|`|~|\+|=', '-'))"/>

        <xsl:sequence select="$correctFileName"/>
    </xsl:function>

    <xsl:function name="ia:addHTMExtension">
        <xsl:param name="fileName"/>

        <xsl:variable name="readyFileName">
            <xsl:choose>
                <xsl:when test="matches($fileName, '[\w+-]+\.[\w+]?')">
                    <xsl:value-of select="substring-before($fileName, '.')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$fileName"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:sequence select="concat($readyFileName, $out-extension)"/>
    </xsl:function>

    <xsl:function name="ia:getLandingPageName">
        <xsl:param name="properties-xml"/>
        <xsl:param name="base-uri"/>

        <xsl:variable name="properties-xml-uri" select="concat('file:///', translate($properties-xml, '\', '/'))"/>
        <xsl:variable name="properties-xml-doc" select="doc($properties-xml-uri)"/>
        <xsl:variable name="pubFtitle" select="if(doc-available($properties-xml-uri)) then($properties-xml-doc/descendant::pub[1]/@pubFTITLE) else('')"/>

        <xsl:variable name="base-name" select="tokenize($base-uri,'/')[last()]"/>

        <xsl:variable name="correct-filename">
            <xsl:choose>
                <xsl:when test="string-length(normalize-space(ia:prepareFileName($pubFtitle))) &gt; 1">
                    <xsl:value-of select="ia:prepareFileName($pubFtitle)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="ia:getNameFromMetaFile($base-uri, $base-name)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:sequence select="concat('00-', $correct-filename)"/>
    </xsl:function>

</xsl:stylesheet>
