<?xml version="1.0" encoding="iso-8859-1"?>
<!--
 psmi.xsl

 Interpret the Page Sequence Master Interleave formatting semantic described
 at http://www.CraneSoftwrights.com/resources/psmi for interleaving page
 geometries in XSLFO flows.

 $Id: psmi.xsl,v 1.6 2002/11/01 18:11:28 G. Ken Holman Exp $

This semantic, its stylesheet file, and the information contained herein is
provided on an "AS IS" basis and CRANE SOFTWRIGHTS LTD. DISCLAIMS
ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO 
ANY WARRANTY THAT THE USE OF THE INFORMATION HEREIN WILL NOT INFRINGE
ANY RIGHTS OR ANY IMPLIED WARRANTIES OF MERCHANTABILITY OR FITNESS 
FOR A PARTICULAR PURPOSE.

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:psmi="http://www.CraneSoftwrights.com/resources/psmi"
                exclude-result-prefixes="psmi"
                version="1.0">

  <!--==========================================================================
  Handle a sequence of pages, only if it has the expected psmi:page-sequence
  children in the flow.
-->
  <xsl:template match="fo:page-sequence">
    <xsl:choose>
      <xsl:when test="fo:flow/psmi:page-sequence">
        <!--accommodate new semantic-->
        <xsl:if test="@force-page-count = 'even' or
                    @force-page-count = 'odd'">
          <!--<xsl:message>
          <xsl:text>Unable to support a 'force-page-count=' </xsl:text>
          <xsl:text>value of: </xsl:text>
          <xsl:value-of select="@force-page-count"/>
        </xsl:message>-->
        </xsl:if>
        <xsl:apply-templates select="fo:flow/*[1]" mode="psmi:do-flow-children"/>
      </xsl:when>
      <xsl:when test="descendant::psmi:*">
        <!--unexpected location for semantic-->
        <xsl:call-template name="psmi:preserve"/>
        <!-- this will catch each-->
      </xsl:when>
      <xsl:otherwise>
        <!--no need to do special processing; faster to just copy-->
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--==========================================================================
  Create a page sequence from the flow.
-->

  <xsl:template match="*" mode="psmi:do-flow-children">
    <fo:page-sequence>
      <!--page-sequence attributes-->
      <xsl:copy-of select="../../@*[not(name(.)='initial-page-number')and not(name(.)='master-reference')]"/>
      <xsl:attribute name="master-reference">
        <xsl:choose>
          <!--Suite - insert a page sequence without a first master page for new sequences that are not the first one in the flow-->
          <xsl:when test="../../@master-reference='body-sequence' and preceding-sibling::*">body-continue-sequence</xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="../../@master-reference"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:if test="self::psmi:page-sequence">
        <xsl:copy-of select="@master-reference"/>
        <xsl:if test="@*[name(.)!='master-reference']">
          <xsl:message>
            <xsl:text>Only the 'master-reference=' attribute is </xsl:text>
            <xsl:text>allowed for </xsl:text>
            <xsl:call-template name="psmi:name-this"/>
          </xsl:message>
        </xsl:if>
      </xsl:if>

      <!--only preserve specified initial-page-number= on first page sequence-->
      <xsl:if test="not(preceding-sibling::*)">
        <xsl:copy-of select="../../@initial-page-number"/>
      </xsl:if>

      <!--only preserve specified force-page-count= on last page sequence-->
      <xsl:if test="following-sibling::psmi:page-sequence or self::psmi:page-sequence/following-sibling::*">
        <!--not last-->
        <xsl:attribute name="force-page-count">no-force</xsl:attribute>
      </xsl:if>

      <xsl:choose>
        <xsl:when test="self::psmi:page-sequence">
          <!--psmi:page-sequence title has precedence-->
          <xsl:copy-of select="(../../fo:title|fo:title)[last()]"/>
          <!--psmi:page-sequence static-content has precedence-->
          <xsl:copy-of select="fo:static-content"/>
          <!--get other static-content not already in psmi:page-sequence-->
          <xsl:variable name="static-content-flow-names"
                        select="fo:static-content/@flow-name"/>
          <xsl:for-each select="../../fo:static-content">
            <xsl:if test="not( @flow-name = $static-content-flow-names )">
              <xsl:copy-of select="."/>
            </xsl:if>
          </xsl:for-each>
          <!--do the psmi:page-sequence flow-->
          <fo:flow>
            <xsl:if test="not(fo:flow)">

            </xsl:if>
            <xsl:for-each select="fo:flow">
              <xsl:copy-of select="@*"/>
              <xsl:if test="not(@flow-name)">

              </xsl:if>
             
              <!-- Suite Dec-2011: copy previous header markers - rs -->
              <xsl:copy-of select="(../preceding-sibling::*/descendant::fo:marker[@marker-class-name='current-header'])[last()]"/>
              <xsl:copy-of select="(../preceding-sibling::*/descendant::fo:marker[@marker-class-name='current-any-header'])[last()]"/>
              
              <!--all flow contents belong in sequence-->
              <xsl:apply-templates select="*"/>
            </xsl:for-each>
          </fo:flow>
        </xsl:when>
        <xsl:otherwise>
          <!--only following siblings up to psmi:page-sequence-->
          <!--use all of the fo:page-sequence's non-flow children-->
          <xsl:copy-of select="../../fo:title|../../fo:static-content"/>
          <!--use all of the fo:page-sequence's flow attributes-->
          <fo:flow>
            <xsl:copy-of select="../@*"/>
            <!--only use as much flow as up to the next psmi:page-sequence-->
            
            <!-- Suite Dec-2011: copy previous header markers - only copy current-any-header if this new flow is not a topic and does not have its own marker - rs -->
            <xsl:copy-of select="(preceding-sibling::*/descendant::fo:marker[@marker-class-name='current-header'])[last()]"/>
            <xsl:if test="not(descendant::fo:marker[@marker-class-name='current-any-header'])">
              <xsl:copy-of select="(preceding-sibling::*/descendant::fo:marker[@marker-class-name='current-any-header'])[last()]"/>
            </xsl:if>
            
            <xsl:call-template name="copy-until-psmi"/>
          </fo:flow>
        </xsl:otherwise>
      </xsl:choose>
    </fo:page-sequence>
    <!--move to the next need for a page sequence-->
    <xsl:choose>
      <xsl:when test="self::psmi:page-sequence">
        <xsl:apply-templates select="following-sibling::*[1]"
                             mode="psmi:do-flow-children"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="following-sibling::psmi:page-sequence[1]"
                             mode="psmi:do-flow-children"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="copy-until-psmi" mode="copy-until-psmi" match="*">
    <xsl:if test="not(self::psmi:page-sequence)">
      <xsl:call-template name="psmi:preserve"/>
      <!--copy this element-->
      <xsl:apply-templates select="following-sibling::*[1]"
                           mode="copy-until-psmi"/>
    </xsl:if>
  </xsl:template>


  <!--==========================================================================
  Handle the new semantic when found in the wrong context by reporting error.
-->

  <xsl:template match="psmi:page-sequence" name="unexpected-psmi">
    <xsl:message terminate="yes">
      <xsl:text>Unexpected parent </xsl:text>
      <xsl:for-each select="..">
        <xsl:call-template name="psmi:name-this"/>
      </xsl:for-each>
      <xsl:text> for </xsl:text>
      <xsl:call-template name="psmi:name-this"/>
    </xsl:message>
    <xsl:apply-templates select="*"/>
  </xsl:template>

  <!--==========================================================================
  Default handlers for other constructs.
-->

  <xsl:template match="psmi:*">
    <!--no other PSMI construct is defined-->
    <xsl:message>
      <xsl:text>Unrecognized construct ignored: </xsl:text>
      <xsl:call-template name="psmi:name-this"/>
    </xsl:message>
  </xsl:template>

  <xsl:template match="*" name="psmi:preserve">
    <!--other constructs preserved-->
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="psmi:name-this">
    <xsl:value-of disable-output-escaping="yes"
               select="local-name()"/>
  </xsl:template>

</xsl:stylesheet>
