<?xml version='1.0'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  xmlns:opentopic="http://www.idiominc.com/opentopic"
  xmlns:opentopic-index="http://www.idiominc.com/opentopic/index"
  xmlns:opentopic-func="http://www.idiominc.com/opentopic/exsl/function"
  xmlns:ot-placeholder="http://suite-sol.com/namespaces/ot-placeholder"
  exclude-result-prefixes="opentopic-index opentopic opentopic-func ot-placeholder"
  version="2.0">

  <!-- 
    Revision History
    ================
    Suite/EMC   RSA       16-Aug-2012   Don't include notices / copyright page in bookmarks
    Suite/EMC   Nochap    06-Sep-2012   Mantis 0006752
    Suite/EMC   RSA       16-Aug-2012   Don't include notices / copyright page in bookmarks
	  EMC		      Glossary  22-Apr-2013	  Bookmarks will not include glossary entries
	  EMC		IB4       15-Apr-2014   #387 - LOF should be before LOT in bookmap template
	  EMC 		IB4       15-Apr-2014   #357 - Glossary content appears in nochap PDF bookmarks
	  EMC		IB4		  18-Apr-2014	Glossary map can be specified in glossarylist @href
  -->
  
<!--Modified index processing, added tablelist and figurelist processing - rs-->
  

  <xsl:template name="createBookmarks">
    <xsl:variable name="bookmarks" as="element()*">
      <xsl:choose>
        <xsl:when test="$retain-bookmap-order">
          <xsl:apply-templates select="/" mode="bookmark"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="/*/*[contains(@class, ' topic/topic ')]">
            <xsl:variable name="topicType">
              <xsl:call-template name="determineTopicType"/>
            </xsl:variable>
            <!-- mckimn: 22-Sept-2016: Remove notices from bookmarks -->
            <!--<xsl:if test="$topicType = 'topicNotices'">
              <xsl:apply-templates select="." mode="bookmark"/>
            </xsl:if>-->
          </xsl:for-each>
          <xsl:choose>
            <xsl:when test="$map//*[contains(@class,' bookmap/toc ')][@href]"/>
            <xsl:when test="$map//*[contains(@class,' bookmap/toc ')]
              | /*[contains(@class,' map/map ')][not(contains(@class,' bookmap/bookmap '))] and $NOCHAP = 'no'">
              <fo:bookmark internal-destination="{$id.toc}">
                <fo:bookmark-title>
                  <xsl:call-template name="getVariable">
                    <xsl:with-param name="id" select="'Table of Contents'"/>
                  </xsl:call-template>
                </fo:bookmark-title>
              </fo:bookmark>
            </xsl:when>
          </xsl:choose>
          <xsl:for-each select="/*/*[contains(@class, ' topic/topic ')] |
            /*/ot-placeholder:glossarylist |
            /*/ot-placeholder:tablelist |
            /*/ot-placeholder:figurelist">
            <xsl:variable name="topicType">
              <xsl:call-template name="determineTopicType"/>
            </xsl:variable>
            <xsl:if test="not($topicType = 'topicNotices')">
              <xsl:apply-templates select="." mode="bookmark"/>
            </xsl:if>
          </xsl:for-each>
          <xsl:if test="//opentopic-index:index.groups//opentopic-index:index.entry">
            <xsl:choose>
              <xsl:when test="$map//*[contains(@class,' bookmap/indexlist ')][@href]"/>
              <xsl:when test="$map//*[contains(@class,' bookmap/indexlist ')]
                | /*[contains(@class,' map/map ')][not(contains(@class,' bookmap/bookmap '))] and $NOCHAP = 'no'">
                <fo:bookmark internal-destination="{$id.index}">
                  <fo:bookmark-title>
                    <xsl:call-template name="getVariable">
                      <xsl:with-param name="id" select="'Index'"/>
                    </xsl:call-template>
                  </fo:bookmark-title>
                </fo:bookmark>
              </xsl:when>
            </xsl:choose>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="exists($bookmarks)">
      <fo:bookmark-tree>
        <xsl:copy-of select="$bookmarks"/>
      </fo:bookmark-tree>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/topic ')]" mode="bookmark">
    <xsl:if test="count(ancestor::*[contains(@class,' topic/topic ')]) &lt; 3">
      <xsl:variable name="mapTopicref" select="key('map-id', @id)[1]"/>
      <xsl:variable name="topicTitle">
        <!-- Suite Jan-2012: extract text only from return value of getNavTitle template, to remove fo markup from bookmark title.
        This is necessary as all text within fo markup in a bookmark title will be hidden. -->
        <xsl:variable name="navTitle">
          <xsl:call-template name="getNavTitle"/>
        </xsl:variable>
        <xsl:variable name="filterNavTitle">
          <xsl:value-of select="$navTitle"/>
        </xsl:variable>
        <xsl:value-of select="normalize-space($filterNavTitle)"/>
      </xsl:variable>

      <xsl:choose>
        <xsl:when test="count(ancestor::*[contains(@class,' topic/topic ')]) = 0 and $NOCHAP = 'yes'">
          <xsl:variable name="in-front-matter"
            select="count(//*[contains(@class, ' bookmap/frontmatter ')]//*[@id = current()/@id]) &gt; 0"/>
          <xsl:if test="not($in-front-matter)">
            <xsl:apply-templates mode="bookmark"/>
          </xsl:if>
        </xsl:when>
        <xsl:when test="$mapTopicref[@toc = 'yes' or not(@toc)] or
          not($mapTopicref)">
          <fo:bookmark>
            <xsl:attribute name="internal-destination">
              <xsl:call-template name="generate-toc-id"/>
            </xsl:attribute>
            <xsl:if test="$bookmarkStyle!='EXPANDED'">
              <xsl:attribute name="starting-state">hide</xsl:attribute>
            </xsl:if>
            <fo:bookmark-title>
              <xsl:value-of select="normalize-space($topicTitle)"/>
            </fo:bookmark-title>
            <xsl:apply-templates mode="bookmark"/>
          </fo:bookmark>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates mode="bookmark"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="ot-placeholder:figurelist" mode="bookmark">
    <xsl:if test="$NOCHAP = 'no'">
      <xsl:if test="//*[contains(@class, ' topic/fig ')]/*[contains(@class, ' topic/title ' )]">
        <fo:bookmark internal-destination="{$id.lof}">
          <xsl:if test="$bookmarkStyle!='EXPANDED'">
            <xsl:attribute name="starting-state">hide</xsl:attribute>
          </xsl:if>
          <fo:bookmark-title>
            <xsl:call-template name="insertVariable">
              <xsl:with-param name="theVariableID" select="'List of Figures'"/>
            </xsl:call-template>
          </fo:bookmark-title>
          
          <xsl:apply-templates mode="bookmark"/>
        </fo:bookmark>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="ot-placeholder:tablelist" mode="bookmark">
    <xsl:if test="$NOCHAP = 'no'">
      <xsl:if test="//*[contains(@class, ' topic/table ')]/*[contains(@class, ' topic/title ' )]">
        <fo:bookmark internal-destination="{$id.lot}">
          <xsl:if test="$bookmarkStyle!='EXPANDED'">
            <xsl:attribute name="starting-state">hide</xsl:attribute>
          </xsl:if>
          <fo:bookmark-title>
            <xsl:call-template name="insertVariable">
              <xsl:with-param name="theVariableID" select="'List of Tables'"/>
            </xsl:call-template>
          </fo:bookmark-title>
          
          <xsl:apply-templates mode="bookmark"/>
        </fo:bookmark>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="ot-placeholder:glossarylist" mode="bookmark">
    <xsl:if test="$NOCHAP = 'no'">
      <fo:bookmark internal-destination="{$id.glossary}">
        <xsl:if test="$bookmarkStyle!='EXPANDED'">
          <xsl:attribute name="starting-state">hide</xsl:attribute>
        </xsl:if>
        <fo:bookmark-title>
          <xsl:call-template name="getVariable">
            <xsl:with-param name="id" select="'Glossary'"/>
          </xsl:call-template>
        </fo:bookmark-title>
        <!--<xsl:apply-templates mode="bookmark"/>-->
      </fo:bookmark>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>