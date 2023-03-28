<?xml version='1.0' encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:ia="http://intelliarts.com"
                exclude-result-prefixes="xs ia"
                version="2.0">

    <xsl:import href="../dell-webhelp-functions.xsl"/>

    <xsl:output indent="yes"/>
    <xsl:param name="properties-file-path" select="''"/>
    <xsl:param name="use-ftitle-name" select="'no'"/>
    <xsl:param name="dell-brand" select="'EMC'"/>
    <xsl:param name="include-outfile-mode" select="'no'"/>

    <xsl:variable name="useFtitleName" select="if($use-ftitle-name = 'yes') then(true()) else(false())"/>

    <xsl:variable name="properties-filename" select="'emc.properties'"/>
    <xsl:variable name="base-name" select="tokenize(base-uri(),'/')[last()]"/>
    <xsl:variable name="base-dir" select="substring-before(base-uri(),$base-name)"/>

    <xsl:variable name="properties-file-uri" select="concat('file:/', translate($properties-file-path, '\', '/'), '/')"/>
    <xsl:variable name="properties-uri" select="if($properties-file-path !='')
                                            then($properties-file-uri)
                                            else(concat($base-dir, $properties-filename))"/>

    <xsl:variable name="conrefs">
        <xsl:apply-templates select="/descendant::*[@conref]/@conref" mode="conrefs"/>
        <xsl:apply-templates select="/descendant::*[contains(@class, ' map/topicref ')][not(ancestor::*[contains(@class, ' map/reltable ')])]" mode="conrefs"/>
    </xsl:variable>

    <xsl:template match="*[@conref]/@conref" mode="conrefs">
        <xsl:variable name="href" select="."/>
        <xsl:variable name="href-value">
            <xsl:choose>
                <xsl:when test="contains($href, '#')">
                    <xsl:value-of select="substring-before($href, '#')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$href"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="href-filename">
            <xsl:choose>
                <xsl:when test="contains($href-value, '.xml') or contains($href-value, '.dita')">
                    <xsl:value-of select="$href-value"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat($href-value, '.xml')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <conref name="{$href-filename}"/>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' map/topicref ')][not(ancestor::*[contains(@class, ' map/reltable ')])][@href]" mode="conrefs">
        <xsl:variable name="href" select="@href"/>
        <xsl:variable name="href-value">
            <xsl:choose>
                <xsl:when test="contains($href, '#')">
                    <xsl:value-of select="substring-before($href, '#')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$href"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="href-filename">
            <xsl:choose>
                <xsl:when test="contains($href-value, '.xml') or contains($href-value, '.dita')">
                    <xsl:value-of select="$href-value"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat($href-value, '.xml')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="ref-doc-uri" select="concat($base-dir, $href-filename)"/>
        <xsl:variable name="ref-doc" select="document($ref-doc-uri)"/>

        <xsl:if test="doc-available($ref-doc-uri) and $ref-doc/descendant::*[@conref]">
            <xsl:apply-templates select="$ref-doc/descendant::*[@conref]/@conref" mode="conrefs"/>
        </xsl:if>
        <xsl:if test="doc-available($ref-doc-uri) and $ref-doc/descendant::*[contains(@class, ' map/topicref ')][@href][not(ancestor::*[contains(@class, ' map/reltable ')])]">
            <xsl:apply-templates select="$ref-doc/descendant::*[contains(@class, ' map/topicref ')][@href][not(ancestor::*[contains(@class, ' map/reltable ')])]" mode="conrefs"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="/">
        <xsl:variable name="meta-file-name" select="ia:getMetaFileName($base-name)"/>
        <xsl:variable name="met-file-uri" select="concat($base-dir, '/', $meta-file-name)"/>
        <xsl:variable name="ftitle">
            <xsl:choose>
                <xsl:when test="doc-available($met-file-uri) and normalize-space(document($met-file-uri)//*[@name = 'FTITLE'][1]) != ''">
                    <xsl:value-of select="normalize-space(document($met-file-uri)//*[@name = 'FTITLE'][1])"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="substring-before($base-name, '.')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="orig-name" select="concat(substring-before($base-name, '.'), '.html')"/>
        <xsl:variable name="ftitle-name" select="concat(ia:prepareFileName($ftitle), '.html')"/>
        <xsl:variable name="name" select="if($useFtitleName) then($ftitle-name) else('')"/>
        <filelist>
            <pub>
                <xsl:attribute name="name" select="$base-name"/>
                <xsl:attribute name="new-name" select="$name"/>
                <xsl:attribute name="met-file-name" select="$meta-file-name"/>
                <xsl:attribute name="type" select="'map'"/>
            </pub>

            <xsl:variable name="all-files">
                <xsl:apply-templates/>
            </xsl:variable>

            <xsl:variable name="unique-files">
                <xsl:for-each select="$all-files/file">
                    <xsl:variable name="current-name" select="@name"/>
                    <xsl:variable name="current-new-name" select="@new-name"/>
                    <xsl:choose>
                        <xsl:when test="preceding-sibling::file[@new-name = $current-new-name][@name = $current-name]">
                            <xsl:variable name="duplicatesNumber" select="count(preceding-sibling::file[@new-name = $current-new-name][@name = $current-name]) + 1"/>
                            <xsl:copy>
                                <xsl:for-each select="@*[not(name() = 'new-name')]">
                                    <xsl:copy-of select="."/>
                                </xsl:for-each>
                                <xsl:variable name="name-value" select="if(normalize-space(@new-name)) then(@new-name) else(@name)"/>
                                <xsl:attribute name="new-name">
                                    <xsl:value-of select="concat(substring-before($name-value, '.'), '_', $duplicatesNumber, '.xml')"/>
                                </xsl:attribute>
                                <xsl:attribute name="duplicate" select="'true'"/>
                            </xsl:copy>
                        </xsl:when>
                        <xsl:when test="preceding-sibling::file[@new-name != $current-new-name][@name = $current-name]">
                            <xsl:variable name="duplicatesNumber" select="count(preceding-sibling::file[@new-name = $current-new-name][@name = $current-name]) + 1"/>
                            <xsl:copy>
                                <xsl:for-each select="@*">
                                    <xsl:copy-of select="."/>
                                </xsl:for-each>
                                <xsl:attribute name="duplicate" select="'true'"/>
                            </xsl:copy>
                        </xsl:when>
                        <xsl:when test="following-sibling::file[@new-name != $current-new-name][@name = $current-name]">
                            <xsl:variable name="duplicatesNumber" select="count(preceding-sibling::file[@new-name = $current-new-name][@name = $current-name]) + 1"/>
                            <xsl:copy>
                                <xsl:for-each select="@*">
                                    <xsl:copy-of select="."/>
                                </xsl:for-each>
                                <xsl:attribute name="duplicate" select="'true'"/>
                            </xsl:copy>
                        </xsl:when>
                        <xsl:when test="not(preceding-sibling::file[@name = $current-name][@new-name = $current-new-name])">
                            <xsl:copy-of select="."/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:variable>
            <xsl:copy-of select="$unique-files"/>

            <xsl:copy-of select="$conrefs"/>
        </filelist>

        <xsl:variable name="pub-lang" select="if(normalize-space(/*/@xml:lang)) then(/*/@xml:lang) else('EN-US')"/>

        <xsl:result-document href="{$properties-uri}" encoding="utf-8" method="text">
            <xsl:text>ftitle.args.input.name=</xsl:text>
            <xsl:value-of select="$name"/>
            <xsl:value-of select="'&#10;'"/>
            <xsl:text>pub.lang=</xsl:text>
            <xsl:value-of select="$pub-lang"/>
            <xsl:value-of select="'&#10;'"/>
        </xsl:result-document>

        <xsl:result-document href="dummy.xml" encoding="utf-8" method="xml">
            <dummy/>
        </xsl:result-document>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' map/reltable ')]"/>
    <xsl:template match="*[contains(@class, ' map/topicref ')][not(normalize-space(@href))]/*[contains(@class, ' map/topicmeta ')]"/>
    <xsl:template match="*[contains(@class, ' map/reltable ')]" mode="conrefs"/>
    <xsl:template match="*[contains(@class, ' map/topicref ') and contains(@class, ' bookmap/backmatter ')]" priority="10"/>

    <xsl:template match="*[contains(@class, ' map/topicref ') and @href]">
        <xsl:variable name="href" select="@href"/>
        <xsl:variable name="href-value">
            <xsl:choose>
                <xsl:when test="contains($href, '#')">
                    <xsl:value-of select="substring-before($href, '#')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$href"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="href-filename">
            <xsl:choose>
                <xsl:when test="contains($href-value, '.xml') or contains($href-value, '.dita')">
                    <xsl:value-of select="$href-value"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat($href-value, '.xml')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="meta-file-name" select="ia:getMetaFileName($href-filename)"/>
        <xsl:variable name="met-file-uri" select="concat($base-dir, '/', $meta-file-name)"/>

        <xsl:variable name="ref-doc-uri" select="concat($base-dir, $href-filename)"/>
        <xsl:variable name="ref-doc" select="document($ref-doc-uri)"/>

        <xsl:variable name="ftitle">
            <xsl:choose>
                <xsl:when
                        test="doc-available($met-file-uri) and normalize-space(document($met-file-uri)//*[@name = 'FTITLE'][1]) != ''">
                    <xsl:value-of select="normalize-space(document($met-file-uri)//*[@name = 'FTITLE'][1])"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="substring-before($href-filename, '.')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="ftitle-name" select="concat(ia:prepareFileName($ftitle), '.html')"/>
        <xsl:variable name="orig-name" select="concat(substring-before($href-filename, '.'), '.html')"/>
        <xsl:variable name="name" select="if($useFtitleName) then($ftitle-name) else('')"/>

        <xsl:variable name="new-name" select="if(normalize-space(@copy-to)) then(@copy-to) else($name)"/>
        <xsl:variable name="file-type">
            <xsl:choose>
                <xsl:when test="doc-available($ref-doc-uri)
                                and $ref-doc/*[contains(name(), 'map')]">
                    <xsl:value-of select="'map'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'topic'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="topicref-type">
            <xsl:choose>
                <xsl:when test="contains(@class, ' bookmap/preface ')">
                    <xsl:value-of select="'preface'"/>
                </xsl:when>
                <xsl:when test="contains(@class, ' bookmap/notices ')">
                    <xsl:value-of select="'notices'"/>
                </xsl:when>
                <xsl:when test="contains(@class, ' bookmap/chapter ')">
                    <xsl:value-of select="'chapter'"/>
                </xsl:when>
                <xsl:when test="contains(@class, ' bookmap/part ')">
                    <xsl:value-of select="'part'"/>
                </xsl:when>
                <xsl:when test="contains(@class, ' bookmap/appendix ')">
                    <xsl:value-of select="'appendix'"/>
                </xsl:when>
                <xsl:when test="contains(@class, ' bookmap/appendices ')">
                    <xsl:value-of select="'appendices'"/>
                </xsl:when>
                <xsl:when test="contains(@class, ' mapgroup-d/keydef ')">
                    <xsl:value-of select="'keydef'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'topicref'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="bridge-topic">
<!--
            <xsl:choose>
                <xsl:when test="(contains(@class, ' bookmap/chapter ')
                                    or contains(@class, ' bookmap/part ')
                                    or contains(@class, ' bookmap/appendix ')
                                    or contains(@class, ' bookmap/appendices ')
                                    or contains(@class, ' map/notices ') 
                                    or contains(@class, ' bookmap/notices '))
                                and doc-available($ref-doc-uri)
                                and $ref-doc/*[name() = 'topic']">
                    <xsl:value-of select="'true'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'false'"/>
                </xsl:otherwise>
            </xsl:choose>
-->
            <xsl:value-of select="'false'"/>
        </xsl:variable>
        
        <xsl:variable name="noHelpFolder" as="xs:boolean"
                      select="if(contains(@outputclass, 'no_help_folder'))
                            then(true()) else(false())"/>

        <!-- 
            Added by shrinidhi
            variable holds boolean value true if outputclass=printonly
            variable holds boolean value false if outputclass doesnt exist
        -->
        <xsl:variable name="notice-topics">
            <xsl:choose>
                <xsl:when test="(contains(@class, ' map/notices ') or 
                                contains(@class, ' bookmap/notices ')) and 
                                contains(@outputclass, 'printonly')">
                    <xsl:value-of select="'true'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'false'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="includeNotices">
            <xsl:choose>
                <xsl:when test="$notice-topics = 'true'">
                    <xsl:value-of select="'true'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'false'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="exclude">
            <xsl:choose>
                <xsl:when test="contains(@class, ' bookmap/preface ')">
                    <xsl:value-of select="'true'"/>
                </xsl:when>
                <xsl:when test="contains(@class, ' bookmap/notices ')">
                    <xsl:value-of select="'true'"/>
                </xsl:when>
                <xsl:when test="parent::*[contains(@class, ' bookmap/notices ')] and preceding-sibling::*[contains(@class, ' map/topicref ')]">
                    <xsl:value-of select="'true'"/>
                </xsl:when>
                <xsl:when test="$bridge-topic = 'true'">
                    <xsl:value-of select="'true'"/>
                </xsl:when>
                <xsl:when test="$file-type = 'map'">
                    <xsl:value-of select="'true'"/>
                </xsl:when>
                <xsl:when test="not(doc-available($ref-doc-uri))">
                    <xsl:value-of select="'true'"/>
                </xsl:when>
                <xsl:when test="$noHelpFolder">
                    <xsl:value-of select="'true'"/>
                </xsl:when>
                <xsl:when test="$includeNotices = 'true'">
                    <xsl:value-of select="'true'"/>
                </xsl:when>
                <xsl:when test="ancestor::*[contains(@chunk, 'to-content')]">
                    <xsl:value-of select="'true'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'false'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="chunked">
            <xsl:choose>
                <xsl:when test="$dell-brand = ('Dell', 'Dell EMC', 'Alienware', 'Non-brand') and ancestor::*[contains(@chunk, 'to-content')]">true</xsl:when>
                <xsl:otherwise>false</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="chunked-ancestor-filename">
            <xsl:variable name="ancestor-href" select="ancestor::*[contains(@chunk, 'to-content')][last()]/@href"/>
            <xsl:choose>
                <xsl:when test="contains($ancestor-href, '#')">
                    <xsl:value-of select="substring-before($ancestor-href, '#')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$ancestor-href"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="chunked-ancestor-orig-name" select="concat(substring-before($chunked-ancestor-filename, '.'), '.html')"/>

        <xsl:variable name="chunked-href">
            <xsl:choose>
                <xsl:when test="$chunked = 'true'">
                    <xsl:value-of select="concat($chunked-ancestor-orig-name, '#', substring-before($href-filename, '.'))"/>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:variable>

        <!--<xsl:message>bridge topic (bool) : <xsl:value-of select="$bridge-topic"/></xsl:message>
        <xsl:message> Notice-topics : <xsl:value-of select="$notice-topics"/></xsl:message>
        <xsl:message>include notice topic (bool) : <xsl:value-of select="$includeNotices"/></xsl:message>-->
        
        <file>
            <xsl:attribute name="name" select="$href"/>
            <xsl:attribute name="new-name" select="$new-name"/>
            <xsl:attribute name="met-file-name" select="$meta-file-name"/>
            <xsl:attribute name="type" select="$file-type"/>
            <xsl:attribute name="topicref-type" select="$topicref-type"/>
            <xsl:attribute name="bridge-topic" select="$bridge-topic"/>
            <!-- added by shrinidhi -->
            <xsl:attribute name="include-notices" select="$includeNotices"/>
            <!-- code change ends here -->
            <xsl:attribute name="exclude" select="$exclude"/>
            <xsl:attribute name="chunked" select="$chunked"/>
            <xsl:attribute name="chunked-href" select="$chunked-href"/>
        </file>
        <xsl:if test="doc-available($ref-doc-uri) and $ref-doc/descendant::*[contains(@class, ' map/topicref ')]">
            <xsl:apply-templates select="$ref-doc/*"/>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="@*|node()">
        <xsl:apply-templates/>
    </xsl:template>

</xsl:stylesheet>
