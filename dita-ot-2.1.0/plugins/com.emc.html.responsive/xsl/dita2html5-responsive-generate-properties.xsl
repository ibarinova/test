<?xml version='1.0' encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:ia="http://intelliarts.com"
                exclude-result-prefixes="xs ia"
                version="2.0">

    <xsl:import href="dita2html5-responsive-common-functions.xsl"/>

    <xsl:param name="ishjobticketXml" select="'ishjobticket.xml'"/>
    <xsl:param name="args.input.name"/>
    <xsl:param name="out-extension" select="'.html'"/>

    <xsl:output indent="yes" encoding="UTF-16"/>

    <xsl:variable name="base-name" select="tokenize(base-uri(),'/')[last()]"/>
    <xsl:variable name="base-dir" select="substring-before(base-uri(),$base-name)"/>

    <xsl:variable name="base-doc" select="document(concat($base-dir, '/', $args.input.name))"/>

    <xsl:variable name="base-meta-file-name" select="ia:getMetaFileName($args.input.name)"/>
    <xsl:variable name="base-meta-doc" select="document(concat($base-dir, '/', $base-meta-file-name))"/>
    <xsl:variable name="ishjobticket-doc" select="document(concat($base-dir, '/', $ishjobticketXml))"/>
    <xsl:variable name="pub-meta-file-name" select="$ishjobticket-doc/descendant::*[@name = 'export-document']"/>
    <xsl:variable name="pub-meta-doc" select="document(concat($base-dir, '/', $pub-meta-file-name, '.met'))"/>

    <xsl:variable name="chapters-number"
              select="count(/descendant::*[contains(@class, ' map/map ')]/child::*[contains(@class, '- map/topicref ')])
              + count(/descendant::*[contains(@class, ' map/map ')]/child::*[contains(@class, ' mapgroup-d/topichead ')]
                        /child::*[contains(@class, '- map/topicref ')])"/>

    <xsl:template match="/">
        <filelist>
            <pub>
                <xsl:attribute name="href" select="$args.input.name"/>
                <xsl:attribute name="meta-file" select="$base-meta-file-name"/>
                <xsl:attribute name="pubFTITLE" select="$pub-meta-doc/descendant::*[@name = 'FTITLE']"/>
                <xsl:attribute name="pubVersion" select="$pub-meta-doc/descendant::*[@name = 'VERSION']"/>
                <xsl:attribute name="pubAccessLevel" select="$pub-meta-doc/descendant::*[@name = 'FEMCACCESSLEVEL']"/>
                <xsl:attribute name="pubType" select="$pub-meta-doc/descendant::*[@name = 'FISHPUBLICATIONTYPE']"/>
                <xsl:attribute name="pubGuid" select="$ishjobticket-doc/descendant::*[@name = 'export-document']"/>
                <xsl:attribute name="pubLanguage" select="$ishjobticket-doc/descendant::*[@name = 'language']"/>
                <!-- IA   Tridion upgrade    Oct-2018   Add support for DELL 'task-label' othermeta parameter.
                     Add 'task-label' othermeta value to specific attribute so we could get it during topic processing.  - IB-->
                <xsl:attribute name="addTaskLabel" select="if(/descendant::*[contains(@class, 'topic/othermeta')][@name = 'task-labels'][last()]/@content = 'no') then('no') else('yes')"/>
            </pub>
            <chapters number="{$chapters-number}"/>
            <xsl:apply-templates/>
        </filelist>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' map/reltable ')]"/>

    <!-- todo add processing for topicrefs without @href-->
    <xsl:template match="*[contains(@class, '- map/topicref ') and @href]">
        <xsl:variable name="href" select="@href"/>
        <xsl:variable name="meta-file-name" select="ia:getMetaFileName($href)"/>
        <xsl:variable name="meta-doc" select="document(concat($base-dir, '/', $meta-file-name))"/>
        <xsl:variable name="title"
                      select="child::*[contains(@class, ' map/topicmeta ')][1]/child::*[contains(@class, ' topic/navtitle ')][1]"/>

        <xsl:variable name="topicGuid">
            <xsl:choose>
                <xsl:when test="matches($meta-file-name, '.*(GUID.*)=\d.*')">
                    <xsl:value-of select="replace($meta-file-name, '.*(GUID.*)=\d.*', '$1')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="substring-before($meta-file-name, '.met')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="name">
            <xsl:choose>
                <xsl:when test="@copy-to">
                    <xsl:value-of select="@copy-to"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$href"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:if test="not(preceding-sibling::*[@href = $href]) and not(preceding::*[@href = $href])">
            <file>
                <xsl:if test="@copy-to">
                    <xsl:attribute name="type" select="'chapter'"/>
                </xsl:if>
                <xsl:attribute name="href" select="$href"/>
                <xsl:attribute name="name" select="$name"/>
                <xsl:attribute name="topic-title" select="$title"/>
                <xsl:attribute name="meta-file" select="$meta-file-name"/>
                <xsl:attribute name="topicGUID" select="$topicGuid"/>
                <xsl:attribute name="topicFTITLE" select="$meta-doc/descendant::*[@name = 'FTITLE']"/>
                <xsl:attribute name="topicLanguage" select="$meta-doc/descendant::*[@name = 'DOC-LANGUAGE']"/>
                <xsl:attribute name="topicVersion" select="$meta-doc/descendant::*[@name = 'VERSION']"/>
                <xsl:attribute name="topicCreateDate" select="$meta-doc/descendant::*[@name = 'CREATED-ON']"/>
                <xsl:attribute name="topicModifiedDate" select="$meta-doc/descendant::*[@name = 'FISHLASTMODIFIEDON']"/>
                <xsl:attribute name="topicAuthor" select="$meta-doc/descendant::*[@name = 'FAUTHOR']"/>
                <xsl:attribute name="topicAccessLevel" select="$meta-doc/descendant::*[@name = 'FEMCACCESSLEVEL']"/>
                <xsl:attribute name="topicContentType" select="$meta-doc/descendant::*[@name = 'FMODULETYPE']"/>
            </file>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="@*|node()">
        <xsl:apply-templates/>
    </xsl:template>

</xsl:stylesheet>