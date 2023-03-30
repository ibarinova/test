<?xml version='1.0'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:opentopic="http://www.idiominc.com/opentopic"
    exclude-result-prefixes="opentopic"
    version="2.0">

    <!--
        Revision History
        ================
        Suite/EMC   SOW7    07-Apr-2013   Exclude change-markup in some contexts and and add support for RSA heading styles
    -->

     <xsl:template name="processTopicPreface">
         <fo:page-sequence master-reference="body-sequence" format="1" xsl:use-attribute-sets="__force__page__count">
             <xsl:call-template name="insertPrefaceStaticContents"/>
             <fo:flow flow-name="xsl-region-body">
                  <!-- IDPL-2700. added by Roopesh. Add topic metadata to PDF, call pubmeta template before preface title-->
				<xsl:if test="lower-case($INCLUDEMETADATA) = 'yes'">
					<fo:block font-size="10pt">
					<xsl:call-template name="pubmeta"/>
					</fo:block>
				</xsl:if>
				 <fo:block xsl:use-attribute-sets="topic">
				     <xsl:call-template name="commonattributes"/>
                    <xsl:if test="not(ancestor::*[contains(@class, ' topic/topic ')])">
                         <fo:marker marker-class-name="current-topic-number">
                             <xsl:number format="1"/>
                         </fo:marker>
                         <fo:marker marker-class-name="current-header">
                             <xsl:for-each select="child::*[contains(@class,' topic/title ')]">
                                 <xsl:apply-templates select="." mode="getTitle">
                                     <xsl:with-param name="change-markup">no</xsl:with-param>
                                 </xsl:apply-templates>
                             </xsl:for-each>
                         </fo:marker>
                     </xsl:if>
                     <xsl:apply-templates select="*[contains(@class,' topic/prolog ')]"/>
                     <xsl:call-template name="insertChapterFirstpageStaticContent">
                         <xsl:with-param name="type" select="'preface'"/>
                     </xsl:call-template>
                     <xsl:choose>
                         <!-- Intelliarts Consulting   DellEMC Rebranding    10-Oct-2016   Add using of RSA BRAND value from BRAND list instead of @outputclass with 'rsa' value - IB-->
                         <xsl:when test="$BRAND-IS-RSA">
                             <fo:block xsl:use-attribute-sets="topic.title__rsa">
                                 <xsl:call-template name="pullPrologIndexTerms"/>
                                 <xsl:for-each select="child::*[contains(@class,' topic/title ')]">
                                     <xsl:apply-templates select="." mode="getTitle"/>
                                 </xsl:for-each>
                             </fo:block>
                         </xsl:when>
                         <xsl:otherwise>
                             <fo:block xsl:use-attribute-sets="topic.title">
                                 <xsl:call-template name="pullPrologIndexTerms"/>
                                 <xsl:for-each select="child::*[contains(@class,' topic/title ')]">
                                     <xsl:apply-templates select="." mode="getTitle"/>
                                 </xsl:for-each>
                             </fo:block>
                         </xsl:otherwise>
                     </xsl:choose>
                     <xsl:apply-templates select="*[not(contains(@class,' topic/title '))]"/>
                 </fo:block>
             </fo:flow>
         </fo:page-sequence>
    </xsl:template>

</xsl:stylesheet>