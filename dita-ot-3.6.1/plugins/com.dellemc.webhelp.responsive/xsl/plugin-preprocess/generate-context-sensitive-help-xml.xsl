<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:relpath="http://dita2indesign/functions/relpath"
                xmlns:ia="http://intelliarts.com"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="#all"
                version="2.0">

    <!--<xsl:import href="plugin:com.oxygenxml.webhelp.responsive:xsl/util/dita-utilities.xsl"/>-->
    <xsl:import href="../dell-webhelp-functions.xsl"/>
    <xsl:output method="xml" indent="yes" exclude-result-prefixes="#all"/>

    <!-- Extension of output files for example .html -->
    <xsl:param name="OUT_EXT" select="'.html'"/>

    <xsl:variable name="base-name" select="tokenize(base-uri(),'/')[last()]"/>
    <xsl:variable name="base-dir" select="substring-before(base-uri(),$base-name)"/>

    <xsl:template match="/">
        <map version="1.0" xmlns="urn:WebWorks-Help-Book-Files-Schema">
            <xsl:apply-templates mode="toc-webhelp"/>
        </map>
    </xsl:template>


    <xsl:template match="text()" mode="toc-webhelp"/>

    <xsl:template match="@xmlns"/>

    <xsl:template match="*[contains(@class, ' bookmap/booklists ')]" mode="toc-webhelp"/>
    <xsl:template match="*[contains(@class, ' map/topicref ') and contains(@class, ' bookmap/backmatter ')]" mode="toc-webhelp"/>

    <xsl:template
            match="*[contains(@class, ' bookmap/frontmatter ')
                      or (contains(@class, ' bookmap/part ')
                          and not(@href))]"
            mode="toc-webhelp" priority="1">
        <xsl:apply-templates mode="toc-webhelp"/>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' map/topicref ')
                          and not(contains(@class, ' bookmap/booklists '))
                          and not(@processing-role='resource-only')
                          and not(ancestor::*[contains(@class, ' map/reltable ')])]"
            mode="toc-webhelp">

        <xsl:variable name="tnert" select="resolve-uri(@href, $base-dir)"/>
        <xsl:variable name="copy-to" select="@copy-to"/>
        <xsl:if test="document($tnert)/*/prolog/resourceid/@id">
            <!-- EMC	IB8		01-Oct-2015		TKT-266: map.xml should handle multiple resourceid STARTS -->
            <xsl:variable name="href"><xsl:value-of select="@href"/></xsl:variable>
            <xsl:for-each select="document($tnert)/*/prolog/resourceid">
                <xsl:variable name="target" select="@id"/>
                <xsl:variable name="appname" select="@appname"/>
                <mapID>
                    <xsl:attribute name="target" select="if($appname != '') then(concat($appname, ':', $target)) else($target)"/>
                    <xsl:choose>
                        <xsl:when test="$copy-to">
                            <xsl:attribute name="href">
                                <xsl:call-template name="replace-extension">
                                    <xsl:with-param name="filename" select="$copy-to"/>
                                    <xsl:with-param name="extension" select="$OUT_EXT"/>
                                </xsl:call-template>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:when test="$href">
                            <xsl:attribute name="href">
                                <xsl:call-template name="replace-extension">
                                    <xsl:with-param name="filename" select="$href"/>
                                    <xsl:with-param name="extension" select="$OUT_EXT"/>
                                </xsl:call-template>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="href" select="'javascript:void(0)'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:if test="@collection-type">
                        <xsl:attribute name="collection-type" select="@collection-type"/>
                    </xsl:if>
                </mapID>
            </xsl:for-each>
            <!-- EMC	IB8		01-Oct-2015		TKT-266: map.xml should handle multiple resourceid ENDS -->
        </xsl:if>
        <xsl:apply-templates mode="toc-webhelp"/>
        <xsl:if test="doc-available($tnert) and document($tnert)/descendant::*[contains(@class, ' map/topicref ')]">
            <xsl:apply-templates select="document($tnert)/descendant::*[contains(@class, ' map/topicref ')]"
                                 mode="toc-webhelp"/>
        </xsl:if>
    </xsl:template>

    <xsl:template name="replace-extension">
        <xsl:param name="filename"/>
        <xsl:param name="extension"/>
        <xsl:param name="ignore-fragment" select="false()"/>
        <xsl:param name="forceReplace" select="false()"/>
        <xsl:variable name="file-path">
            <xsl:choose>
                <xsl:when test="contains($filename, '#')">
                    <xsl:value-of select="substring-before($filename, '#')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$filename"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="f">
            <xsl:call-template name="substring-before-last">
                <xsl:with-param name="text" select="$file-path"/>
                <xsl:with-param name="delim" select="'.'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="original-extension">
            <xsl:call-template name="substring-after-last">
                <xsl:with-param name="text" select="$file-path"/>
                <xsl:with-param name="delim" select="'.'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:if test="string($f)">
            <xsl:choose>
                <xsl:when test="$forceReplace or $original-extension = 'xml' or $original-extension = 'dita'">
                    <xsl:value-of select="concat($f, $extension)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat($f, '.', $original-extension)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        <xsl:if test="not($ignore-fragment) and contains($filename, '#')">
            <xsl:value-of select="concat('#', substring-after($filename, '#'))"/>
        </xsl:if>
    </xsl:template>

    <xsl:template name="substring-before-last" as="xs:string?">
        <xsl:param name="text" as="xs:string"/>
        <xsl:param name="delim" as="xs:string"/>
        <xsl:param name="acc" as="xs:string?"/>

        <xsl:choose>
            <xsl:when test="string($text) and string($delim)">
                <xsl:variable name="tail" select="substring-after($text, $delim)" />
                <xsl:choose>
                    <xsl:when test="contains($tail, $delim)">
                        <xsl:call-template name="substring-before-last">
                            <xsl:with-param name="text" select="$tail" />
                            <xsl:with-param name="delim" select="$delim" />
                            <xsl:with-param name="acc" select="concat($acc, substring-before($text, $delim), $delim)"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat($acc, substring-before($text, $delim))"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$acc"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="substring-after-last">
        <xsl:param name="text"/>
        <xsl:param name="delim"/>

        <xsl:if test="string($text) and string($delim)">
            <xsl:variable name="tail" select="substring-after($text, $delim)" />
            <xsl:choose>
                <xsl:when test="string-length($tail) > 0">
                    <xsl:call-template name="substring-after-last">
                        <xsl:with-param name="text" select="$tail" />
                        <xsl:with-param name="delim" select="$delim" />
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$text"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
