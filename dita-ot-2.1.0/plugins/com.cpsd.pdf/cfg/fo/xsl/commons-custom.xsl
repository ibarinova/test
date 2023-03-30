<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:exsl="http://exslt.org/common" xmlns:opentopic="http://www.idiominc.com/opentopic"
                xmlns:opentopic-index="http://www.idiominc.com/opentopic/index"
                xmlns:opentopic-func="http://www.idiominc.com/opentopic/exsl/function"
                xmlns:dita2xslfo="http://dita-ot.sourceforge.net/ns/200910/dita2xslfo"
                xmlns:ot-placeholder="http://suite-sol.com/namespaces/ot-placeholder"
                xmlns:ss="http://www.suite-sol.com" xmlns:psmi="http://www.CraneSoftwrights.com/resources/psmi"
                extension-element-prefixes="exsl"
                exclude-result-prefixes="ot-placeholder exsl opentopic opentopic-index opentopic-func dita2xslfo xs"
                version="2.0">

    <xsl:template name="processTopicNotices">
        <fo:page-sequence master-reference="body-sequence" xsl:use-attribute-sets="__force__page__count">
            <xsl:call-template name="insertBodyStaticContents"/>
            <fo:flow flow-name="xsl-region-body">
                <fo:block xsl:use-attribute-sets="topic">
                    <xsl:call-template name="commonattributes"/>
                    <xsl:if test="empty(ancestor::*[contains(@class, ' topic/topic ')])">
                        <fo:marker marker-class-name="current-topic-number">
                            <xsl:variable name="topicref"
                                          select="key('map-id', ancestor-or-self::*[contains(@class, ' topic/topic ')][1]/@id)"/>
                            <xsl:for-each select="$topicref">
                                <xsl:apply-templates select="." mode="topicTitleNumber"/>
                            </xsl:for-each>
                        </fo:marker>
                        <fo:marker marker-class-name="current-header">
                            <xsl:for-each select="*[contains(@class, ' topic/title ')]">
                                <xsl:apply-templates select="." mode="getTitle">
                                    <xsl:with-param name="change-markup">no</xsl:with-param>
                                </xsl:apply-templates>
                            </xsl:for-each>
                        </fo:marker>
                    </xsl:if>

                    <xsl:apply-templates select="*[contains(@class, ' topic/prolog ')]"/>

                    <xsl:call-template name="insertChapterFirstpageStaticContent">
                        <xsl:with-param name="type" select="'notices'"/>
                    </xsl:call-template>

                    <fo:block xsl:use-attribute-sets="topic.title">
                        <xsl:call-template name="pullPrologIndexTerms"/>
                        <xsl:for-each select="*[contains(@class, ' topic/title ')]">
                            <xsl:apply-templates select="." mode="getTitle"/>
                        </xsl:for-each>
                    </fo:block>

                    <fo:block xsl:use-attribute-sets="topic.title">
                        <xsl:call-template name="pullPrologIndexTerms"/>
                        <xsl:for-each select="*[contains(@class, ' topic/title ')]">
                            <xsl:apply-templates select="." mode="getTitle"/>
                        </xsl:for-each>
                    </fo:block>

                    <xsl:choose>
                        <xsl:when test="$noticesLayout = 'BASIC'">
                            <xsl:apply-templates
                                    select="
                  *[not(contains(@class, ' topic/topic ') or contains(@class, ' topic/title ') or
                  contains(@class, ' topic/prolog '))]"/>
                            <!--xsl:apply-templates select="." mode="buildRelationships"/-->
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="." mode="createMiniToc"/>
                        </xsl:otherwise>
                    </xsl:choose>

                    <xsl:apply-templates select="*[contains(@class, ' topic/topic ')]"/>
                    <xsl:call-template name="pullPrologIndexTerms.end-range"/>
                </fo:block>
            </fo:flow>
        </fo:page-sequence>
    </xsl:template>

    <xsl:template name="insertChapterFirstpageStaticContent">
        <xsl:param name="type" as="xs:string"/>
        <fo:block>
            <xsl:attribute name="id">
                <xsl:call-template name="generate-toc-id"/>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when test="$type = 'chapter'">
                    <!-- IA   Tridion upgrade    Oct-2018   Remove 'Chapter 1' from the chapter cover page if there is only one chapter in PDF  - IB-->
                    <xsl:if test="count(/descendant::*[contains(@class, ' bookmap/chapter ')]) &gt; 1">
                        <fo:block xsl:use-attribute-sets="__chapter__frontmatter__name__container">
                            <!-- IA   Tridion upgrade    Mar-2019 IDPL-5477: Adapt 3 PDF output formats to support CPSD documenation.
                            Omit chapters number if bookmap has @outputclass = 'omit_chapter_numbers'.  - IB-->
                            <xsl:if test="not($omit-chapter-numbers)">
                                <xsl:call-template name="getVariable">
                                    <xsl:with-param name="id" select="'Chapter with number'"/>
                                    <xsl:with-param name="params" as="element()*">
                                        <number>
                                            <fo:inline xsl:use-attribute-sets="__chapter__frontmatter__number__container">
                                                <xsl:apply-templates select="key('map-id', @id)[1]"
                                                                     mode="topicTitleNumber"/>
                                            </fo:inline>
                                        </number>
                                    </xsl:with-param>
                                </xsl:call-template>
                            </xsl:if>
                        </fo:block>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="$type = 'appendix'">
                    <fo:block xsl:use-attribute-sets="__chapter__frontmatter__name__container">
                        <xsl:call-template name="getVariable">
                            <xsl:with-param name="id" select="'Appendix with number'"/>
                            <xsl:with-param name="params" as="element()*">
                                <number>
                                    <!--IA    Sep-2019    IDPL-7080: PDF, PDF Draft, PDF Beta, CPSD PDF: Appendix does not properly number
                                                Use 'Appendix' title without number if bokkmap contains ONLY ONE Appendix.    -  IB-->
                                    <xsl:if test="count(/descendant::*[contains(@class, ' bookmap/appendix ')]) &gt; 1">
                                        <fo:inline xsl:use-attribute-sets="__chapter__frontmatter__number__container">
                                            <xsl:apply-templates select="key('map-id', @id)[1]" mode="topicTitleNumber"/>
                                        </fo:inline>
                                    </xsl:if>
                                </number>
                            </xsl:with-param>
                        </xsl:call-template>
                    </fo:block>
                </xsl:when>
                <xsl:when test="$type = 'appendices'">
                    <!-- IA   Tridion upgrade    Oct-2018   Remove 'Appendices A' from the appendices cover page if there is only one appendices in PDF  - IB-->
                    <xsl:if test="count(/descendant::*[contains(@class, ' bookmap/appendices ')]) &gt; 1">
                    <fo:block xsl:use-attribute-sets="__chapter__frontmatter__name__container">
                        <xsl:call-template name="getVariable">
                            <xsl:with-param name="id" select="'Appendix with number'"/>
                            <xsl:with-param name="params" as="element()*">
                                <number>
                                    <fo:inline xsl:use-attribute-sets="__chapter__frontmatter__number__container">
                                        <xsl:text>&#xA0;</xsl:text>
                                    </fo:inline>
                                </number>
                            </xsl:with-param>
                        </xsl:call-template>
                    </fo:block>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="$type = 'part'">
                    <!-- IA   Tridion upgrade    Oct-2018   Remove 'Part 1' from the part cover page if there is only one part in PDF  - IB-->
                    <xsl:if test="count(/descendant::*[contains(@class, ' bookmap/part ')]) &gt; 1">
                        <fo:block xsl:use-attribute-sets="__chapter__frontmatter__name__container">
                            <xsl:call-template name="getVariable">
                                <xsl:with-param name="id" select="'Part with number'"/>
                                <xsl:with-param name="params" as="element()*">
                                    <number>
                                        <fo:inline xsl:use-attribute-sets="__chapter__frontmatter__number__container">
                                            <xsl:apply-templates select="key('map-id', @id)[1]"
                                                                 mode="topicTitleNumber"/>
                                        </fo:inline>
                                    </number>
                                </xsl:with-param>
                            </xsl:call-template>
                        </fo:block>
                    </xsl:if>
                </xsl:when>
                <!--<xsl:when test="$type = 'preface'">
                  <fo:block xsl:use-attribute-sets="__chapter__frontmatter__name__container">
                    <xsl:call-template name="getVariable">
                      <xsl:with-param name="id" select="'Preface title'"/>
                    </xsl:call-template>
                  </fo:block>
                </xsl:when>-->
                <xsl:when test="$type = 'notices'">
                    <fo:block xsl:use-attribute-sets="__chapter__frontmatter__name__container">
                        <xsl:call-template name="getVariable">
                            <xsl:with-param name="id" select="'Notices title'"/>
                        </xsl:call-template>
                    </fo:block>
                </xsl:when>
            </xsl:choose>
        </fo:block>
    </xsl:template>

    <!-- Suite Sep-21-2012: If body contains a descendant with outputclass=landscape, do not create fo:block around body.
      Instead, apply-templates with tunnelled param so each child without the outputclass, and without a descendant with outputclass
      will be wrapped in its own "body" fo:block.
      "body" attribute-set can be used for all level topics as body, body__toplevel, and body__secondLevel are all identical. - rs -->
    <xsl:template match="*" mode="createMiniToc">
        <fo:block xsl:use-attribute-sets="body">
            <!--added attr-set to indent - rs-->
            <xsl:apply-templates select="*[contains(@class, ' topic/titlealts ')]"/>
            <xsl:if
                    test="
          *[contains(@class, ' topic/shortdesc ')
          or contains(@class, ' topic/abstract ')]/node()">
                <fo:block xsl:use-attribute-sets="p">
                    <xsl:apply-templates
                            select="
              *[contains(@class, ' topic/shortdesc ')
              or contains(@class, ' topic/abstract ')]/node()"
                    />
                </fo:block>
            </xsl:if>
        </fo:block>
        <xsl:choose>
            <xsl:when
                    test="*[contains(@class, ' topic/body ')]/descendant::*[contains(@outputclass, 'landscape')]">
                <xsl:apply-templates select="*[contains(@class, ' topic/body ')]/*">
                    <xsl:with-param name="body-block" tunnel="yes">yes</xsl:with-param>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <fo:block xsl:use-attribute-sets="body">
                    <xsl:apply-templates select="*[contains(@class, ' topic/body ')]/*"/>
                </fo:block>
            </xsl:otherwise>
        </xsl:choose>
        <fo:block xsl:use-attribute-sets="body">
            <!-- Added with RFE 2976463 to fix dropped links in topics with a mini-TOC. -->
            <xsl:if
                    test="
          *[contains(@class, ' topic/related-links ')]//
          *[contains(@class, ' topic/link ')][not(@role) or @role != 'child']">
                <xsl:apply-templates select="*[contains(@class, ' topic/related-links ')]"/>
            </xsl:if>
        </fo:block>
        <!-- IA   Tridion upgrade    Oct-2018   Add support for DELL othermeta parameters - IB-->
        <!-- IA   Tridion upgrade    Oct-2018   Do not generate mini-toc ONLY if 'mini-toc' <othermeta> value equal 'no'  - IB-->
        <!-- IA   Tridion upgrade    Mar-2019 IDPL-5477: Adapt 3 PDF output formats to support CPSD documenation.
                             Omit minitoc if bookmap has @outputclass = 'omit_chapter_numbers' even if
                             'mini-toc' <othermeta> value equal 'yes'.  - IB-->
        <xsl:if test="$generate-mini-toc and(not($omit-chapter-numbers))">
            <fo:block xsl:use-attribute-sets="__toc__mini">
                <xsl:if test="*[contains(@class, ' topic/topic ')]">
                    <fo:list-block xsl:use-attribute-sets="__toc__mini__list">
                        <xsl:choose>
                            <xsl:when test="preceding::*[contains(@class, ' bookmap/part ')][current()/@id = @id]">
                                <xsl:apply-templates select="*[contains(@class, ' topic/topic ')]"
                                                     mode="in-this-part-list"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="*[contains(@class, ' topic/topic ')]"
                                                     mode="in-this-chapter-list"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </fo:list-block>
                </xsl:if>
            </fo:block>
        </xsl:if>
        <xsl:if test="not(preceding::*[contains(@class, ' bookmap/part ')][current()/@id = @id]) and not($omit-chapter-numbers)">
            <!-- IA   Tridion upgrade    Mar-2019 IDPL-5477: Adapt 3 PDF output formats to support CPSD documenation.
                                    Remove page break after Chapter topic. Process 2-nd level topic on the same page
                                    as Chapter topic if bookmap has @outputclass = 'omit_chapter_numbers'.  - IB-->
            <fo:block break-after="page"/>
        </xsl:if>
    </xsl:template>

    <!-- Balaji Mani 1-Apr-2013 Added for the part minitoc -->
    <xsl:template match="*[contains(@class, ' topic/topic ')]" mode="in-this-part-list">
        <fo:list-item xsl:use-attribute-sets="minitoc__ul.li">
            <fo:list-item-label xsl:use-attribute-sets="ul.li__label">
                <fo:block xsl:use-attribute-sets="ul.li__label__content">
                    <!--<xsl:call-template name="getVariable">
                      <xsl:with-param name="id" select="''"/>
                    </xsl:call-template>-->
                </fo:block>
            </fo:list-item-label>
            <fo:list-item-body xsl:use-attribute-sets="ul.li__body">
                <fo:block margin-left="-0.25in" padding-bottom="10pt">
                    <fo:basic-link internal-destination="{@id}" xsl:use-attribute-sets="xref">
                        <!-- IA   Tridion upgrade    Jan-2019   Remove 'Chapter 1' from the chapter cover page if there is only one chapter in PDF  - IB-->
                        <!-- IA   Tridion upgrade    Mar-2019 IDPL-5477: Adapt 3 PDF output formats to support CPSD documenation.
                                                    Omit minitoc if bookmap has @outputclass = 'omit_chapter_numbers'
                                                    even if 'mini-toc' <othermeta> value equal 'yes'.  - IB-->
                        <xsl:if test="(count(/descendant::*[contains(@class, ' bookmap/chapter ')]) &gt; 1) and(not($omit-chapter-numbers))">
                            <xsl:call-template name="getVariable">
                                <xsl:with-param name="id" select="'Chapter with number'"/>
                                <xsl:with-param name="params" as="element()*">
                                    <number>
                                        <xsl:apply-templates select="key('map-id', @id)[1]" mode="topicTitleNumber"/>
                                    </number>
                                </xsl:with-param>
                            </xsl:call-template>
                            <xsl:text>, </xsl:text>
                        </xsl:if>
                        "<xsl:value-of select="child::*[contains(@class, ' topic/title ')]"/>"
                    </fo:basic-link>
                </fo:block>
            </fo:list-item-body>
        </fo:list-item>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/topic ')]" mode="in-this-chapter-list">
        <fo:list-item xsl:use-attribute-sets="minitoc__ul.li">
            <fo:list-item-label xsl:use-attribute-sets="ul.li__label">
                <fo:block xsl:use-attribute-sets="ul.li__label__content">
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'Unordered List bullet level1'"/>
                    </xsl:call-template>
                </fo:block>
            </fo:list-item-label>
            <fo:list-item-body xsl:use-attribute-sets="ul.li__body">
                <fo:block xsl:use-attribute-sets="minitoc__ul.li__content">
                    <fo:basic-link internal-destination="{@id}" xsl:use-attribute-sets="xref">
                        <!-- Suite/EMC  SOW7x  13-Aug-2013  Mantis #9040
                   Deleted topics are not being picked up by change tracking code, as the processing instructions do not get passed into the merged file for topic references.
                   Call change tracking code here, only for checking deleted topics.
                   Note:  we did not add support for retaining nested topics if only parent topic deleted.  - LB -->
                        <xsl:call-template name="add.changebars">
                            <xsl:with-param name="node" select="."/>
                            <xsl:with-param name="type" select="'begin'"/>
                            <xsl:with-param name="language">
                                <xsl:call-template name="get.current.language"/>
                            </xsl:with-param>
                            <xsl:with-param name="placement" select="'inline'"/>
                        </xsl:call-template>
                        <xsl:value-of select="child::*[contains(@class, ' topic/title ')]"/>
                        <xsl:call-template name="add.changebars">
                            <xsl:with-param name="node" select="."/>
                            <xsl:with-param name="type" select="'end'"/>
                            <xsl:with-param name="language">
                                <xsl:call-template name="get.current.language"/>
                            </xsl:with-param>
                            <xsl:with-param name="placement" select="'inline'"/>
                        </xsl:call-template>
                    </fo:basic-link>
                    <fo:inline xsl:use-attribute-sets="toc.item.right">
                        <fo:leader xsl:use-attribute-sets="__toc__leader"/>
                        <fo:page-number-citation ref-id="{concat('_OPENTOPIC_TOC_PROCESSING_', generate-id())}"
                        />
                    </fo:inline>
                </fo:block>
            </fo:list-item-body>
        </fo:list-item>
    </xsl:template>

    <!-- mckimn 25-April-2017 prepend brand name to content wrapped in keyword with outputclass="prodname" -->
    <xsl:template match="*[contains(@class,' topic/keyword ')][@outputclass='branded']">
        <fo:inline xsl:use-attribute-sets="ph">
            <xsl:call-template name="commonattributes"/>
            <xsl:value-of select="$BRAND-TEXT"/>
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>

    <!-- Balaji Mani 12-June-2013: table footnote callout process -->
    <xsl:template
            match="*[contains(@class, ' topic/fn ')][ancestor::*[contains(@class, ' topic/table ') or contains(@class, ' topic/simpletable ') or contains(@class, ' task/choicetable ')]]">
        <fo:basic-link font-style="normal">
            <xsl:attribute name="internal-destination" select="generate-id(.)"/>
            <fo:inline xsl:use-attribute-sets="fn__callout_ref">
                <xsl:variable name="tableId"
                              select="ancestor::*[contains(@class, ' topic/table ') or contains(@class, ' topic/simpletable ') or contains(@class, ' task/choicetable ')]/generate-id(.)"/>
                <xsl:variable name="tableFnCountRef"
                              select="count(preceding::*[contains(@class, ' topic/fn ') and ancestor::*[contains(@class, ' topic/table ') or contains(@class, ' topic/simpletable ') or contains(@class, ' task/choicetable ') and generate-id(.) = $tableId] and ancestor::*[contains(@class, ' topic/table ') or contains(@class, ' topic/simpletable ') or contains(@class, ' task/choicetable ')]/generate-id(.) = $tableId])"/>
                <xsl:choose>
                    <xsl:when test="translate($locale, 'RU', 'ru') = 'ru'">
                        <xsl:number format="&#x0430;" value="$tableFnCountRef + 1"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:number format="a" value="$tableFnCountRef + 1"/>
                    </xsl:otherwise>
                </xsl:choose>
            </fo:inline>
        </fo:basic-link>
    </xsl:template>

    <!--Modified formatting of table footnotes and of all footnote numbers - rs-->
    <!-- Balaji Mani 12-June-2013: process footnote except table -->
    <xsl:template
            match="*[contains(@class, ' topic/fn ')][not(ancestor::*[contains(@class, ' topic/table ') or contains(@class, ' topic/simpletable ') or contains(@class, ' task/choicetable ')])]">
        <fo:inline id="{@id}"/>
        <fo:footnote xsl:use-attribute-sets="fn_container" axf:footnote-keep="always"
                     xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions">
            <fo:inline xsl:use-attribute-sets="fn__callout_ref">
                <xsl:number format="1" level="any"
                            count="*[contains(@class, ' topic/fn ')][not(ancestor::*[contains(@class, ' topic/table ') or contains(@class, ' topic/simpletable ') or contains(@class, ' task/choicetable ')])]"
                />
            </fo:inline>
            <!-- Balaji Mani IB2 18-July-2013: Removed the end-indent for label -->
            <!-- EMC	 Hotfix_3.2		25-Jun-2015		TKT 298: Adding end-label() and body-start() -->
            <fo:footnote-body>
                <fo:list-block xsl:use-attribute-sets="fn__body" id="{@id}">
                    <fo:list-item>
                        <fo:list-item-label xsl:use-attribute-sets="fn__label_start">
                            <fo:block text-align-last="right">
                                <fo:inline xsl:use-attribute-sets="fn__callout">
                                    <xsl:number format="1." level="any"
                                                count="*[contains(@class, ' topic/fn ')][not(ancestor::*[contains(@class, ' topic/table ') or contains(@class, ' topic/simpletable ') or contains(@class, ' task/choicetable ')])]"
                                    />
                                </fo:inline>
                            </fo:block>
                        </fo:list-item-label>
                        <fo:list-item-body xsl:use-attribute-sets="fn__body_start">
                            <fo:block>
                                <xsl:apply-templates/>
                            </fo:block>
                        </fo:list-item-body>
                    </fo:list-item>
                </fo:list-block>
            </fo:footnote-body>
        </fo:footnote>
    </xsl:template>

    <!-- Balaji Mani 12-June-2013: process table footnote -->
    <xsl:template match="*[contains(@class, ' topic/fn ')]" mode="from-table">
        <fo:block xsl:use-attribute-sets="fn_container">
            <fo:list-block xsl:use-attribute-sets="fn__body">
                <xsl:attribute name="id">
                    <xsl:value-of select="generate-id(.)"/>
                </xsl:attribute>
                <fo:list-item>
                    <fo:list-item-label end-indent="label-end()">
                        <fo:block text-align="right">
                            <fo:inline xsl:use-attribute-sets="fn__callout">
                                <xsl:variable name="tableId"
                                              select="ancestor::*[contains(@class, ' topic/table ') or contains(@class, ' topic/simpletable ') or contains(@class, ' task/choicetable ')]/generate-id()"/>
                                <xsl:comment>tableId=<xsl:value-of select="$tableId"/>
                                </xsl:comment>
                                <xsl:choose>
                                    <xsl:when test="translate($locale, 'RU', 'ru') = 'ru'">
                                        <xsl:number format="&#x0430;."
                                                    from="//*[(contains(@class, ' topic/table ') or contains(@class, ' topic/simpletable ') or contains(@class, ' task/choicetable ')) and generate-id() = $tableId]"
                                                    level="any"
                                                    count="*[contains(@class, ' topic/fn ')][ancestor::*[contains(@class, ' topic/table ') or contains(@class, ' topic/simpletable ') or contains(@class, ' task/choicetable ')]]"
                                        />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:number format="a."
                                                    from="//*[(contains(@class, ' topic/table ') or contains(@class, ' topic/simpletable ') or contains(@class, ' task/choicetable ')) and generate-id() = $tableId]"
                                                    level="any"
                                                    count="*[contains(@class, ' topic/fn ')][ancestor::*[contains(@class, ' topic/table ') or contains(@class, ' topic/simpletable ') or contains(@class, ' task/choicetable ')]]"
                                        />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </fo:inline>
                        </fo:block>
                    </fo:list-item-label>
                    <fo:list-item-body start-indent="body-start()">
                        <fo:block>
                            <xsl:apply-templates/>
                        </fo:block>
                    </fo:list-item-body>
                </fo:list-item>
            </fo:list-block>
        </fo:block>
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/note ')]">
        <xsl:apply-templates select="." mode="placeNoteContent"/>
    </xsl:template>

    <xsl:template match="*" mode="placeNoteContent">
        <!-- IA   Tridion upgrade    Oct-2018   Add new admonitions view STARTS HERE. - IB-->
        <xsl:variable name="type">
            <xsl:choose>
                <xsl:when test="@type = ('danger', 'warning', 'caution', 'notice')">
                    <xsl:value-of select="@type"/>
                </xsl:when>
                <xsl:otherwise>note</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="image-type">
            <xsl:choose>
                <xsl:when test="@type = 'warning'">warning</xsl:when>
                <xsl:when test="@type = 'danger'">danger</xsl:when>
                <xsl:when test="@type = 'caution'">caution</xsl:when>
                <xsl:otherwise>note</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <fo:table xsl:use-attribute-sets="note_table">
            <fo:table-column column-width="{if(ancestor::table) then('13pt') else('15pt')}"/>
            <fo:table-column/>
            <fo:table-body>
                <fo:table-row>
                    <fo:table-cell xsl:use-attribute-sets="note_image_cell">
                        <xsl:call-template name="insert_admonition_image">
                            <xsl:with-param name="image-type" select="$image-type"/>
                        </xsl:call-template>
                    </fo:table-cell>
                    <fo:table-cell xsl:use-attribute-sets="note_body_cell">
                        <fo:block xsl:use-attribute-sets="note_body_cell_content">
							<!-- Dimitri: Render admonitions in uppercase, followed by a colon. -->
                            <!--fo:inline xsl:use-attribute-sets="note_colored_text">
                                <xsl:call-template name="insert_admonition_text">
                                    <xsl:with-param name="type" select="$type"/>
                                </xsl:call-template>
                            </fo:inline>
                            <fo:inline><xsl:text> </xsl:text></fo:inline-->
                            <fo:inline xsl:use-attribute-sets="note_colored_text">
                                <xsl:call-template name="insert_admonition_text">
                                    <xsl:with-param name="type" select="upper-case($type)"/>
                                </xsl:call-template>
                                <xsl:text>: </xsl:text>
                            </fo:inline>
                            <xsl:apply-templates/>
                        </fo:block>
                    </fo:table-cell>
                </fo:table-row>
            </fo:table-body>
        </fo:table>
        <!-- IA   Tridion upgrade    Oct-2018   Add new admonitions view ENDS HERE. - IB-->
    </xsl:template>

    <xsl:template name="insert_admonition_image">
        <xsl:param name="image-type" select="'note'"/>

        <xsl:variable name="image-path">
            <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="concat($image-type, ' Image Path')"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="ancestor::table">
                <fo:block xsl:use-attribute-sets="note__image">
                    <fo:external-graphic src="url({$image-path})" content-height="14px"/>
                </fo:block>
            </xsl:when>
            <xsl:otherwise>
                <fo:block xsl:use-attribute-sets="note__image">
                    <fo:external-graphic src="url({$image-path})" content-height="16px"/>
                </fo:block>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="insert_admonition_text">
        <xsl:param name="type" select="'note'"/>
        <xsl:call-template name="getVariable">
            <xsl:with-param name="id" select="$type"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/image ')]">
        <xsl:choose>
            <xsl:when test="empty(@href)"/>
            <xsl:when test="contains(@outputclass, 'landscape') and parent::*[contains(@class,' topic/body ')]">
                <psmi:page-sequence master-reference="body-landscape-sequence">
                    <xsl:call-template name="insertBodyStaticContents"/>
                    <fo:flow flow-name="xsl-region-body">
                        <fo:block xsl:use-attribute-sets="image__block">
                            <xsl:call-template name="commonattributes"/>
                            <xsl:apply-templates select="." mode="placeImage">
                                <xsl:with-param name="imageAlign" select="@align"/>
                                <xsl:with-param name="href"
                                                select="if (@scope = 'external' or opentopic-func:isAbsolute(@href)) then @href else concat($input.dir.url, @href)"/>
                                <xsl:with-param name="height" select="@height"/>
                                <xsl:with-param name="width" select="@width"/>
                            </xsl:apply-templates>
                        </fo:block>
                    </fo:flow>
                </psmi:page-sequence>
            </xsl:when>
            <xsl:when
                    test="@placement = 'break'
                    or contains(@outputclass, 'pagewide')
                    or parent::*[contains(@class, ' topic/fig ')][contains(@outputclass, 'pagewide')]
                    or (contains(@outputclass,'landscape') and parent::*[contains(@class,' topic/body ')])">
                <fo:block xsl:use-attribute-sets="image__block">
                    <xsl:call-template name="commonattributes"/>
                    <xsl:apply-templates select="." mode="placeImage">
                        <xsl:with-param name="imageAlign" select="@align"/>
                        <xsl:with-param name="href"
                                        select="if (@scope = 'external' or opentopic-func:isAbsolute(@href)) then @href else concat($input.dir.url, @href)"/>
                        <xsl:with-param name="height" select="@height"/>
                        <xsl:with-param name="width" select="@width"/>
                    </xsl:apply-templates>
                </fo:block>
            </xsl:when>
            <xsl:otherwise>
                <fo:inline xsl:use-attribute-sets="image__inline">
                    <xsl:call-template name="commonattributes"/>
                    <xsl:apply-templates select="." mode="placeImage">
                        <xsl:with-param name="imageAlign" select="@align"/>
                        <xsl:with-param name="href"
                                        select="if (@scope = 'external' or opentopic-func:isAbsolute(@href)) then @href else concat($input.dir.url, @href)"/>
                        <xsl:with-param name="height" select="@height"/>
                        <xsl:with-param name="width" select="@width"/>
                    </xsl:apply-templates>
                </fo:inline>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*" mode="placeImage">
        <xsl:param name="imageAlign"/>
        <xsl:param name="href"/>
        <xsl:param name="height" as="xs:string?"/>
        <xsl:param name="width" as="xs:string?"/>

        <!-- IA   Tridion upgrade    Mar-2019   IDPL-5503: Large graphics run off the page in PDF layouts.
                                            Add @max-width for image. Value depends on page orientation and
                                            left margin of lists (if image is nested element of list)   - IB-->

        <xsl:variable name="listLevel" select="count(ancestor::*[contains(@class, ' topic/li ')]) - 1"/>
        <xsl:variable name="list-left-margin" select="$list-item-indent + ($listLevel*$sublist-item-indent)"/>
        <xsl:variable name="max-width-number">
            <xsl:choose>
                <xsl:when test="ancestor::*[contains(@class, ' topic/li ')]
                                and not(ancestor::*[contains(@outputclass, 'landscape')])
                                and not(parent::*[contains(@class, ' topic/fig ')][contains(@outputclass, 'pagewide')])">
					<!-- Dimitri: Increase maximum image/figure width. -->
                    <!--xsl:variable name="image-width" select="5.27 - $list-left-margin"/-->
					<xsl:variable name="image-width" select="7 - $list-left-margin"/>
                    <xsl:value-of select="$image-width"/>
                </xsl:when>
                <xsl:when test="ancestor::*[contains(@class, ' topic/li ')]
                                and parent::*[contains(@outputclass, 'landscape')]
                                and not(parent::*[contains(@class, ' topic/fig ')][contains(@outputclass, 'pagewide')])">
                    <xsl:variable name="image-width" select="9.55 - $list-left-margin"/>
                    <xsl:value-of select="$image-width"/>
                </xsl:when>
                <xsl:when test="parent::*[contains(@class, ' topic/fig ')][contains(@outputclass, 'pagewide')]">7.018</xsl:when>
                <xsl:when test="parent::*[contains(@outputclass, 'landscape')]">9.55</xsl:when>
				<!-- Dimitri: Increase maximum image/figure width. -->
                <!--xsl:otherwise>5.27</xsl:otherwise-->
				<xsl:otherwise>7.27</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="max-width" select="concat($max-width-number, 'in')"/>

        <!--Using align attribute set according to image @align attribute-->
        <xsl:call-template name="processAttrSetReflection">
            <xsl:with-param name="attrSet" select="concat('__align__', $imageAlign)"/>
            <xsl:with-param name="path" select="'../../cfg/fo/attrs/commons-attr.xsl'"/>
        </xsl:call-template>
        <fo:external-graphic src="url('{$href}')" xsl:use-attribute-sets="image">
            <!--Setting image height if defined-->
            <xsl:if test="$height">
                <xsl:attribute name="content-height">
                    <!--The following test was commented out because most people found the behavior
                     surprising.  It used to force images with a number specified for the dimensions
                     *but no units* to act as a measure of pixels, *if* you were printing at 72 DPI.
                     Uncomment if you really want it. -->
                    <xsl:choose>
                        <!--xsl:when test="not(string(number($height)) = 'NaN')">
                          <xsl:value-of select="concat($height div 72,'in')"/>
                        </xsl:when-->
                        <xsl:when test="not(string(number($height)) = 'NaN')">
                            <xsl:value-of select="concat($height, 'px')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$height"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </xsl:if>
            <!--Setting image width if defined-->
            <xsl:if test="$width">
                <xsl:attribute name="content-width">
                    <xsl:choose>
                        <!--xsl:when test="not(string(number($width)) = 'NaN')">
                          <xsl:value-of select="concat($width div 72,'in')"/>
                        </xsl:when-->
                        <xsl:when test="not(string(number($width)) = 'NaN')">
                            <xsl:value-of select="concat($width, 'px')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$width"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="not($width) and not($height) and @scale">
                <xsl:attribute name="content-width">
                    <xsl:value-of select="concat(@scale,'%')"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@scalefit = 'yes' and not($width) and not($height) and not(@scale)">
                <xsl:attribute name="width">100%</xsl:attribute>
                <xsl:attribute name="height">100%</xsl:attribute>
                <xsl:attribute name="content-width">scale-to-fit</xsl:attribute>
                <xsl:attribute name="content-height">scale-to-fit</xsl:attribute>
                <xsl:attribute name="scaling">uniform</xsl:attribute>
            </xsl:if>
            <xsl:if test="not(@max-width)">
                <xsl:attribute name="max-width"><xsl:value-of select="$max-width"/></xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="node() except (*[contains(@class, ' topic/alt ') or
                                                        contains(@class, ' topic/longdescref ')])"/>
        </fo:external-graphic>
    </xsl:template>

    <!--Suite/EMC Aug-27-2012 add title id to figgroup -->
    <xsl:template match="*[contains(@class,' topic/figgroup ')]">
        <fo:inline>
            <xsl:attribute name="id">
                <xsl:value-of select="*[contains(@class, ' topic/title ')]/@id"/>
            </xsl:attribute>
        </fo:inline>
        <fo:inline xsl:use-attribute-sets="figgroup">
            <xsl:call-template name="commonattributes"/>
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/fig ')]">
        <xsl:choose>
            <xsl:when test="contains(@outputclass, 'landscape') and parent::*[contains(@class,' topic/body ')]">
                <psmi:page-sequence master-reference="body-landscape-sequence">
                    <xsl:call-template name="insertBodyStaticContents"/>
                    <fo:flow flow-name="xsl-region-body">
                        <xsl:apply-templates select="." mode="figSubTemplate"/>
                    </fo:flow>
                </psmi:page-sequence>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="." mode="figSubTemplate"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*" mode="figSubTemplate">
        <xsl:param name="parent" tunnel="yes" select="''"/>
        <fo:block xsl:use-attribute-sets="fig">
            <xsl:call-template name="commonattributes"/>
            <xsl:call-template name="setFrame"/>
            <xsl:if test="not(@id)">
                <xsl:attribute name="id">
                    <xsl:call-template name="get-id"/>
                </xsl:attribute>
            </xsl:if>
            <fo:table>
                <xsl:attribute name="width">
                    <xsl:choose>
                        <xsl:when
                                test="contains(@outputclass, 'landscape') and parent::*[contains(@class,' topic/body ')]">
                            <xsl:value-of select="$page-width-without-margins-landscape"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$page-width-without-margins"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <fo:table-column>
                    <!-- Suite/EMC   SOW7    19-Feb-2013   Prevent right margin overflow - set column-width based on parent element - rs -->
                    <xsl:attribute name="column-width">
                        <xsl:choose>
                            <xsl:when test="$parent='example'">0in</xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$side-col-1"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                </fo:table-column>
                <fo:table-column>
                    <!-- Suite/EMC   SOW7    19-Feb-2013   Prevent right margin overflow - set column-width based on parent element - rs -->
                    <xsl:attribute name="column-width">
                        <xsl:choose>
                            <xsl:when test="$parent='example'">0in</xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$side-col-2"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                </fo:table-column>
                <!-- if fig is inside list, indent more to align with text-->
                <xsl:variable name="list-ancestor-count"
                              select="count(ancestor::*[contains(@class,' topic/ol ') or contains(@class,' topic/ul ')])"/>
                <xsl:variable name="column-width">
                    <xsl:choose>
                        <xsl:when test="$list-ancestor-count=0">0</xsl:when>
                        <xsl:when test="ancestor::*[contains(@class,' topic/ol ') or contains(@class,' topic/ul ')]
                                        [last()]
                                        [contains(@class, ' task/steps ') or contains(@class, ' task/steps-unordered ')]">
                            <xsl:value-of
                                    select="$list-item-indent + ($list-ancestor-count*$sublist-item-indent) - 0.035"/>
                        </xsl:when>
                        <xsl:otherwise>
							<!-- Dimitri: After adding the ol and ul indent, increase image indent inside lists and steps. -->
                            <!--xsl:value-of
                                    select="$list-item-indent - $list-indent + ($list-ancestor-count*$sublist-item-indent) "/-->
							<xsl:value-of select="$list-item-indent - $list-indent + ($list-ancestor-count*$sublist-item-indent) + 0.25"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <fo:table-column>
                    <xsl:attribute name="column-width">
                        <xsl:value-of select="$column-width"/>
                        <xsl:text>in</xsl:text>
                    </xsl:attribute>
                </fo:table-column>
                <fo:table-column>
                    <xsl:attribute name="column-width">
                        <xsl:choose>
                            <xsl:when
                                    test="contains(@outputclass, 'landscape') and parent::*[contains(@class,' topic/body ')]">
                                <xsl:value-of select="$main-col-landscape"/>
                                <xsl:text>in</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$main-col - $column-width"/>
                                <xsl:text>in</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                </fo:table-column>

                <xsl:if test="*[contains(@class,' topic/title ')]">
                    <fo:table-header>
                        <fo:table-row>
                            <!--Suite/EMC   SOW5  16-Feb-2012   fix figure title spacing START - ck-->
                            <fo:table-cell/>
                            <fo:table-cell/>
                            <fo:table-cell/>
                            <fo:table-cell xsl:use-attribute-sets="fig.title">
                                <!-- Intelliarts Consulting   DellEMC Rebranding    10-Oct-2016   Remove additional block with duplicated ID in order to prevent AH errors- IB-->
                                <!--<fo:block>-->
                                <!--<xsl:call-template name="commonattributes"/>-->
                                <fo:block>
                                    <xsl:if test="@id != ''">
                                        <xsl:attribute name="id">
                                            <xsl:value-of select="concat(@id,'should_remain')"/>
                                        </xsl:attribute>
                                    </xsl:if>
                                    <!--Suite/EMC   SOW5  19-Feb-2012   label should be bold -->
                                    <fo:inline font-weight="bold">
                                        <xsl:call-template name="getVariable">
                                            <xsl:with-param name="id" select="'Figure Num'"/>
                                            <xsl:with-param name="params" as="node()">
                                                <number>
                                                    <xsl:number level="any"
                                                                count="*[contains(@class, ' topic/fig ')][child::*[contains(@class, ' topic/title ')]]"
                                                                from="/"/>
                                                </number>
                                            </xsl:with-param>
                                        </xsl:call-template>
                                    </fo:inline>
                                    <xsl:text>&#xA0;</xsl:text>
                                    <xsl:apply-templates select="*[contains(@class,' topic/title ')]"/>
                                    <fo:retrieve-table-marker retrieve-class-name="continued"/>
                                </fo:block>
                                <!--</fo:block>-->
                            </fo:table-cell>
                        </fo:table-row>
                    </fo:table-header>
                </xsl:if>
                <fo:table-body>
                    <fo:table-row>
                        <!-- Suite Dec-2011: create figure in a variable to insert either in last cell (default behavior)
                        or in one cell spanning all columns (for pagewide figures) -rs -->
                        <!-- Suite/EMC   SOW7  10-Mar-2013   add attribute-set to figure blocks - rs -->
                        <xsl:variable name="figure">
                            <fo:block xsl:use-attribute-sets="fig fig__block">
                                <fo:table>
                                    <fo:table-body>
                                        <xsl:apply-templates select="*[not(contains(@class,' topic/title '))]"
                                                             mode="from-fig-or-example"/>
                                    </fo:table-body>
                                </fo:table>
                            </fo:block>
                        </xsl:variable>
                        <xsl:choose>
                            <!--Suite/EMC   SOW5  18-Mar-2012   remove margin from landsapce figures - ck-->
                            <xsl:when
                                    test="@expanse='page' or contains(@outputclass,'pagewide') or (contains(@outputclass, 'landscape') and parent::*[contains(@class,' topic/body ')])">
                                <fo:table-cell number-columns-spanned="4">
                                    <fo:block-container width="{$page-width-without-margins}">
                                        <xsl:copy-of select="$figure"/>
                                    </fo:block-container>
                                </fo:table-cell>
                            </xsl:when>
                            <xsl:otherwise>
                                <fo:table-cell>
                                    <fo:block/>
                                </fo:table-cell>
                                <fo:table-cell>
                                    <fo:block/>
                                </fo:table-cell>
                                <fo:table-cell>
                                    <fo:block/>
                                </fo:table-cell>
                                <fo:table-cell>
                                    <xsl:copy-of select="$figure"/>
                                </fo:table-cell>
                            </xsl:otherwise>
                        </xsl:choose>
                    </fo:table-row>
                </fo:table-body>
            </fo:table>
        </fo:block>
    </xsl:template>

    <!--<!{1}**figure title **{1}>-->
    <xsl:template match="*[contains(@class,' topic/fig ')]/*[contains(@class,' topic/title ')]">
        <fo:inline>
            <xsl:call-template name="commonattributes"/>
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>

    <!--mckimn 14-Sep-2016: Do not display titlealts in draft output  -->
    <xsl:template match="*[contains(@class,' topic/titlealts ')]">
        <!--<xsl:if test="$DRAFT='yes'">
            <xsl:if test="*">
              <fo:block xsl:use-attribute-sets="titlealts">
                <xsl:call-template name="commonattributes"/>
                <xsl:apply-templates/>
              </fo:block>
            </xsl:if>
          </xsl:if>-->
    </xsl:template>

    <xsl:template match="*" mode="processTopicTitle">
        <xsl:variable name="levelTemp" as="xs:integer">
            <xsl:apply-templates select="." mode="get-topic-level"/>
        </xsl:variable>
        <xsl:variable name="level">
            <xsl:choose>
                <xsl:when
                        test="$levelTemp > 7 and preceding::*[@id=@id]/ancestor::*[contains(@class,' bookmap/part ')]">
                    <xsl:value-of select="6"/>
                </xsl:when>
                <xsl:when test="preceding::*[@id=@id]/ancestor::*[contains(@class,' bookmap/part ')]">
                    <xsl:value-of select="$levelTemp"/>
                </xsl:when>
                <xsl:when
                        test="$levelTemp > 6 and not(preceding::*[@id=@id]/ancestor::*[contains(@class,' bookmap/part ')])">
                    <xsl:value-of select="6"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$levelTemp"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="attrSet1">
            <xsl:apply-templates select="." mode="createTopicAttrsName">
                <xsl:with-param name="theCounter" select="$level"/>
            </xsl:apply-templates>
        </xsl:variable>
        <xsl:variable name="attrSet2" select="concat($attrSet1, '__content')"/>
        <fo:block>

            <xsl:call-template name="commonattributes"/>
            <xsl:call-template name="processAttrSetReflection">
                <xsl:with-param name="attrSet" select="$attrSet1"/>
                <xsl:with-param name="path" select="'../../cfg/fo/attrs/commons-attr.xsl'"/>
            </xsl:call-template>
            <!-- Add topic metadata to PDF, call pubmeta template before every topic title-->
            <xsl:if test="lower-case($INCLUDEMETADATA) = 'yes'">
                <fo:block font-size="10pt">
                    <xsl:call-template name="pubmeta"/>
                </fo:block>
            </xsl:if>
            <fo:block>
				<!-- Dimitri: Render topic titles in blue color. -->
				<xsl:attribute name="color"><xsl:value-of select="$dell_blue"/></xsl:attribute>
                <xsl:call-template name="processAttrSetReflection">
                    <xsl:with-param name="attrSet" select="$attrSet2"/>
                    <xsl:with-param name="path" select="'../../cfg/fo/attrs/commons-attr.xsl'"/>
                </xsl:call-template>

                <xsl:if test="$level = 1">
                    <fo:marker marker-class-name="current-header">
                        <xsl:apply-templates select="." mode="getTitle">
                            <xsl:with-param name="change-markup">no</xsl:with-param>
                        </xsl:apply-templates>
                    </fo:marker>
                </xsl:if>
                <xsl:if test="$level = 2">
                    <fo:marker marker-class-name="current-h2">
                        <xsl:apply-templates select="." mode="getTitle">
                            <xsl:with-param name="change-markup">no</xsl:with-param>
                        </xsl:apply-templates>
                    </fo:marker>
                    <fo:marker marker-class-name="current-any-header">
                        <xsl:apply-templates select="." mode="getTitle">
                            <xsl:with-param name="change-markup">no</xsl:with-param>
                        </xsl:apply-templates>
                    </fo:marker>
                </xsl:if>
                <xsl:if test="$level = 3">
                    <fo:marker marker-class-name="current-any-header">
                        <xsl:apply-templates select="." mode="getTitle">
                            <xsl:with-param name="change-markup">no</xsl:with-param>
                        </xsl:apply-templates>
                    </fo:marker>
                </xsl:if>
                <fo:inline id="{parent::node()/@id}"/>
                <fo:inline>
                    <xsl:attribute name="id">
                        <xsl:call-template name="generate-toc-id">
                            <xsl:with-param name="element" select=".."/>
                        </xsl:call-template>
                    </xsl:attribute>
                </fo:inline>
                <xsl:call-template name="pullPrologIndexTerms"/>
                <xsl:apply-templates select="." mode="getTitle"/>
            </fo:block>
        </fo:block>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' bookmap/part ')]" mode="topicTitleNumber">
        <xsl:number format="1" count="*[contains(@class, ' bookmap/part ')]"/>
    </xsl:template>

    <!--  Bookmap Chapter processing  -->
    <xsl:template name="processTopicChapter">
        <xsl:variable name="gid" select="generate-id()"/>
        <xsl:variable name="topicref" select="$map//*[@id = @id]"/>
        <xsl:variable name="topicNumber"
                      select="count($topicNumbers/topic[@id = @id][following-sibling::topic[@guid = $gid]]) + 1"/>

        <!-- IA   Tridion upgrade    Mar-2019 IDPL-5477: Adapt 3 PDF output formats to support CPSD documenation.
                             Add specific '__force__page__count_chapter' attr-set for Chapter in order to dynamically
                             decide if it is required to start every chapter on even page.
                             Do this only for Chapters and ignore Glosaary, Index and Appendix.  - IB-->
        <fo:page-sequence master-reference="body-sequence" xsl:use-attribute-sets="__force__page__count_chapter">
            <xsl:call-template name="startPageNumbering"/>
            <xsl:call-template name="insertBodyStaticContents"/>
            <fo:flow flow-name="xsl-region-body">
                <!-- Suite Dec-2011: do not wrap entire chapter in block so psmi will work.  Instead, create a block with the id at the beginning. - rs -->
                <!-- IDPL-2700. added by Roopesh. Add topic metadata to PDF, call pubmeta template before every chapter title-->
                <xsl:if test="lower-case($INCLUDEMETADATA) = 'yes'">
                    <fo:block font-size="10pt">
                        <xsl:call-template name="pubmeta"/>
                    </fo:block>
                </xsl:if>
                <fo:block xsl:use-attribute-sets="topic">
                    <xsl:call-template name="commonattributes"/>

                    <xsl:variable name="levelTemp" as="xs:integer">
                        <xsl:apply-templates select="." mode="get-topic-level"/>
                    </xsl:variable>
                    <xsl:variable name="level" as="xs:integer">
                        <xsl:choose>
                            <xsl:when
                                    test="$levelTemp > 7 and preceding::*[@id=@id]/ancestor::*[contains(@class,' bookmap/part ')]">
                                <xsl:value-of select="6"/>
                            </xsl:when>
                            <xsl:when test="preceding::*[@id=@id]/ancestor::*[contains(@class,' bookmap/part ')]">
                                <xsl:value-of select="$levelTemp - 1"/>
                            </xsl:when>
                            <xsl:when
                                    test="$levelTemp > 6 and not(preceding::*[@id=@id]/ancestor::*[contains(@class,' bookmap/part ')])">
                                <xsl:value-of select="6"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$levelTemp"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>

                    <xsl:variable name="topicref"
                                  select="key('map-id', ancestor-or-self::*[contains(@class, ' topic/topic ')][1]/@id)"/>
                    <xsl:choose>
                        <xsl:when test="$level eq 1">
                            <fo:marker marker-class-name="current-topic-number">
                                <xsl:for-each select="$topicref">
                                    <xsl:apply-templates select="." mode="topicTitleNumber"/>
                                </xsl:for-each>
                            </fo:marker>
                            <fo:marker marker-class-name="current-header">
                                <xsl:for-each select="*[contains(@class,' topic/title ')]">
                                    <xsl:apply-templates select="." mode="getTitle">
                                        <xsl:with-param name="change-markup">no</xsl:with-param>
                                    </xsl:apply-templates>
                                </xsl:for-each>
                            </fo:marker>
                        </xsl:when>
                        <xsl:otherwise>
                            <fo:marker marker-class-name="current-topic-number">
                                <xsl:number format="1"/>
                            </fo:marker>
                            <fo:marker marker-class-name="current-header">
                                <!-- Suite Dec-2011: first use navtitle attribute if present, otherwise use title -->
                                <!-- Suite/EMC   SOW7   08-April-2013   navtitle should only overide title if locktitle = yes  - aw -->
                                <xsl:choose>
                                    <xsl:when test="@navtitle and  $topicref[position()=$topicNumber]/@locktitle='yes'">
                                        <xsl:apply-templates select="@navtitle"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:for-each select="child::*[contains(@class,' topic/title ')]">
                                            <!-- Suite/EMC   SOW7  07-Apr-2013   Add parameter to prevent change-markup in header/footer - rs -->
                                            <xsl:apply-templates select="." mode="getTitle">
                                                <xsl:with-param name="change-markup">no</xsl:with-param>
                                            </xsl:apply-templates>
                                        </xsl:for-each>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </fo:marker>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:apply-templates select="*[contains(@class,' topic/prolog ')]"/>
                </fo:block>

                <xsl:call-template name="insertChapterFirstpageStaticContent">
                    <xsl:with-param name="type" select="'chapter'"/>
                </xsl:call-template>

                <fo:block xsl:use-attribute-sets="topic.title">
                    <xsl:call-template name="pullPrologIndexTerms"/>
                    <xsl:for-each select="*[contains(@class,' topic/title ')]">
                        <xsl:apply-templates select="." mode="getTitle"/>
                    </xsl:for-each>
                </fo:block>
                <xsl:choose>
                    <xsl:when test="$chapterLayout='BASIC'">
                        <xsl:apply-templates select="*[not(contains(@class, ' topic/topic ') or contains(@class, ' topic/title ') or
                                            contains(@class, ' topic/prolog '))]"/>
                        <!--xsl:apply-templates select="." mode="buildRelationships"/-->
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="." mode="createMiniToc"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:apply-templates select="*[contains(@class,' topic/topic ')]"/>
                <xsl:call-template name="pullPrologIndexTerms.end-range"/>
            </fo:flow>
        </fo:page-sequence>
    </xsl:template>

    <!--  Bookmap Appendix processing  -->
    <xsl:template name="processTopicAppendix">
        <fo:page-sequence master-reference="body-sequence" xsl:use-attribute-sets="__force__page__count">
            <xsl:call-template name="startPageNumbering"/>
            <xsl:call-template name="insertBodyStaticContents"/>
            <fo:flow flow-name="xsl-region-body">
                <!-- Suite Dec-2011: do not wrap entire appendix in block so psmi will work.  Instead, create a block with the id at the beginning. - rs -->
                <fo:block xsl:use-attribute-sets="topic">
                    <xsl:call-template name="commonattributes"/>
                    <!-- Add topic metadata to PDF, call pubmeta template before every topic title-->
                    <xsl:if test="lower-case($INCLUDEMETADATA) = 'yes'">
                        <fo:block font-size="10pt">
                            <xsl:call-template name="pubmeta"/>
                        </fo:block>
                    </xsl:if>
                    <xsl:variable name="levelTemp" as="xs:integer">
                        <xsl:apply-templates select="." mode="get-topic-level"/>
                    </xsl:variable>
                    <xsl:variable name="level" as="xs:integer">
                        <xsl:choose>
                            <xsl:when
                                    test="$levelTemp > 7 and preceding::*[@id=@id]/ancestor::*[contains(@class,' bookmap/part ')]">
                                <xsl:value-of select="6"/>
                            </xsl:when>
                            <xsl:when test="preceding::*[@id=@id]/ancestor::*[contains(@class,' bookmap/part ')]">
                                <xsl:value-of select="$levelTemp - 1"/>
                            </xsl:when>
                            <xsl:when
                                    test="$levelTemp > 6 and not(preceding::*[@id=@id]/ancestor::*[contains(@class,' bookmap/part ')])">
                                <xsl:value-of select="6"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$levelTemp"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:if test="$level eq 1">
                        <fo:marker marker-class-name="current-topic-number">
                            <xsl:variable name="topicref"
                                          select="key('map-id', ancestor-or-self::*[contains(@class, ' topic/topic ')][1]/@id)"/>
                            <xsl:for-each select="$topicref">
                                <xsl:apply-templates select="." mode="topicTitleNumber"/>
                            </xsl:for-each>
                        </fo:marker>
                        <fo:marker marker-class-name="current-header">
                            <xsl:for-each select="*[contains(@class,' topic/title ')]">
                                <xsl:apply-templates select="." mode="getTitle">
                                    <xsl:with-param name="change-markup">no</xsl:with-param>
                                </xsl:apply-templates>
                            </xsl:for-each>
                        </fo:marker>
                    </xsl:if>
                    <xsl:apply-templates select="*[contains(@class,' topic/prolog ')]"/>
                </fo:block>

                <xsl:call-template name="insertChapterFirstpageStaticContent">
                    <xsl:with-param name="type" select="'appendix'"/>
                </xsl:call-template>

                <fo:block xsl:use-attribute-sets="topic.title">
                    <xsl:call-template name="pullPrologIndexTerms"/>
                    <xsl:for-each select="*[contains(@class,' topic/title ')]">
                        <xsl:apply-templates select="." mode="getTitle"/>
                    </xsl:for-each>
                </fo:block>
                <xsl:choose>
                    <xsl:when test="$chapterLayout='BASIC'">
                        <xsl:apply-templates select="*[not(contains(@class, ' topic/topic ') or contains(@class, ' topic/title ') or
              contains(@class, ' topic/prolog '))]"/>
                        <!--xsl:apply-templates select="." mode="buildRelationships"/-->
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="." mode="createMiniToc"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:apply-templates select="*[contains(@class,' topic/topic ')]"/>
                <xsl:call-template name="pullPrologIndexTerms.end-range"/>
            </fo:flow>
        </fo:page-sequence>
    </xsl:template>

    <!-- Suite/EMC Nochap 26-Aug-2012: Add template to process nochap chapter(s) - Start - AW -->
    <xsl:template name="processTopicChapterNochap">
        <fo:block>
            <xsl:attribute name="id">
                <xsl:call-template name="generate-toc-id"/>
            </xsl:attribute>
        </fo:block>
        <!-- Suite/EMC Nochap 21-Sep-2012: do not wrap entire chapter in block so psmi will work.
          Instead, create a block with the id at the beginning. - rs -->
        <fo:block>
            <xsl:call-template name="commonattributes"/>
        </fo:block>
        <xsl:apply-templates select="*[contains(@class,' topic/topic ')]"/>
    </xsl:template>

    <!-- Suite/EMC Nochap 26-Aug-2012: Add template to process nochap appendices - Start - AW -->
    <xsl:template name="processTopicAppendixNochap">
        <fo:block>
            <xsl:attribute name="id">
                <xsl:call-template name="generate-toc-id"/>
            </xsl:attribute>
        </fo:block>
        <!-- Suite/EMC Nochap 21-Sep-2012: do not wrap entire appendix in block so psmi will work.
          Instead, create a block with the id at the beginning. - rs -->
        <fo:block>
            <xsl:call-template name="commonattributes"/>
        </fo:block>
        <xsl:apply-templates select="*[contains(@class,' topic/topic ')]"/>
    </xsl:template>

    <!--  Bookmap Part processing  -->
    <xsl:template name="processTopicPart">
        <xsl:if test="ancestor::*[not(contains(@outputclass,'nochap'))]">
            <fo:page-sequence master-reference="body-sequence" xsl:use-attribute-sets="__force__page__count">
                <xsl:call-template name="startPageNumbering"/>
                <xsl:call-template name="insertBodyStaticContents"/>
                <fo:flow flow-name="xsl-region-body">
                    <fo:block xsl:use-attribute-sets="topic">
                        <xsl:call-template name="commonattributes"/>
                        <xsl:if test="empty(ancestor::*[contains(@class, ' topic/topic ')])">
                            <fo:marker marker-class-name="current-topic-number">
                                <xsl:variable name="topicref"
                                              select="key('map-id', ancestor-or-self::*[contains(@class, ' topic/topic ')][1]/@id)"/>
                                <xsl:for-each select="$topicref">
                                    <xsl:apply-templates select="." mode="topicTitleNumber"/>
                                </xsl:for-each>
                            </fo:marker>
                            <fo:marker marker-class-name="current-header">
                                <xsl:for-each select="*[contains(@class,' topic/title ')]">
                                    <xsl:apply-templates select="." mode="getTitle"/>
                                </xsl:for-each>
                            </fo:marker>
                        </xsl:if>

                        <xsl:apply-templates select="*[contains(@class,' topic/prolog ')]"/>

                        <xsl:call-template name="insertChapterFirstpageStaticContent">
                            <xsl:with-param name="type" select="'part'"/>
                        </xsl:call-template>

                        <fo:block xsl:use-attribute-sets="topic.title">
                            <xsl:call-template name="pullPrologIndexTerms"/>
                            <xsl:for-each select="*[contains(@class,' topic/title ')]">
                                <xsl:apply-templates select="." mode="getTitle"/>
                            </xsl:for-each>
                        </fo:block>

                        <xsl:choose>
                            <xsl:when test="$partLayout='BASIC'">
                                <xsl:apply-templates select="*[not(contains(@class, ' topic/topic ') or contains(@class, ' topic/title ') or
                  contains(@class, ' topic/prolog '))]"/>
                                <!--xsl:apply-templates select="." mode="buildRelationships"/-->
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="." mode="createMiniToc"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:for-each select="*[contains(@class,' topic/topic ')]">
                            <xsl:variable name="topicType" as="xs:string">
                                <xsl:call-template name="determineTopicType"/>
                            </xsl:variable>
                            <xsl:if test="$topicType = 'topicSimple'">
                                <xsl:apply-templates select="."/>
                            </xsl:if>
                        </xsl:for-each>
                        <xsl:call-template name="pullPrologIndexTerms.end-range"/>
                    </fo:block>
                </fo:flow>
            </fo:page-sequence>
        </xsl:if>
        <xsl:for-each select="*[contains(@class,' topic/topic ')]">
            <xsl:variable name="topicType" as="xs:string">
                <xsl:call-template name="determineTopicType"/>
            </xsl:variable>
            <xsl:if test="not($topicType = 'topicSimple')">
                <xsl:apply-templates select="."/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <!-- Suite/EMC Nochap 26-Aug-2012: add <part> processing template - Start - AW -->
    <!-- Balaji Mani 28-Mar-2013: Remove page number for the Part and commented for nochap -->
    <xsl:template name="processTopicPartNochap">
        <xsl:for-each select="*[contains(@class,' topic/topic ')]">
            <xsl:variable name="topicType">
                <xsl:call-template name="determineTopicType"/>
            </xsl:variable>
            <xsl:if test="not($topicType = 'topicSimple')">
                <xsl:apply-templates select="."/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <!--Suite/EMC Nochap 26-Aug-2012: make sure a page-seq is not created for nochap - START - ck-->
    <xsl:template match="*" mode="processUnknowTopic"
                  name="processTopicSimple">
        <xsl:param name="topicType"/>
        <xsl:variable name="page-sequence-reference"
                      select="if ($mapType = 'bookmap') then 'body-sequence' else 'ditamap-body-sequence'"/>
        <xsl:choose>
            <xsl:when
                    test="empty(ancestor::*[contains(@class,' topic/topic ')]) and empty(ancestor::ot-placeholder:glossarylist) and $NOCHAP = 'no'">
                <fo:page-sequence master-reference="{$page-sequence-reference}"
                                  xsl:use-attribute-sets="__force__page__count">
                    <xsl:call-template name="startPageNumbering"/>
                    <xsl:call-template name="insertBodyStaticContents"/>
                    <fo:flow flow-name="xsl-region-body">
                        <xsl:apply-templates select="." mode="processTopic"/>
                    </fo:flow>
                </fo:page-sequence>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="." mode="processTopic"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--If example has title - wraps example in table and inserts recurring caption - rs-->
    <xsl:template match="*[contains(@class,' topic/example ')]">
        <fo:block float="left" start-indent="0in">
            <fo:table width="{$page-width-without-margins}">
                <fo:table-column column-width="{$side-col-1}"/>
                <fo:table-column column-width="{$side-col-2}"/>

                <!-- if example is inside list, indent more to align with text-->
                <xsl:variable name="list-ancestor-count"
                              select="count(ancestor::*[contains(@class,' topic/ol ') or contains(@class,' topic/ul ')])"/>
                <xsl:variable name="column-width">
                    <xsl:choose>
                        <xsl:when test="$list-ancestor-count=0">0</xsl:when>
                        <xsl:when test="$list-ancestor-count=1">
                            <xsl:value-of select="$list-item-indent"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of
                                    select="$list-item-indent + ($list-ancestor-count*$sublist-item-indent) "/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>

                <fo:table-column>
                    <xsl:attribute name="column-width">
                        <xsl:value-of select="$column-width"/>
                        <xsl:text>in</xsl:text>
                    </xsl:attribute>
                </fo:table-column>

                <fo:table-column>
                    <xsl:attribute name="column-width">
                        <xsl:value-of select="$main-col"/>
                        <xsl:text>in</xsl:text>
                    </xsl:attribute>
                </fo:table-column>

                <xsl:if test="*[contains(@class,' topic/title ')]">
                    <fo:table-header>
                        <fo:table-row>
                            <!--Suite/EMC   SOW5  16-Feb-2012   fix example title spacing START - ck-->
                            <fo:table-cell/>
                            <fo:table-cell/>
                            <fo:table-cell/>
                            <fo:table-cell xsl:use-attribute-sets="example.title">
                                <fo:block id="{@id}">
                                    <fo:block>
                                        <xsl:if test="@id != ''">
                                            <xsl:attribute name="id">
                                                <xsl:value-of select="concat(@id,'should_remain')"/>
                                            </xsl:attribute>
                                        </xsl:if>
                                        <!--Suite/EMC   SOW5  19-Feb-2012   label should be bold - ck-->
                                        <xsl:choose>
                                            <!-- IA   Tridion upgrade    Oct-2018   Add support for DELL othermeta parameters.
                                                Do not add task labels ONLY if 'task-labels' <othermeta> value equal 'no'.  - IB-->
                                            <xsl:when test="parent::*[contains(@class, ' task/taskbody ')] and $generate-task-labels = false()"/>
                                            <xsl:otherwise>
                                                <fo:inline font-weight="bold">
                                                    <xsl:call-template name="getVariable">
                                                        <xsl:with-param name="id" select="'Example'"/>
                                                        <xsl:with-param name="params" as="element()*">
                                                            <number>
                                                                <xsl:number level="any"
                                                                            count="*[contains(@class, ' topic/example ')][child::*[contains(@class, ' topic/title ')]]"
                                                                            from="/"/>
                                                            </number>
                                                        </xsl:with-param>
                                                    </xsl:call-template>
                                                </fo:inline>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        <xsl:text>&#xA0;</xsl:text>
                                        <xsl:apply-templates select="*[contains(@class,' topic/title ')]"/>
                                        <fo:retrieve-table-marker retrieve-class-name="continued"/>
                                    </fo:block>
                                </fo:block>
                            </fo:table-cell>
                        </fo:table-row>
                    </fo:table-header>
                </xsl:if>

                <fo:table-body>
                    <fo:table-row>
                        <fo:table-cell>
                            <fo:block/>
                        </fo:table-cell>
                        <fo:table-cell>
                            <fo:block/>
                        </fo:table-cell>
                        <fo:table-cell>
                            <fo:block/>
                        </fo:table-cell>
                        <fo:table-cell>
                            <fo:block xsl:use-attribute-sets="example">
                                <fo:table>
                                    <fo:table-body>
                                        <!-- Suite/EMC   SOW7    19-Feb-2013   Prevent right margin overflow - rs -->
                                        <!-- EMC  28-Oct-2013  IB3  Issue 291: Text within <example> does not appear in PDF  -->
                                        <xsl:apply-templates select="*[not(contains(@class,' topic/title '))] | text()"
                                                             mode="from-fig-or-example">
                                            <!-- send tunnel parameter parent=example so that child fig/table elements can deduct margins/width accordingly - rs -->
                                            <xsl:with-param name="parent" tunnel="yes">example</xsl:with-param>
                                        </xsl:apply-templates>
                                    </fo:table-body>
                                </fo:table>
                            </fo:block>
                        </fo:table-cell>
                    </fo:table-row>
                </fo:table-body>
            </fo:table>
        </fo:block>
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/example ')]/*[contains(@class,' topic/title ')]">
        <xsl:apply-templates/>
    </xsl:template>

    <!-- Suite Dec-2011: match children of figures or examples with special mode,
      insert table row and cell with marker to determine which page of parent element is on, then apply default templates.
      This enables continuation numbering for examples and figures.
      NOTE: This requires figures and examples to include id attributes and values. - rs  -->
    <!-- EMC  28-Oct-2013  IB3  Issue 291: Text within <example> does not appear in PDF  -->
    <xsl:template match="* | text()" mode="from-fig-or-example">
        <xsl:variable name="id">
            <xsl:choose>
                <xsl:when test="@id">
                    <xsl:value-of select="concat('cell-',@id,'should_remain')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat('cell-',generate-id(),'should_remain')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="self::*">
                <!-- If this is the first child element immediately following the title, insert an extra, empty marker so first page will not have continuation notation - rs -->
                <xsl:if test="preceding-sibling::*[1][contains(@class,' topic/title ')]">
                    <fo:table-row>
                        <fo:table-cell>
                            <fo:marker marker-class-name="continued"/>
                        </fo:table-cell>
                    </fo:table-row>
                </xsl:if>
                <!-- Insert marker preceding the element, noting the first page this element appears on - rs -->
                <fo:table-row keep-with-next.within-page="always">
                    <fo:table-cell>
                        <fo:marker marker-class-name="continued">
                            <fo:inline>
                                <xsl:call-template name="getVariable">
                                    <xsl:with-param name="id" select="'Continued'"/>
                                </xsl:call-template>
                            </fo:inline>
                        </fo:marker>
                    </fo:table-cell>
                </fo:table-row>
            </xsl:when>
        </xsl:choose>
        <!-- Insert the element itself, in its own table row -->
        <fo:table-row>
            <!-- EMC  15-Apr-14  IB4  #403 - Text bleeds margin in <example> with <fig>-->
            <fo:table-cell xsl:use-attribute-sets="__from__fig__or__example__width">
                <xsl:attribute name="id">
                    <xsl:value-of select="$id"/>
                </xsl:attribute>
                <!-- EMC  14-May-2014  IB4  #406 - Too little space between block-level elements in task examples -->
                <xsl:choose>
                    <xsl:when test="text()">
                        <fo:block xsl:use-attribute-sets="example.sub.element.text">
                            <xsl:apply-templates select="."/>
                        </fo:block>
                    </xsl:when>
                    <xsl:otherwise>
                        <fo:block xsl:use-attribute-sets="example.sub.element">
                            <xsl:apply-templates select="."/>
                        </fo:block>
                    </xsl:otherwise>
                </xsl:choose>
            </fo:table-cell>
        </fo:table-row>
        <xsl:choose>
            <xsl:when test="self::*">
                <fo:table-row keep-with-previous.within-page="always">
                    <fo:table-cell>
                        <fo:marker marker-class-name="continued">
                            <fo:inline>
                                <xsl:call-template name="getVariable">
                                    <xsl:with-param name="id" select="'Continued'"/>
                                </xsl:call-template>
                            </fo:inline>
                        </fo:marker>
                    </fo:table-cell>
                </fo:table-row>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/lq ')]">
        <fo:block>
            <xsl:call-template name="commonattributes"/>
            <xsl:choose>
                <xsl:when test="@href or @reftitle">
                    <xsl:call-template name="processAttrSetReflection">
                        <xsl:with-param name="attrSet" select="'lq'"/>
                        <xsl:with-param name="path" select="'../../cfg/fo/attrs/commons-attr.xsl'"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="processAttrSetReflection">
                        <xsl:with-param name="attrSet" select="'lq_simple'"/>
                        <xsl:with-param name="path" select="'../../cfg/fo/attrs/commons-attr.xsl'"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'lq-open'"/>
            </xsl:call-template>
            <xsl:apply-templates/>
            <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'lq-close'"/>
            </xsl:call-template>
        </fo:block>
        <xsl:choose>
            <xsl:when test="@href">
                <fo:block xsl:use-attribute-sets="lq_link">
                    <fo:basic-link>
                        <xsl:call-template name="buildBasicLinkDestination">
                            <xsl:with-param name="scope" select="@scope"/>
                            <xsl:with-param name="format" select="@format"/>
                            <xsl:with-param name="href" select="@href"/>
                        </xsl:call-template>
                        <xsl:choose>
                            <xsl:when test="@reftitle">
                                <xsl:value-of select="@reftitle"/>
                            </xsl:when>
                            <xsl:when test="not(@type = 'external' or @format = 'html')">
                                <xsl:apply-templates select="." mode="insertReferenceTitle">
                                    <xsl:with-param name="href" select="@href"/>
                                    <xsl:with-param name="titlePrefix" select="''"/>
                                </xsl:apply-templates>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="@href"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </fo:basic-link>
                </fo:block>
            </xsl:when>
            <xsl:when test="@reftitle">
                <fo:block xsl:use-attribute-sets="lq_title">
                    <xsl:value-of select="@reftitle"/>
                </fo:block>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/q ')]">
        <fo:inline xsl:use-attribute-sets="q">
            <xsl:call-template name="commonattributes"/>
            <!--Suite/EMC   SOW6  14-Mar-2012   Quotations alternative - ck-->
            <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'q-begin'"/>
            </xsl:call-template>
            <xsl:apply-templates/>
            <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'q-end'"/>
            </xsl:call-template>
        </fo:inline>
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/cite ')]">
        <fo:inline xsl:use-attribute-sets="cite">
            <xsl:call-template name="commonattributes"/>
            <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'start-cite'"/>
            </xsl:call-template>
            <xsl:apply-templates/>
            <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'end-cite'"/>
            </xsl:call-template>
        </fo:inline>
    </xsl:template>

    <!-- EMC		IB8		05-Oct-2015		TKT 165: "term" should be surrounded with prefix/suffix for L10N -->
    <xsl:template match="*[contains(@class,' topic/term ')]" name="topic.term">
        <xsl:param name="keys" select="@keyref" as="attribute()?"/>
        <xsl:param name="contents" as="node()*">
            <xsl:variable name="target" select="key('id', substring(@href, 2))"/>
            <xsl:choose>
                <xsl:when
                        test="not(normalize-space(.)) and $keys and $target/self::*[contains(@class,' topic/topic ')]">
                    <xsl:apply-templates select="$target/*[contains(@class, ' topic/title ')]/node()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:param>
        <xsl:variable name="topicref" select="key('map-id', substring(@href, 2))"/>
        <xsl:choose>
            <xsl:when
                    test="$keys and @href and not($topicref/ancestor-or-self::*[@linking][1]/@linking = ('none', 'sourceonly'))">
                <fo:basic-link xsl:use-attribute-sets="xref term">
                    <xsl:call-template name="commonattributes"/>
                    <xsl:call-template name="buildBasicLinkDestination"/>
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'start-term'"/>
                    </xsl:call-template>
                    <xsl:copy-of select="$contents"/>
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'end-term'"/>
                    </xsl:call-template>
                </fo:basic-link>
            </xsl:when>
            <xsl:otherwise>
                <fo:inline xsl:use-attribute-sets="term">
                    <xsl:call-template name="commonattributes"/>
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'start-term'"/>
                    </xsl:call-template>
                    <xsl:copy-of select="$contents"/>
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'end-term'"/>
                    </xsl:call-template>
                </fo:inline>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Suite/EMC  SOW7x  13-Aug-2013  Mantis #9040
         Deleted topics are not being picked up by change tracking code, as the processing instructions do not get passed into the merged file for topic references.
         Call change tracking code here, only for checking deleted topics.
         Note:  we did not add support for retaining nested topics if only parent topic deleted.  - LB -->
    <xsl:template match="*" mode="commonTopicProcessing">
        <xsl:call-template name="add.changebars">
            <xsl:with-param name="node" select="."/>
            <xsl:with-param name="type" select="'begin'"/>
            <xsl:with-param name="language">
                <xsl:call-template name="get.current.language"/>
            </xsl:with-param>
            <xsl:with-param name="placement" select="'break'"/>
        </xsl:call-template>
        <xsl:if test="empty(ancestor::*[contains(@class, ' topic/topic ')])">
            <fo:marker marker-class-name="current-topic-number">
                <xsl:variable name="topicref"
                              select="key('map-id', ancestor-or-self::*[contains(@class, ' topic/topic ')][1]/@id)"/>
                <xsl:for-each select="$topicref">
                    <xsl:apply-templates select="." mode="topicTitleNumber"/>
                </xsl:for-each>
            </fo:marker>
        </xsl:if>
        <xsl:apply-templates select="*[contains(@class, ' topic/title ')]"/>
        <xsl:if test="$insert-topic-guid and normalize-space(@oid)">
            <!-- IA   Tridion upgrade    Oct-2018   Add topic GUID below title if required property set. - IB-->
            <fo:block xsl:use-attribute-sets="topic_guid">
                <xsl:value-of select="@oid"/>
            </fo:block>
        </xsl:if>
        <xsl:apply-templates select="*[contains(@class, ' topic/prolog ')]"/>
        <xsl:apply-templates select="*[not(contains(@class, ' topic/title ')) and
      not(contains(@class, ' topic/prolog ')) and
      not(contains(@class, ' topic/topic '))]"/>
        <!--xsl:apply-templates select="." mode="buildRelationships"/-->
        <xsl:apply-templates select="*[contains(@class,' topic/topic ')]"/>
        <xsl:apply-templates select="." mode="topicEpilog"/>
        <xsl:call-template name="add.changebars">
            <xsl:with-param name="node" select="."/>
            <xsl:with-param name="type" select="'end'"/>
            <xsl:with-param name="language">
                <xsl:call-template name="get.current.language"/>
            </xsl:with-param>
            <xsl:with-param name="placement" select="'break'"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/topic ')]">
        <xsl:variable name="topicType" as="xs:string">
            <xsl:call-template name="determineTopicType"/>
        </xsl:variable>

        <xsl:choose>
            <!-- EMC		IB4		08-May-2014		Glossary map can be specified in glossarylist @href -->
            <xsl:when test="$topicType = 'topicGlossaryList'"/>
            <xsl:when test="$topicType = 'topicChapter'">
                <xsl:choose>
                    <xsl:when test="$NOCHAP = 'yes'">
                        <xsl:call-template name="processTopicChapterNochap"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="processTopicChapter"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$topicType = 'topicAppendix'">
                <xsl:choose>
                    <xsl:when test="$NOCHAP = 'yes'">
                        <xsl:call-template name="processTopicAppendixNochap"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="processTopicAppendix"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$topicType = 'topicAppendices'">
                <xsl:if test="$NOCHAP = 'no'">
                    <xsl:call-template name="processTopicAppendices"/>
                </xsl:if>
            </xsl:when>
            <xsl:when test="$topicType = 'topicPart'">
                <xsl:choose>
                    <xsl:when test="$NOCHAP = 'yes'">
                        <xsl:call-template name="processTopicPartNochap"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="processTopicPart"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$topicType = 'topicPreface'">
                <xsl:if test="$NOCHAP = 'no'">
                    <xsl:call-template name="processTopicPreface"/>
                </xsl:if>
            </xsl:when>
            <xsl:when test="$topicType = 'topicNotices'">
                <xsl:if test="$retain-bookmap-order">
                    <xsl:call-template name="processTopicNotices"/>
                </xsl:if>
            </xsl:when>
            <xsl:when test="$topicType = 'topicTocList'">
                <xsl:call-template name="processTocList"/>
            </xsl:when>
            <xsl:when test="$topicType = 'topicIndexList'">
                <xsl:call-template name="processIndexList"/>
            </xsl:when>
            <xsl:when test="$topicType = 'topicSimple'">
                <xsl:call-template name="processTopicSimple"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="." mode="processUnknowTopic">
                    <xsl:with-param name="topicType" select="$topicType"/>
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Suite Dec-2011: remove wrapper block from all topic types for psmi - rs -->
    <xsl:template match="*" mode="processTopic">
        <xsl:apply-templates select="." mode="commonTopicProcessing"/>
    </xsl:template>

    <!-- Suite/EMC  07-Apr-2013   exclude change-markup when specified BEGIN -->
    <xsl:template match="*" mode="getTitle">
        <xsl:param name="change-markup">yes</xsl:param>
        <xsl:choose>
            <!--             add keycol here once implemented-->
            <xsl:when test="@spectitle">
                <xsl:value-of select="@spectitle"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$change-markup = 'no'">
                        <xsl:apply-templates select="* | text()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Suite Dec-2011: If body contains a descendant with outputclass=landscape, do not create fo:block around body.
    Instead, apply-templates with tunnelled param so each child without the outputclass, and without a descendant with outputclass
    will be wrapped in its own "body" fo:block.
    "body" attribute-set can be used for all level topics as body, body__toplevel, and body__secondLevel are all identical. -->
    <!-- this is the fallthrough body for nested topics -->
    <xsl:template match="*[contains(@class,' topic/body ')]">
        <xsl:variable name="level" as="xs:integer">
            <xsl:apply-templates select="." mode="get-topic-level"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="descendant::*[contains(@outputclass,'landscape')]">
                <xsl:apply-templates>
                    <xsl:with-param name="body-block" tunnel="yes">yes</xsl:with-param>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <fo:block xsl:use-attribute-sets="body">
                    <xsl:apply-templates/>
                </fo:block>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Suite Dec-2011: Matches any element in order to catch all elements which could not have the body/section attribute-set applied to their parent or ancestor.
    If the element itself has outputclass=landscape, simply apply-templates on itself with next-match.
    If the element has descendants with outputclass=landscape, apply template recursively on all its children.
    If the element has no descendants with outputclass=landscape, test tunnelled parameter values:
    Parameters:
      body-block: default=no; value of yes indicates element should be wrapped in fo:block with body attribute-set
      section-block: default=no; value of yes indicates element should be preceded with section block and wrapped in section__child block.
    Element is then re-processed with negative value (which sends it to the same template recursively, and is necessary in order to negate the tunnelling value).
    When all values are set to no, apply-templates on itself with next-match. - rs -->

    <xsl:template match="*" priority="20">
        <xsl:param name="body-block" tunnel="yes">no</xsl:param>
        <xsl:param name="section-block" tunnel="yes">no</xsl:param>

        <xsl:choose>
            <xsl:when
                    test="contains(@outputclass,'landscape') or ancestor::*[contains(@outputclass,'landscape')]">
                <xsl:next-match/>
            </xsl:when>
            <xsl:when test="$body-block = 'yes'">
                <fo:block xsl:use-attribute-sets="body">
                    <xsl:apply-templates select=".">
                        <xsl:with-param name="body-block" tunnel="yes">no</xsl:with-param>
                    </xsl:apply-templates>
                </fo:block>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Suite Nov-2011: force page break before element with outputclass=pagebreak -->
    <!-- EMC  IB4    25-Mar-2014  388/fix nopagebreak processing for list-items and steps -->
    <!-- EMC  IB4    02-Apr-2014  Ignore nopagebreak/pagebreak processing for table elements -->
    <xsl:template match="*[@outputclass='pagebreak'][count(ancestor-or-self::*[contains(@class, 'table')]) = 0]"
                  priority="9">
        <!-- Suite/EMC   SOW5    19-Mar-2013   fix pagebreak processing for list-items and steps - rs -->
        <xsl:choose>
            <xsl:when test="contains(@class,' topic/li ')">
                <xsl:next-match>
                    <xsl:with-param name="pagebreak" tunnel="yes">yes</xsl:with-param>
                </xsl:next-match>
            </xsl:when>
            <xsl:otherwise>
                <fo:block break-before="page">
                    <xsl:next-match/>
                </fo:block>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Suite Nov-2011: keep entire element on one page (unless content exceeds length of page) for element with outputclass=nopagebreak -->
    <!-- EMC  IB4    25-Mar-2014  388/fix nopagebreak processing for list-items and steps -->
    <!-- EMC  IB4    02-Apr-2014  Ignore nopagebreak/pagebreak processing for table elements -->
    <xsl:template
            match="*[contains(@outputclass,'nopagebreak')][count(ancestor-or-self::*[contains(@class, 'table')]) = 0]"
            priority="9">
        <xsl:choose>
            <xsl:when test="contains(@class,' topic/li ')">
                <xsl:next-match>
                    <xsl:with-param name="pagebreak" tunnel="yes">nopagebreak</xsl:with-param>
                </xsl:next-match>
            </xsl:when>
            <xsl:otherwise>
                <fo:block keep-together.within-page="5">
                    <xsl:next-match/>
                </fo:block>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Balaji Mani 18-June-2013: remove space after the colon and full stop in Chinese -->
    <xsl:template match="text()[contains(translate($locale,'ZHCN','zhcn'),'cn')]" priority="20">
        <xsl:variable name="removeFullstopSpace">
            <xsl:call-template name="removePunchSpace">
                <xsl:with-param name="text" select="."/>
                <xsl:with-param name="punch" select="'.'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="removeCNFullstopSpace">
            <xsl:call-template name="removePunchSpace">
                <xsl:with-param name="text" select="$removeFullstopSpace"/>
                <xsl:with-param name="punch" select="'。'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="removeCNColonSpace">
            <xsl:call-template name="removePunchSpace">
                <xsl:with-param name="text" select="$removeCNFullstopSpace"/>
                <xsl:with-param name="punch" select="'：'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="removeColonSpace">
            <xsl:call-template name="removePunchSpace">
                <xsl:with-param name="text" select="$removeCNColonSpace"/>
                <xsl:with-param name="punch" select="':'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="$removeColonSpace"/>
    </xsl:template>

    <xsl:template name="removePunchSpace">
        <xsl:param name="text"/>
        <xsl:param name="punch"/>
        <xsl:choose>
            <xsl:when test="starts-with($text,' ') and ends-with(preceding-sibling::*[1],$punch)">
                <xsl:choose>
                    <xsl:when test="contains(substring-after($text,' '),concat($punch,' '))">
                        <xsl:call-template name="removePunchSpace">
                            <xsl:with-param name="text" select="substring-after($text,' ')"/>
                            <xsl:with-param name="punch" select="$punch"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring-after($text,' ')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="contains($text,concat($punch,' '))">
                        <xsl:value-of select="concat(substring-before($text,concat($punch,' ')),$punch)"/>
                        <xsl:choose>
                            <xsl:when test="contains(substring-after($text,' '),concat($punch,' '))">
                                <xsl:call-template name="removePunchSpace">
                                    <xsl:with-param name="text" select="substring-after($text,concat($punch,' '))"/>
                                    <xsl:with-param name="punch" select="$punch"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="substring-after($text,concat($punch,' '))"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$text"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/draft-comment ')]">
        <!--<xsl:if test="not(lower-case($BETA) = 'yes') and (lower-case($show-comments) = 'yes')">-->
        <!-- Sep 2019   IDPL-8259: Enable Draft comments publishing for PDF Beta.   IA -->
        <xsl:if test="lower-case($show-comments) = 'yes'">
            <fo:block xsl:use-attribute-sets="draft-comment">
                <!--<xsl:call-template name="commonattributes"/>-->
                <fo:inline xsl:use-attribute-sets="draft-comment__label">
                    <xsl:text>Draft comment: </xsl:text>
                </fo:inline>
                <xsl:apply-templates/>
            </fo:block>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
