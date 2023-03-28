<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ia="http://intelliarts.com"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="ia xs"
                version="2.0">
    <xsl:import href="../dell-webhelp-functions.xsl"/>

    <xsl:param name="properties-xml"/>
    <xsl:param name="dell-brand" select="'EMC'"/>

    <xsl:output indent="yes"/>

    <xsl:variable name="doctype" select="ia:gen-doctype(unparsed-text(document-uri(.)))"/>

    <xsl:variable name="properties-xml-uri" select="concat('file:/', translate($properties-xml, '\', '/'))"/>
    <xsl:variable name="properties-xml-doc" select="document($properties-xml-uri)"/>

    <xsl:variable name="base-name" select="tokenize(base-uri(),'/')[last()]"/>
    <xsl:variable name="base-dir" select="substring-before(base-uri(),$base-name)"/>

    <xsl:variable name="show-page-notes" as="xs:boolean"
                  select="if(lower-case(/descendant::*[contains(@class, ' topic/othermeta ')][lower-case(@name) = 'hide-admonitions'][1]/@content) = 'yes')
						then(false()) else(true())"/>

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="@*|node()" mode="inside-reltable">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="inside-reltable"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/">
        <xsl:value-of select="$doctype" disable-output-escaping="yes"/>
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' bookmap/bookmap ')]">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>

            <xsl:apply-templates select="/descendant::*[contains(@class, ' map/reltable ')]" mode="reltable"/>
            <xsl:for-each select="/descendant::*[contains(@class, ' map/topicref ')][@href]
                                        [not(ancestor::*[contains(@class, ' map/reltable ')])]">
                <xsl:apply-templates select="." mode="reltable"/>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' map/reltable ')]" mode="reltable">
        <xsl:copy>
            <xsl:apply-templates mode="inside-reltable"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' map/topicref ')][@href]" mode="inside-reltable">
        <xsl:variable name="href-filename" select="ia:getFileNameFromHref(@href)"/>

		<!-- copyright topic reference is excluded -->
        <xsl:variable name="new-name" select="$properties-xml-doc/descendant::*[matches(@name, $href-filename)][1]/@new-name"/>
        <xsl:variable name="exclude" select="$properties-xml-doc/descendant::*[matches(@name, $href-filename)][1]/@exclude"/>
        <xsl:variable name="bridge-topic" select="$properties-xml-doc/descendant::*[matches(@name, $href-filename)][1]/@bridge-topic"/>
		<!-- copyright topic reference is excluded -->

        <xsl:variable name="ref-doc-uri" select="if(@href != '') then(resolve-uri($href-filename, $base-dir)) else('')"/>
        <xsl:variable name="ref-doc" select="if(doc-available($ref-doc-uri)) then(document($ref-doc-uri))  else('')"/>
        <xsl:variable name="ref-doc-title" select="if(doc-available($ref-doc-uri))
                                                then($ref-doc/descendant::*[contains(@class, ' topic/title ')][1])
                                                else('')"/>

        <xsl:variable name="navtitle" select="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/navtitle ')]"/>

		<!--<xsl:message> File name excluded is : <xsl:value-of select="$new-name"/></xsl:message>-->
        <xsl:variable name="title">
            <xsl:choose>
                <xsl:when test="$ref-doc-title != ''">
                    <xsl:value-of select="$ref-doc-title"/>
                </xsl:when>
                <xsl:when test="$navtitle != ''">
                    <xsl:value-of select="$navtitle"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@navtitle"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
		<!--<xsl:message> Exclude filename flag is : <xsl:value-of select="$exclude"/></xsl:message>-->
        <xsl:if test="($exclude = 'false') and ($bridge-topic = 'false')">
            <xsl:copy>
                <xsl:apply-templates select="@*[not(name() = 'copy-to')]" mode="inside-reltable"/>
                <xsl:choose>
                    <xsl:when test="normalize-space(@copy-to)">
                        <xsl:choose>
                            <xsl:when test="ends-with(@copy-to, '.xml')">
                                <xsl:attribute name="copy-to" select="concat(substring-before(@copy-to, '.xml'), '.html')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="copy-to" select="@copy-to"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="normalize-space($new-name)">
                        <xsl:attribute name="copy-to" select="$new-name"/>
                    </xsl:when>
                </xsl:choose>
                <topicmeta>
                    <navtitle>
                        <xsl:value-of select="$title"/>
                    </navtitle>
                </topicmeta>
                <xsl:apply-templates select="node()" mode="inside-reltable"/>
            </xsl:copy>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' map/topicref ')]" mode="reltable">
        <xsl:variable name="href-filename" select="ia:getFileNameFromHref(@href)"/>
        <xsl:variable name="ref-doc-uri" select="if(@href != '') then(resolve-uri($href-filename, $base-dir)) else('')"/>
        <xsl:variable name="ref-doc" select="if(doc-available($ref-doc-uri)) then(document($ref-doc-uri))  else('')"/>

        <xsl:if test="doc-available($ref-doc-uri) and $ref-doc/descendant::*[contains(@class, ' map/map ')]/descendant::*[contains(@class, ' map/reltable ')]">
            <xsl:apply-templates select="$ref-doc/descendant::*[contains(@class, ' map/map ')]/descendant::*[contains(@class, ' map/reltable ')]" mode="reltable"/>
        </xsl:if>
        <xsl:if test="doc-available($ref-doc-uri) and $ref-doc/descendant::*[contains(@class, ' map/map ')]/descendant::*[contains(@class, ' map/topicref ')][@href][not(ancestor::*[contains(@class, ' map/reltable ')])]">
            <xsl:for-each select="$ref-doc/descendant::*[contains(@class, ' map/map ')]/
                                            descendant::*[contains(@class, ' map/topicref ')]
                                            [@href][not(ancestor::*[contains(@class, ' map/reltable ')])]">
                <xsl:apply-templates select="." mode="reltable"/>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*/@outputclass">
        <xsl:variable name="value">
            <xsl:choose>
                <xsl:when test="contains(normalize-space(.), 'no_help_folder')">
                    <xsl:value-of select="replace(normalize-space(.), 'no_help_folder', '')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="normalize-space($value) != ''">
            <xsl:attribute name="{name(.)}">
                <xsl:value-of select="$value"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' map/topicref ')]/*[contains(@class, ' map/reltable ')]"/>
    <xsl:template match="*[contains(@class, ' map/topicref ')]/*[contains(@class, ' map/topicmeta ')]"/>
    <xsl:template match="*[contains(@class, ' map/topicref ') and contains(@class, ' mapgroup-d/keydef ')]/*[contains(@class, ' map/topicmeta ')]" priority="10">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="*[contains(@class, ' map/topicref ')]/*[contains(@class, ' map/topicmeta ')]" mode="inside-reltable"/>
    <xsl:template match="*[contains(@class, ' map/topicref ') and contains(@class, ' bookmap/backmatter ')]"/>
    <xsl:template match="*[contains(@class, ' map/topicref ') and contains(@class, ' bookmap/preface ')]" priority="10"/>
    <xsl:template match="*[contains(@class, ' map/topicref ') and contains(@class, ' bookmap/notices ')]" priority="10">
        <xsl:if test="$show-page-notes">
            <xsl:next-match/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' map/topicref ')][@href][not(contains(@class, ' mapgroup-d/keydef '))]">
        <xsl:variable name="href-filename" select="ia:getFileNameFromHref(@href)"/>
        <xsl:variable name="new-name" select="$properties-xml-doc/descendant::*[matches(@name, $href-filename)][1]/@new-name"/>
        <xsl:variable name="bridge-topic" select="$properties-xml-doc/descendant::*[matches(@name, $href-filename)][1]/@bridge-topic"/>

        <xsl:variable name="ref-doc-uri" select="if(@href != '') then(resolve-uri($href-filename, $base-dir)) else('')"/>
        <xsl:variable name="ref-doc" select="if(doc-available($ref-doc-uri)) then(document($ref-doc-uri))  else('')"/>
        <xsl:variable name="ref-doc-title" select="if(doc-available($ref-doc-uri))
                                                then($ref-doc/descendant::*[contains(@class, ' topic/title ')][1])
                                                else('')"/>

        <xsl:variable name="navtitle" select="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/navtitle ')]"/>
        <xsl:variable name="title">
            <xsl:choose>
                <xsl:when test="$ref-doc-title != ''">
                    <xsl:value-of select="$ref-doc-title"/>
                </xsl:when>
                <xsl:when test="$navtitle != ''">
                    <xsl:value-of select="$navtitle"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@navtitle"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="map-toc-attr" select="if(doc-available($ref-doc-uri)) then($ref-doc/descendant::*[contains(@class, ' map/map ')][1]/@toc) else('')"/>

        <xsl:choose>
            <xsl:when test="doc-available($ref-doc-uri) and (count($ref-doc/*/*[contains(@class, '- map/topicref ')]) = 1)
                            and (name() = 'topicref')">
                <xsl:apply-templates select="$ref-doc/*[contains(@class, '- map/map ')]/*[contains(@class, ' map/topicref ')]"/>
            </xsl:when>
            <xsl:when test="doc-available($ref-doc-uri) and $ref-doc/descendant::*[contains(@class, '- map/topicref ')][@href][not(ancestor::*[contains(@class, ' map/reltable ')])] and (name() = 'mapref')">
                <xsl:apply-templates select="$ref-doc/descendant::*[contains(@class, '- map/map ')]/*[contains(@class, ' map/topicref ')]"/>
            </xsl:when>
            <xsl:when test="doc-available($ref-doc-uri) and $ref-doc/descendant::*[contains(@class, '- map/topicref ')][@href][not(ancestor::*[contains(@class, ' map/reltable ')])]">
                <xsl:variable name="element-name">
                    <xsl:choose>
                        <xsl:when test="(name() = 'chapter') and (count($ref-doc/*/*[contains(@class, ' map/topicref ')]) = 1)">
                            <xsl:value-of select="'chapter'"/>
                        </xsl:when>
                        <xsl:when test="(name() = 'topicref') and (count($ref-doc/*/*[contains(@class, ' map/topicref ')]) = 1)">
                            <xsl:value-of select="'topicref'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="'topicgroup'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:element name="{$element-name}">
                    <xsl:apply-templates select="@*[not(name() = 'copy-to')]
                                                    [not(name() = 'type')]
                                                    [not(name() = 'format')]
                                                    [not(name() = 'navtitle')]
                                                    [not(name() = 'toc')]
                                                    [not(name() = 'keys')]
                                                    [not(name() = 'href')]"/>
                    <xsl:choose>
                        <xsl:when test="@toc and not(normalize-space(@toc) = '')">
                            <xsl:attribute name="toc" select="@toc"/>
                        </xsl:when>
                        <xsl:when test="parent::*[contains(@outputclass, 'no_help_folder')]">
                            <xsl:attribute name="toc" select="'yes'"/>
                        </xsl:when>
                        <xsl:when test="not(normalize-space($map-toc-attr) = '')">
                            <xsl:attribute name="toc" select="$map-toc-attr"/>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:apply-templates select="$ref-doc/descendant::*[contains(@class, '- map/map ')]/*[contains(@class, ' map/topicref ')]"/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="doc-available($ref-doc-uri) and $ref-doc/descendant::*[contains(@class, ' mapgroup-d/keydef ')]">
                <xsl:variable name="element-name">
                    <xsl:choose>
                        <xsl:when test="(name() = 'chapter') and (count($ref-doc/*/*[contains(@class, ' map/topicref ')]) = 1)">
                            <xsl:value-of select="'chapter'"/>
                        </xsl:when>
                        <xsl:when test="(name() = 'topicref') and (count($ref-doc/*/*[contains(@class, ' map/topicref ')]) = 1)">
                            <xsl:value-of select="'topicref'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="'topicgroup'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:element name="{$element-name}">

                    <xsl:apply-templates select="@*[not(name() = 'copy-to')]
                                                    [not(name() = 'type')]
                                                    [not(name() = 'format')]
                                                    [not(name() = 'navtitle')]
                                                    [not(name() = 'toc')]
                                                    [not(name() = 'keys')]
                                                    [not(name() = 'href')]"/>
                    <xsl:choose>
                        <xsl:when test="@toc and not(normalize-space(@toc) = '')">
                            <xsl:attribute name="toc" select="@toc"/>
                        </xsl:when>
                        <xsl:when test="parent::*[contains(@outputclass, 'no_help_folder')]">
                            <xsl:attribute name="toc" select="'yes'"/>
                        </xsl:when>
                        <xsl:when test="not(normalize-space($map-toc-attr) = '')">
                            <xsl:attribute name="toc" select="$map-toc-attr"/>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:apply-templates select="$ref-doc/descendant::*[contains(@class, ' mapgroup-d/keydef ')]"/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="doc-available($ref-doc-uri) and $ref-doc/descendant::*[contains(@class, '- map/topicref ')][@href][ancestor::*[contains(@class, ' map/reltable ')]]"/>
            <xsl:when test="contains(@outputclass, 'no_help_folder')">
                <xsl:copy>
                    <xsl:apply-templates select="@*[not(name() = 'toc')][not(name() = 'copy-to')][not(name() = 'type')][not(name() = 'outputclass')]"/>
                    <xsl:attribute name="toc" select="'no'"/>
                    <topicmeta>
                        <navtitle>
                            <xsl:value-of select="$title"/>
                        </navtitle>
                    </topicmeta>
                    <xsl:apply-templates select="node()"/>
                </xsl:copy>
            </xsl:when>
            <xsl:when test="$bridge-topic = 'true'">
                <xsl:copy>
                    <xsl:apply-templates select="@*[not(name() = ('href', 'copy-to', 'type', 'outputclass'))]"/>
                    <xsl:attribute name="outputclass" select="concat('bridge ', @outputclass)"/>
                    <topicmeta>
                        <navtitle>
                            <xsl:value-of select="$title"/>
                        </navtitle>
                    </topicmeta>
                    <xsl:apply-templates select="node()"/>
                </xsl:copy>
            </xsl:when>
            <xsl:when test="ancestor::*[contains(@class, ' bookmap/notices ')] and preceding-sibling::*[contains(@class, ' map/topicref ')]"/>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*[not(name() = 'copy-to')][not(name() = 'chunk')]"/>
                    <xsl:if test="not(ancestor::*[contains(@chunk, 'to-content')])">
                        <xsl:choose>
                            <xsl:when test="normalize-space(@copy-to)">
                                <xsl:attribute name="copy-to" select="@copy-to"/>
                            </xsl:when>
                            <xsl:when test="normalize-space($new-name)">
                                <xsl:attribute name="copy-to" select="$new-name"/>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:if test="contains(@chunk, 'to-content')">
                            <xsl:attribute name="chunk">to-content</xsl:attribute>
                        </xsl:if>
                    </xsl:if>
                    <topicmeta>
                        <navtitle>
                            <xsl:value-of select="$title"/>
                        </navtitle>
                    </topicmeta>
                    <xsl:apply-templates select="node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' bookmap/part ') or contains(@class, ' bookmap/chapter ') or contains(@class, ' mapgroup-d/topichead ')][not(@href)]">
        <xsl:variable name="navtitle" select="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/navtitle ')]"/>
        <xsl:variable name="title">
            <xsl:choose>
                <xsl:when test="$navtitle != ''">
                    <xsl:value-of select="$navtitle"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@navtitle"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <topicmeta>
                <navtitle>
                    <xsl:value-of select="$title"/>
                </navtitle>
            </topicmeta>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' bookmap/bookmap ')]/*[contains(@class, ' bookmap/chapter ')][1][contains(@outputclass, 'no_help_folder')]/@outputclass" priority="10">
        <xsl:attribute name="{name(.)}">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="*/@ishlabelxpath" priority="10"/>
    <xsl:template match="*/@ishlinkxpath" priority="10"/>
    <xsl:template match="*/@ishtype" priority="10"/>
    <xsl:template match="*/@domains" priority="10"/>
    <xsl:template match="*/@class" priority="10"/>

    <xsl:template match="*/@ishlabelxpath" priority="10" mode="inside-reltable"/>
    <xsl:template match="*/@ishlinkxpath" priority="10" mode="inside-reltable"/>
    <xsl:template match="*/@ishtype" priority="10" mode="inside-reltable"/>
    <xsl:template match="*/@domains" priority="10" mode="inside-reltable"/>
    <xsl:template match="*/@class" priority="10" mode="inside-reltable"/>

</xsl:stylesheet>
