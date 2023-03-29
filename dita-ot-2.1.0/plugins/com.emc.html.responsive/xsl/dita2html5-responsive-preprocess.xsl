<?xml version='1.0' encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:ia="http://intelliarts.com"
                exclude-result-prefixes="xs ia"
                version="2.0">

    <xsl:import href="dita2html5-responsive-common-functions.xsl"/>

    <xsl:output indent="yes" encoding="UTF-8"/>

    <xsl:param name="out-extension" select="'.html'"/>

    <xsl:template match="/">
        <xsl:variable name="map-doctype" select="ia:gen-map-doctype(unparsed-text(document-uri(.)))"/>
        <xsl:value-of select="$map-doctype" disable-output-escaping="yes"/>

        <xsl:apply-templates select="node()"/>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' map/map ')]">
        <xsl:variable name="mainbooktitle">
            <!-- IA   Tridion upgrade    Oct-2018   Fixed missed processing of <keyref>s in <mainbook> and TOC titles.
                                                Add processing instead of using just value of title.  - IB-->
            <xsl:apply-templates select="descendant::*[contains(@class, ' bookmap/mainbooktitle ')][1]" mode="title-processing" />
        </xsl:variable>
        <xsl:element name="map">
            <xsl:apply-templates select="@*[not(name() = 'class')]"/>

            <xsl:element name="title">
                <xsl:choose>
                    <xsl:when test="string-length(normalize-space($mainbooktitle)) &gt; 0">
                        <xsl:copy-of select="$mainbooktitle"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'UNTITLED'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>

            <xsl:apply-templates select="node()[not(contains(@class, ' mapgroup-d/keydef ')
                                                or contains(@class, ' bookmap/booktitle ')
                                                or contains(@class, ' map/reltable '))]"/>
            <xsl:call-template name="processReltables"/>
        </xsl:element>
    </xsl:template>

    <xsl:template name="processReltables">
        <xsl:apply-templates select="*[contains(@class, ' map/reltable ')]"/>
        <xsl:for-each select="/descendant::*[contains(@class, ' map/topicref ')
                                        and not(contains(@class, ' mapgroup-d/topichead '))
                                        and not(contains(@class, ' bookmap/part '))][@href]">

            <xsl:variable name="doc" select="document(@href)"/>
            <xsl:choose>
                <xsl:when test="$doc/descendant::*[contains(@class, ' map/map ')]/descendant::*[contains(@class, ' map/reltable ')]">
                    <xsl:apply-templates
                            select="$doc/descendant::*[contains(@class, ' map/map ')]/descendant::*[contains(@class, ' map/reltable ')]"/>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="@xmlns" priority="10"/>

    <xsl:template match="*[contains(@class, ' bookmap/bookmeta ')]">
        <xsl:variable name="month">
            <xsl:choose>
                <xsl:when test="string-length(descendant::completed/descendant::month) &gt; 0">
                    <xsl:value-of select="descendant::completed/descendant::month"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'undefined'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="year">
            <xsl:choose>
                <xsl:when test="string-length(descendant::completed/descendant::year) &gt; 0">
                    <xsl:value-of select="descendant::completed/descendant::year"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'undefined'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:element name="topicmeta">
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="shortdesc"/>
            <critdates>
                <created>
                    <xsl:attribute name="date">
                        <xsl:text>month=</xsl:text>
                        <xsl:value-of select="$month"/>
                        <xsl:text>;year=</xsl:text>
                        <xsl:value-of select="$year"/>
                        <xsl:text>;</xsl:text>
                    </xsl:attribute>
                </created>
            </critdates>
            <!-- IA   Tridion upgrade    Oct-2018   Add support for DELL 'task-label' othermeta parameter.
                        Copy required <othermeta> elements to map.  - IB-->
            <xsl:apply-templates select="othermeta"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' map/topicref ') and contains(@class, ' bookmap/bkinfo ')]" priority="10"/>
    <xsl:template match="*[contains(@class, ' map/topicref ') and contains(@class, ' bookmap/notices ')]" priority="10"/>

    <xsl:template match="*[contains(@class, ' bookmap/backmatter ')]" priority="10"/>

    <xsl:template match="*[contains(@class, ' bookmap/frontmatter ')]" priority="10">
        <xsl:variable name="frontmatter-keyrefs">
            <xsl:for-each select="descendant::*[contains(@class, ' mapgroup-d/keydef ')]">
                <xsl:copy-of select="."/>
            </xsl:for-each>
            <xsl:for-each select="descendant::*[contains(@class, ' map/topicref ')][@href]">
                <xsl:variable name="doc" select="document(@href)"/>
                <xsl:for-each select="$doc/descendant::*[contains(@class, ' mapgroup-d/keydef ')]">
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:variable>

        <xsl:copy-of select="$frontmatter-keyrefs"/>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' bookmap/booktitle ')]"/>

    <xsl:template match="*[contains(@class, ' bookmap/mainbooktitle ')]"/>

    <xsl:template match="*[contains(@class, ' map/topicref ')]/@scope" priority="10" />
    <xsl:template match="*[contains(@class, ' map/topicref ')]/@chunk" priority="10" />
    <xsl:template match="*[contains(@class, ' map/topicref ')]/@class" priority="10" />
    <xsl:template match="*[contains(@class, ' map/topicref ')]/@navtitle" priority="10" />
    <xsl:template match="*[contains(@class, ' map/topicref ')]/@copy-to" priority="10" />

    <xsl:template match="*[contains(@class, ' mapgroup-d/topichead ')]">
        <xsl:apply-templates select="node()"/>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' mapgroup-d/topichead ')]/*[contains(@class, ' map/topicmeta ')]" priority="10"/>

    <xsl:template
            match="*[contains(@class, ' map/topicmeta ')]
                        /*[contains(@class, ' topic/navtitle ')]">
        <xsl:variable name="parent.href" select="ancestor::*[contains(@class, '- map/topicref ')][1]/@href"/>
        <xsl:element name="navtitle">
            <xsl:copy-of select="ia:getNavigationTitle($parent.href, .)"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' map/topicref ') and not(contains(@class, ' mapgroup-d/topichead '))
                                                        and not(contains(@class, ' bookmap/part '))
                                                        and not(contains(@class, ' mapgroup-d/keydef '))]">
        <xsl:variable name="level" select="count(ancestor::*[contains(@class, ' map/topicref ') and not(contains(@class, ' bookmap/part '))]) + 1"/>
        <xsl:variable name="navtitle">
            <xsl:apply-templates select="*[contains(@class, ' map/topicmeta ')][1]/*[contains(@class, ' topic/navtitle ')][1]" mode="title-processing"/>
        </xsl:variable>

        <xsl:variable name="doc" select="document(@href)"/>

        <xsl:variable name="child-topicref" select="descendant::*[contains(@class, ' map/topicref ')
                                                                    and not(contains(@class, ' bookmap/part '))
                                                                    and not(contains(@class, ' mapgroup-d/topichead '))]
                                                                    [@href][1]"/>
        <xsl:variable name="child-topicref-navtitle" select="ia:getNavigationTitle($child-topicref/@href, '')"/>
        <!-- IA   Tridion upgrade    Oct-2018   Fixed missed processing of <keyref>s in <mainbook> and TOC titles.
                  Add processing instead of using just value of title.  - IB-->
        <xsl:variable name="child-topicref-title">
            <xsl:apply-templates select="$child-topicref-navtitle" mode="title-processing"/>
        </xsl:variable>

        <xsl:element name="topicref">
            <xsl:if test="$level = 1 and ancestor::*[contains(@class, ' bookmap/bookmap ')]">
                <xsl:variable name="position">
                    <xsl:value-of
                            select="format-number(count(preceding::*[contains(@class, ' map/topicref ') and not(contains(@class, ' bookmap/part '))]
                                                            [parent::*[contains(@class, ' map/map ') or contains(@class, ' bookmap/part ')]]
                                                            [not(contains(@class, ' mapgroup-d/topichead '))]
                                                            [not(contains(@class, ' bookmap/frontmatter '))]) + 1, '00')"/>
                </xsl:variable>
                <xsl:variable name="correct.name" >
                    <xsl:choose>
                        <xsl:when test="@href">
                            <xsl:value-of select="ia:getNameFromMetaFile(base-uri(), @href)"/>
                        </xsl:when>
                        <xsl:when test="string-length(normalize-space($navtitle)) &gt; 0">
                            <xsl:value-of select="ia:prepareFileName(normalize-space($navtitle))"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="ia:prepareFileName(normalize-space($child-topicref-title))"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>

                <xsl:variable name="output.name" select="concat($position, '-', $correct.name)"/>

                <xsl:attribute name="chunk">
                    <xsl:value-of select="'to-content'"/>
                </xsl:attribute>

                <xsl:attribute name="copy-to">
                    <xsl:value-of select="$output.name"/>
                </xsl:attribute>

            </xsl:if>

            <xsl:if test="$level &gt; 1">
                <xsl:attribute name="toc">
                    <xsl:value-of select="'no'"/>
                </xsl:attribute>
            </xsl:if>

            <xsl:if test="$level = 1 and not(ancestor::*[contains(@class, ' bookmap/bookmap ')])">
                <xsl:attribute name="toc">
                    <xsl:value-of select="'no'"/>
                </xsl:attribute>
            </xsl:if>

            <xsl:choose>
                <xsl:when test="$doc/descendant::*[contains(@class, ' map/map ')]">
                    <xsl:choose>
                        <xsl:when test="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/navtitle ')]">
                            <xsl:apply-templates select="*[contains(@class, ' map/topicmeta ')]"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <topicmeta>
                                <navtitle>
                                    <xsl:value-of select="$child-topicref-title"/>
                                </navtitle>
                            </topicmeta>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:apply-templates select="$doc/descendant::*[contains(@class, ' map/map ')]/*[not(contains(@class, ' map/reltable '))][not(contains(@class, ' topic/title '))]"/>
                    <!--<xsl:apply-templates select="*[not(contains(@class, ' map/topicmeta '))]"/>-->
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="@*"/>
                    <xsl:choose>
                        <xsl:when test="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/navtitle ')]">
                            <xsl:apply-templates select="*[contains(@class, ' map/topicmeta ')]"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <topicmeta>
                                <navtitle>
                                    <xsl:value-of select="$child-topicref-title"/>
                                </navtitle>
                            </topicmeta>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:apply-templates select="*[not(contains(@class, ' map/topicmeta '))]"/>
                </xsl:otherwise>
            </xsl:choose>

        </xsl:element>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' map/topicref ') and contains(@class, ' bookmap/part ')]">
        <xsl:variable name="navtitle"
                      select="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/navtitle ')]"/>

        <xsl:element name="topichead">
            <topicmeta>
                <navtitle>
                    <!-- IA   Tridion upgrade    Oct-2018   Fixed missed processing of <keyref>s in <mainbook> and TOC titles.
                        Add processing instead of using just value of title.  - IB-->
                    <xsl:copy-of select="ia:getNavigationTitle(@href, $navtitle)"/>
                </navtitle>
            </topicmeta>
            <xsl:apply-templates select="node()[not(contains(@class, ' map/topicmeta '))]"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="*" mode="title-processing">
        <!-- IA   Tridion upgrade    Oct-2018   Fixed missed processing of <keyref>s in <mainbook> and TOC titles.
                  Add processing instead of using just value of title.  - IB-->
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:function name="ia:gen-map-doctype" as="xs:string">
        <xsl:param name="unparsed-topic-text" as="xs:string"/>

        <xsl:variable name="doctype" select="replace(
                                                $unparsed-topic-text,
                                                '.*?&lt;!DOCTYPE([^>\[]*(\[[^\]]*\])?)?>.*',
                                                '&#xA;&lt;!DOCTYPE$1&gt;',
                                                's'
                                                )"/>
        <xsl:variable name="replace-bookmap" select="replace(replace($doctype, 'bookmap', 'map'), 'BookMap', 'Map')"/>
        <xsl:sequence select="translate($replace-bookmap, '&#x9;&#xD;&#xA;', ' ')"/>
    </xsl:function>

    <xsl:function name="ia:getNavigationTitle">
        <xsl:param name="href"/>
        <xsl:param name="navtitle"/>

        <xsl:variable name="doc" select="document($href)"/>

        <xsl:variable name="title" >
            <xsl:choose>
                <xsl:when test="$doc/descendant::*[contains(@class, ' map/map ')]">
                    <xsl:variable name="descendant.doc" select="document($doc/descendant::*[contains(@class, ' map/map ')][1]
                                            /descendant::*[contains(@class, ' map/topicref ')][1]/@href)" />
                    <xsl:choose>
                        <xsl:when test="string-length(normalize-space($descendant.doc/descendant::*[contains(@class , ' topic/title ')][1])) &gt; 0">
                            <!-- IA   Tridion upgrade    Oct-2018   Fixed missed processing of <keyref>s in <mainbook> and TOC titles.
                                            Add processing instead of using just value of title.  - IB-->
                            <xsl:apply-templates select="$descendant.doc/descendant::*[contains(@class , ' topic/title ')][1]" mode="title-processing"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- IA   Tridion upgrade    Oct-2018   Fixed missed processing of <keyref>s in <mainbook> and TOC titles.
                                            Add processing instead of using just value of title.  - IB-->
                            <xsl:apply-templates select="$doc/descendant::*[contains(@class, ' map/map ')][1]
                                            /descendant::*[contains(@class, ' map/topicref ')][1]
                                            /descendant::*[contains(@class, ' topic/navtitle ')][1]" mode="title-processing"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when
                        test="string-length(normalize-space($doc/descendant::*[contains(@class , ' topic/title ')][1])) &gt; 0">
                    <!-- IA   Tridion upgrade    Oct-2018   Fixed missed processing of <keyref>s in <mainbook> and TOC titles.
                                            Add processing instead of using just value of title.  - IB-->
                    <xsl:apply-templates select="$doc/descendant::*[contains(@class , ' topic/title ')][1]" mode="title-processing"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$navtitle"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:sequence select="$title"/>
    </xsl:function>

</xsl:stylesheet>
