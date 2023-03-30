<?xml version='1.0'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:opentopic="http://www.idiominc.com/opentopic"
    xmlns:opentopic-func="http://www.idiominc.com/opentopic/exsl/function"
    xmlns:opentopic-index="http://www.idiominc.com/opentopic/index"
    xmlns:ot-placeholder="http://suite-sol.com/namespaces/ot-placeholder"
    exclude-result-prefixes="xs opentopic opentopic-func ot-placeholder opentopic-index"
    version="2.0">

    <!-- 
    Revision History
    ================
    Suite/EMC   SOW5  07-Feb-2012   Move toc header to static content
    Suite/EMC   SOW7  07-Apr-2013   Prevent change-markup in TOC
  	Balaji Mani       16-July-2013  For part upto 4 level processing
  	EMC 		IB4	  15-Apr-2014	#387 - LOF should be before LOT in bookmap template
	EMC			IB4	  18-Apr-2014	Glossary map can be specified in glossarylist @href
  -->

    <xsl:template name="createTocHeader">
        <fo:block xsl:use-attribute-sets="__toc__header" id="{$id.toc}"/>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/topic ')]" mode="toc">
        <xsl:param name="include"/>
        <xsl:variable name="topicType">
            <xsl:call-template name="determineTopicType"/>
        </xsl:variable>
        <xsl:variable name="topicLevel" as="xs:integer">
            <xsl:apply-templates select="." mode="get-topic-level"/>
        </xsl:variable>
        <xsl:if test="$topicLevel &lt; $tocMaximumLevel">
            <xsl:variable name="mapTopicref" select="key('map-id', @id)[1]"/>
            <xsl:choose>
                <!-- In a future version, suppressing Notices in the TOC should not be hard-coded. -->
                <xsl:when test="$retain-bookmap-order and $mapTopicref/self::*[contains(@class, ' bookmap/notices ')]"/>
                <xsl:when test="$mapTopicref[@toc = 'yes' or not(@toc)] or (not($mapTopicref) and $include = 'true')">
                    <xsl:choose>
                        <xsl:when test="$topicLevel = 1 or $mapTopicref/self::*[contains(@class, ' bookmap/part ')]">
                            <fo:block xsl:use-attribute-sets="__toc__toplevel">
                                <xsl:variable name="tocItemContent">
                                    <fo:float float="left" start-indent="0pt" xsl:use-attribute-sets="__toc__topic__content">
                                        <fo:block-container xsl:use-attribute-sets="__toc__heading">
                                            <fo:block xsl:use-attribute-sets="__toc__heading__block">
                                                <xsl:apply-templates select="$mapTopicref" mode="tocPrefix"/>
                                            </fo:block>
                                        </fo:block-container>
                                    </fo:float>
                                    <fo:block xsl:use-attribute-sets="__toc__topic__content">
                                        <fo:basic-link xsl:use-attribute-sets="__toc__link">
                                            <xsl:attribute name="internal-destination">
                                                <xsl:call-template name="generate-toc-id"/>
                                            </xsl:attribute>
											<!-- Dimitri: Set top-level (<chapter>) TOC entries flush left. -->
                                            <!--fo:block xsl:use-attribute-sets="__toc__page-number" margin-left="60mm"-->
											<fo:block xsl:use-attribute-sets="__toc__page-number" margin-left="0in">
                                                <fo:inline xsl:use-attribute-sets="__toc__title">
                                                    <!-- mckimn 04 Oct 2016: Exclude preface topic title from TOC -->
                                                    <xsl:if test="$topicType != 'topicPreface'">
                                                        <xsl:call-template name="getNavTitle" />
                                                    </xsl:if>
                                                </fo:inline>
												<!-- Dimitri: Add leader to the top-level TOC entries. -->
                                                <!--fo:leader xsl:use-attribute-sets="__toc__empty__leader"/-->
												<fo:leader xsl:use-attribute-sets="__toc__leader"/>
                                                <fo:page-number-citation>
                                                    <xsl:attribute name="ref-id">
                                                        <xsl:call-template name="generate-toc-id"/>
                                                    </xsl:attribute>
                                                </fo:page-number-citation>
                                            </fo:block>
                                        </fo:basic-link>
                                    </fo:block>
                                </xsl:variable>
                                <xsl:choose>
                                    <xsl:when test="not($mapTopicref)">
                                        <xsl:apply-templates select="." mode="tocText">
                                            <xsl:with-param name="tocItemContent" select="$tocItemContent"/>
                                            <xsl:with-param name="currentNode" select="."/>
                                        </xsl:apply-templates>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:apply-templates select="$mapTopicref" mode="tocText">
                                            <xsl:with-param name="tocItemContent" select="$tocItemContent"/>
                                            <xsl:with-param name="currentNode" select="."/>
                                        </xsl:apply-templates>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </fo:block>
                            <xsl:apply-templates mode="toc">
                                <xsl:with-param name="include" select="'true'"/>
                            </xsl:apply-templates>
                        </xsl:when>
                        <xsl:otherwise>
                            <fo:block xsl:use-attribute-sets="__toc__indent">
                                <xsl:variable name="tocItemContent">
                                    <fo:basic-link xsl:use-attribute-sets="__toc__link">
                                        <xsl:attribute name="internal-destination">
                                            <xsl:call-template name="generate-toc-id"/>
                                        </xsl:attribute>
                                        <fo:inline xsl:use-attribute-sets="__toc__title">
                                            <xsl:call-template name="getNavTitle" />
                                        </fo:inline>
                                        <fo:inline xsl:use-attribute-sets="__toc__page-number">
                                            <fo:leader xsl:use-attribute-sets="__toc__leader"/>
                                            <fo:page-number-citation>
                                                <xsl:attribute name="ref-id">
                                                    <xsl:call-template name="generate-toc-id"/>
                                                </xsl:attribute>
                                            </fo:page-number-citation>
                                        </fo:inline>
                                    </fo:basic-link>
                                </xsl:variable>
                                <xsl:choose>
                                    <xsl:when test="not($mapTopicref)">
                                        <xsl:apply-templates select="." mode="tocText">
                                            <xsl:with-param name="tocItemContent" select="$tocItemContent"/>
                                            <xsl:with-param name="currentNode" select="."/>
                                        </xsl:apply-templates>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:apply-templates select="$mapTopicref" mode="tocText">
                                            <xsl:with-param name="tocItemContent" select="$tocItemContent"/>
                                            <xsl:with-param name="currentNode" select="."/>
                                        </xsl:apply-templates>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </fo:block>
                            <xsl:apply-templates mode="toc">
                                <xsl:with-param name="include" select="'true'"/>
                            </xsl:apply-templates>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates mode="toc">
                        <xsl:with-param name="include" select="'true'"/>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' bookmap/part ')]" mode="tocText">
        <xsl:param name="tocItemContent"/>
        <xsl:param name="currentNode"/>
        <xsl:for-each select="$currentNode">
            <fo:block xsl:use-attribute-sets="__toc__part__content">
                <xsl:copy-of select="$tocItemContent"/>
            </fo:block>
        </xsl:for-each>
    </xsl:template>
    
    <!-- mckimn: 22-Sept-2016: Remove notices from TOC -->
    <xsl:template match="*[contains(@class, ' bookmap/notices ')]" mode="tocText"/>

    <xsl:template match="ot-placeholder:tablelist" mode="toc">
        <xsl:if test="//*[contains(@class, ' topic/table ')]/*[contains(@class, ' topic/title ')]">
            <fo:block xsl:use-attribute-sets="__toc__toplevel">
                <fo:float float="left" start-indent="0pt"
                    xsl:use-attribute-sets="__toc__topic__content">
					<!-- Dimitri: Fix the "Tables" leader length. -->
                    <!--fo:block-container xsl:use-attribute-sets="__toc__heading"-->
                    <fo:block-container>
                        <fo:block xsl:use-attribute-sets="__toc__heading__block">
                            <xsl:call-template name="insertVariable">
                                <xsl:with-param name="theVariableID" select="'List of Tables'"/>
                            </xsl:call-template>
                        </fo:block>
                    </fo:block-container>
                </fo:float>
                <fo:block xsl:use-attribute-sets="__toc__topic__content__lot">
                    <fo:basic-link internal-destination="{$id.lot}"
                        xsl:use-attribute-sets="__toc__link">
                        <fo:block xsl:use-attribute-sets="__toc__page-number">
							<!-- Dimitri: Add the "Tables" leader. -->
                            <!--fo:leader xsl:use-attribute-sets="__toc__empty__leader"/-->
							<fo:leader xsl:use-attribute-sets="__toc__leader"/>
                            <fo:page-number-citation ref-id="{$id.lot}"/>
                        </fo:block>
                    </fo:basic-link>
                </fo:block>
            </fo:block>
        </xsl:if>
    </xsl:template>

    <xsl:template match="ot-placeholder:figurelist" mode="toc">
        <xsl:if test="//*[contains(@class, ' topic/fig ')]/*[contains(@class, ' topic/title ')]">
            <fo:block xsl:use-attribute-sets="__toc__toplevel">
                <fo:float float="left" start-indent="0pt"
                    xsl:use-attribute-sets="__toc__topic__content">
					<!-- Dimitri: Fix the "Figures" leader length. -->
                    <!--fo:block-container xsl:use-attribute-sets="__toc__heading"-->
					<fo:block-container>
                        <fo:block xsl:use-attribute-sets="__toc__heading__block">
                            <xsl:call-template name="insertVariable">
                                <xsl:with-param name="theVariableID" select="'List of Figures'"/>
                            </xsl:call-template>
                        </fo:block>
                    </fo:block-container>
                </fo:float>
                <fo:block xsl:use-attribute-sets="__toc__topic__content__lof">
                    <fo:basic-link internal-destination="{$id.lof}"
                        xsl:use-attribute-sets="__toc__link">
                        <fo:block xsl:use-attribute-sets="__toc__page-number">
							<!-- Dimitri: Add the "Figures" leader. -->
                            <!--fo:leader xsl:use-attribute-sets="__toc__empty__leader"/-->
							<fo:leader xsl:use-attribute-sets="__toc__leader"/>
                            <fo:page-number-citation ref-id="{$id.lof}"/>
                        </fo:block>
                    </fo:basic-link>
                </fo:block>
            </fo:block>
        </xsl:if>
    </xsl:template>

    <xsl:template match="ot-placeholder:glossarylist" mode="toc">
        <fo:block xsl:use-attribute-sets="__toc__toplevel">
            <fo:float float="left" start-indent="0pt" xsl:use-attribute-sets="__toc__topic__content">
				<!-- Dimitri: Fix the "Glossary" leader length. -->
                <!--fo:block-container xsl:use-attribute-sets="__toc__heading"-->
				<fo:block-container>
                    <fo:block xsl:use-attribute-sets="__toc__heading__block">
                        <xsl:call-template name="insertVariable">
                            <xsl:with-param name="theVariableID" select="'Glossary'"/>
                        </xsl:call-template>
                    </fo:block>
                </fo:block-container>
            </fo:float>
            <fo:block xsl:use-attribute-sets="__toc__topic__content__glossary">
                <fo:basic-link internal-destination="{$id.glossary}"
                    xsl:use-attribute-sets="__toc__link">
                    <fo:block xsl:use-attribute-sets="__toc__page-number">
							<!-- Dimitri: Add the "Glossary" leader. -->
                        <!--fo:leader xsl:use-attribute-sets="__toc__empty__leader"/-->
						<fo:leader xsl:use-attribute-sets="__toc__leader"/>
                        <fo:page-number-citation ref-id="{$id.glossary}"/>
                    </fo:block>
                </fo:basic-link>
            </fo:block>
        </fo:block>
    </xsl:template>

    <xsl:template match="ot-placeholder:indexlist" mode="toc" name="toc.index">
        <xsl:if
            test="(//opentopic-index:index.groups//opentopic-index:index.entry) and (exists($index-entries//opentopic-index:index.entry))">
            <fo:block xsl:use-attribute-sets="__toc__toplevel">
                <fo:float float="left" start-indent="0pt"
                    xsl:use-attribute-sets="__toc__topic__content">
					<!-- Dimitri: Fix the "Index" leader length. -->
                    <!--fo:block-container xsl:use-attribute-sets="__toc__heading"-->
					<fo:block-container>
                        <fo:block xsl:use-attribute-sets="__toc__heading__block">
                            <xsl:call-template name="insertVariable">
                                <xsl:with-param name="theVariableID" select="'Index'"/>
                            </xsl:call-template>
                        </fo:block>
                    </fo:block-container>
                </fo:float>
                <fo:block xsl:use-attribute-sets="__toc__topic__content__booklist">
                    <fo:basic-link internal-destination="{$id.index}"
                        xsl:use-attribute-sets="__toc__link">
                        <fo:block xsl:use-attribute-sets="__toc__page-number">
							<!-- Dimitri: Add the "Index" leader. -->
                            <!--fo:leader xsl:use-attribute-sets="__toc__empty__leader"/-->
							<fo:leader xsl:use-attribute-sets="__toc__leader"/>
                            <fo:page-number-citation ref-id="{$id.index}"/>
                        </fo:block>
                    </fo:basic-link>
                </fo:block>
            </fo:block>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' bookmap/chapter ')]" mode="tocPrefix" priority="-1">
        <xsl:variable name="omit-chapter-numbers" select="if(/descendant::*[contains(@outputclass, 'omit_chapter_numbers')]) then(true()) else(false())"/>
        <!-- IA   Tridion upgrade    Jan-2019   Remove 'Chapter 1' from the chapter cover page if there is only one chapter in PDF  - IB-->
        <!-- IA   Tridion upgrade    Mar-2019 IDPL-5477: Adapt 3 PDF output formats to support CPSD documenation.
                                    Omit chapters number if bookmap has @outputclass = 'omit_chapter_numbers'.  - IB-->
        <xsl:if test="(count(/descendant::*[contains(@class, ' bookmap/chapter ')]) &gt; 1) and(not($omit-chapter-numbers))">
            <xsl:call-template name="insertVariable">
                <xsl:with-param name="theVariableID" select="'Table of Contents Chapter'"/>
                <xsl:with-param name="theParameters">
                    <number>
                        <xsl:apply-templates select="." mode="topicTitleNumber"/>
                    </number>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' bookmap/appendix ')]" mode="tocPrefix">
        <xsl:call-template name="insertVariable">
            <xsl:with-param name="theVariableID" select="'Table of Contents Appendix'"/>
            <xsl:with-param name="theParameters">
                <!--IA    Sep-2019    IDPL-7080: PDF, PDF Draft, PDF Beta, CPSD PDF: Appendix does not properly number
                 Use 'Appendix' title without number if bokkmap contains ONLY ONE Appendix.    -  IB-->
                <xsl:if test="count(/descendant::*[contains(@class, ' bookmap/appendix ')]) &gt; 1">
                    <number>
                        <xsl:apply-templates select="." mode="topicTitleNumber"/>
                    </number>
                </xsl:if>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>
