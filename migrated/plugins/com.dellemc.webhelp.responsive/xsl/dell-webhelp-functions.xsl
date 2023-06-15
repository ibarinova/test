<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:ia="http://intelliarts.com"
                version="2.0"
                exclude-result-prefixes="xs ia">

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

    <xsl:function name="ia:prepareFileName">
        <xsl:param name="fileName"/>

        <xsl:variable name="correctFileName"
                      select="replace(lower-case($fileName), '\W|-|\^|\$|\||&lt;|&gt;|`|~|\+|=', '_')"/>

        <xsl:sequence select="$correctFileName"/>
    </xsl:function>

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
                    <xsl:choose>
                        <xsl:when test="contains($href-path, '.html')">
                            <xsl:value-of select="concat(substring-before(tokenize($href-path,'/')[last()], '.html'), '.xml')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="tokenize($href-path,'/')[last()]"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="contains($href-path, '.html')">
                    <xsl:value-of select="concat(substring-before($href-path, '.html'), '.xml')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$href-path"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:sequence select="$href-filename"/>
    </xsl:function>

</xsl:stylesheet>
