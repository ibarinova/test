<?xml version="1.0" encoding="UTF-8"?>
<!--
    ============================================================
    Copyright (c) 2006 Antenna House, Inc. All rights reserved.
    Antenna House is a trademark of Antenna House, Inc.
    URL    : http://www.antennahouse.com/
    E-mail : info@antennahouse.com
    ============================================================
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  xmlns:opentopic-func="http://www.idiominc.com/opentopic/exsl/function"
  xmlns:comparer="com.idiominc.ws.opentopic.xsl.extension.CompareStrings"
  xmlns:opentopic-index="http://www.idiominc.com/opentopic/index"
  exclude-result-prefixes="xs opentopic-index comparer opentopic-func">


  <!-- 
    Revision History
    ================
    Suite/EMC   SOW6  10-Jun-2012   "index-see" should be displayed inline.
    Suite/EMC   SOW6  16-Aug-2012   index should be processed only when <indexlist/> appears
  -->

  <xsl:template name="createIndex">
    <xsl:if test="(//opentopic-index:index.groups//opentopic-index:index.entry) and (count($index-entries//opentopic-index:index.entry) &gt; 0)">
      <xsl:variable name="index">
        <xsl:choose>
          <xsl:when test="$map//*[contains(@class,' bookmap/indexlist ')][@href]"/>
          <xsl:when test="$map//*[contains(@class,' bookmap/indexlist ')]">
            <xsl:apply-templates select="/" mode="index-postprocess"/>
          </xsl:when>
          <xsl:when test="/*[contains(@class,' map/map ')][not(contains(@class,' bookmap/bookmap '))]">
            <xsl:apply-templates select="/" mode="index-postprocess"/>
          </xsl:when>
        </xsl:choose>
      </xsl:variable>
      <xsl:if test="count($index/*) > 0">
        <fo:page-sequence master-reference="index-sequence" xsl:use-attribute-sets="__force__page__count">
          <xsl:call-template name="insertIndexStaticContents"/>
          <fo:flow flow-name="xsl-region-body" page-number-treatment="link">
            <fo:marker marker-class-name="current-header">
              <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'Index'"/>
              </xsl:call-template>
            </fo:marker>
            <xsl:copy-of select="$index"/>
          </fo:flow>
        </fo:page-sequence>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match="opentopic-index:index.entry" mode="index-postprocess">
    <xsl:variable name="value" select="@value"/>
    <xsl:choose>
      <xsl:when test="opentopic-index:index.entry">
        <fo:table>
          <fo:table-body>
            <fo:table-row>
              <fo:table-cell>
                <fo:block xsl:use-attribute-sets="index-no-indents">
                  <xsl:if test="count(ancestor::opentopic-index:index.entry) > 0">
                    <xsl:attribute name="keep-together.within-page">always</xsl:attribute>
                  </xsl:if>
                  <xsl:comment>block B1 - begin indexterm with child indexterms - rs</xsl:comment>
                  <xsl:variable name="following-idx"
                    select="following-sibling::opentopic-index:index.entry[@value = $value and opentopic-index:refID]"/>
                  <xsl:if
                    test="count(preceding-sibling::opentopic-index:index.entry[@value = $value]) = 0">
                    <xsl:variable name="page-setting"
                      select="(ancestor-or-self::opentopic-index:index.entry/@no-page | ancestor-or-self::opentopic-index:index.entry/@start-page)[last()]"/>
                    <xsl:variable name="isNoPage"
                      select="$page-setting = 'true' and name($page-setting) = 'no-page'"/>
                    <xsl:variable name="refID" select="opentopic-index:refID/@value"/>
                    <xsl:choose>
                      <xsl:when
                        test="$index-entries/opentopic-index:index.entry[(@value = $value) and (opentopic-index:refID/@value = $refID)][not(opentopic-index:index.entry)]">
                        <xsl:apply-templates select="." mode="make-index-ref">
                          <xsl:with-param name="idxs" select="opentopic-index:refID"/>
                          <xsl:with-param name="inner-text" select="opentopic-index:formatted-value"/>
                          <xsl:with-param name="no-page" select="$isNoPage"/>
                        </xsl:apply-templates>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:apply-templates select="." mode="make-index-ref">
                          <xsl:with-param name="inner-text" select="opentopic-index:formatted-value"/>
                          <xsl:with-param name="no-page" select="$isNoPage"/>
                        </xsl:apply-templates>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:if>
                </fo:block>
                <xsl:comment>block B1 - end - rs</xsl:comment>
              </fo:table-cell>
            </fo:table-row>
          </fo:table-body>
          <fo:table-body>
            <fo:table-row>
              <fo:table-cell>
                <fo:block xsl:use-attribute-sets="index.entry__content">
                  <xsl:comment>block B2 - begin all child indexterms - rs</xsl:comment>
                  <xsl:apply-templates mode="index-postprocess"/>
                </fo:block>
                <xsl:comment>block B2 - end - rs</xsl:comment>
              </fo:table-cell>
            </fo:table-row>
          </fo:table-body>
        </fo:table>
      </xsl:when>
      <xsl:otherwise>
        <fo:block xsl:use-attribute-sets="index-indents">
          <xsl:if test="count(ancestor::opentopic-index:index.entry) > 0">
            <xsl:attribute name="keep-together.within-page">always</xsl:attribute>
          </xsl:if>
          <xsl:comment>block B3 - begin any individual indexterm (parent/child/standalone) - rs</xsl:comment>
          <xsl:variable name="following-idx"
            select="following-sibling::opentopic-index:index.entry[@value = $value and opentopic-index:refID]"/>
          <xsl:if test="count(preceding-sibling::opentopic-index:index.entry[@value = $value]) = 0">
            <xsl:variable name="page-setting"
              select="(ancestor-or-self::opentopic-index:index.entry/@no-page | ancestor-or-self::opentopic-index:index.entry/@start-page)[last()]"/>
            <xsl:variable name="isNoPage"
              select="$page-setting = 'true' and name($page-setting) = 'no-page'"/>
            <xsl:apply-templates select="." mode="make-index-ref">
              <xsl:with-param name="idxs" select="opentopic-index:refID"/>
              <xsl:with-param name="inner-text" select="opentopic-index:formatted-value"/>
              <xsl:with-param name="no-page" select="$isNoPage"/>
            </xsl:apply-templates>
          </xsl:if>
          <xsl:comment>block B3 - end - rs</xsl:comment>
          <!-- Dana/Natasha ib2 2013-06-28 fixed See also indent -->
          <xsl:choose>
            <xsl:when test="opentopic-index:see-also-childs">
              <fo:block margin-left="0.25in">
                <xsl:apply-templates mode="index-postprocess"/>
              </fo:block>
            </xsl:when>
            <xsl:otherwise>
              <fo:inline xsl:use-attribute-sets="index.entry__content">
                <xsl:apply-templates mode="index-postprocess"/>
              </fo:inline>
            </xsl:otherwise>
          </xsl:choose>
        </fo:block>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
   
  <xsl:template match="*" mode="make-index-ref">
    <xsl:param name="idxs" select="()"/>
    <xsl:param name="inner-text" select="()"/>
    <xsl:param name="no-page"/>
      <fo:inline>
        <xsl:apply-templates select="$inner-text/node()"/>
      </fo:inline>
      <!-- XXX: XEP has this, should base too? -->
      <!--
      <xsl:if test="$idxs">
        <xsl:for-each select="$idxs">
          <fo:inline id="{@value}"/>
        </xsl:for-each>
      </xsl:if>
      -->
      <xsl:if test="not($no-page)">
        <xsl:if test="$idxs">
          <xsl:copy-of select="$index.separator"/>
          <fo:index-page-citation-list>
            <xsl:for-each select="$idxs">
              <fo:index-key-reference ref-index-key="{@value}" xsl:use-attribute-sets="__index__page__link"/>
            </xsl:for-each>
          </fo:index-page-citation-list>
        </xsl:if>
      </xsl:if>
      <xsl:if test="@no-page = 'true'">
        <xsl:apply-templates select="opentopic-index:see-childs" mode="index-postprocess"/>
      </xsl:if>
      <xsl:if test="empty(opentopic-index:index.entry)">
        <xsl:apply-templates select="opentopic-index:see-also-childs" mode="index-postprocess"/>
      </xsl:if>
  </xsl:template>

  <!--Suite/EMC   SOW6  10-Jun-2012   keep 'see-also' with previous - ck-->
  <xsl:template match="opentopic-index:see-childs" mode="index-postprocess">
    <xsl:choose>
      <xsl:when test="parent::*[@no-page = 'true']">
        <fo:inline>
          <xsl:call-template name="getVariable">
            <xsl:with-param name="id" select="'Index See String'"/>
          </xsl:call-template>
          <fo:basic-link>
            <xsl:attribute name="internal-destination">
              <xsl:apply-templates select="opentopic-index:index.entry[1]"
                mode="get-see-destination"/>
            </xsl:attribute>
            <xsl:apply-templates select="opentopic-index:index.entry[1]" mode="get-see-value"/>
          </fo:basic-link>
        </fo:inline>
      </xsl:when>
      <xsl:otherwise>
        <fo:inline>
          <!--keep 'see also' with previous - ck-->
          <xsl:attribute name="keep-with-previous.within-column">always</xsl:attribute>
          <fo:inline>
            <xsl:call-template name="getVariable">
              <xsl:with-param name="id" select="'Index See Also String'"/>
            </xsl:call-template>
            <fo:basic-link>
              <xsl:attribute name="internal-destination">
                <xsl:apply-templates select="opentopic-index:index.entry[1]"
                  mode="get-see-destination"/>
              </xsl:attribute>
              <xsl:apply-templates select="opentopic-index:index.entry[1]" mode="get-see-value"/>
            </fo:basic-link>
          </fo:inline>
        </fo:inline>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
