<?xml version="1.0"?>

<!--
Revision History
================
Suite/EMC   SOW5  24-Apr-2012   font changes
EMC			IB3	  28-Oct-2013  	Issue 362: Font size change for screen
EMC		    IB4	  21-May-2014	wintitle, uicontrol should be Tahoma Bold for Russian characters
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

    <!-- EMC	IB4	 21-May-2014	uicontrol should be Tahoma Bold for Russian characters -->
    <xsl:attribute-set name="uicontrol">
        <xsl:attribute name="font-weight">
            <xsl:choose>
                <xsl:when test="$locale = 'ko'">bold</xsl:when>
                <xsl:otherwise>normal</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="line-height">100%</xsl:attribute>
        <xsl:attribute name="font-family">
            <xsl:choose>
                <xsl:when test="$locale = 'ru'">SansCondBoldRoman-Bold</xsl:when>
                <xsl:otherwise>SansCondBoldRoman</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="font-size">
            <xsl:choose>
                <xsl:when test="ancestor::*[contains(@class, ' topic/table ')]">
                    <!-- IA   Tridion upgrade    Oct-2018   Use decreased font size for elements inside table - IB-->
                    <xsl:value-of select="$default-table-font-size"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$default-font-size" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:attribute-set>

	<!-- EMC	IB4	 21-May-2014	wintitle should be Tahoma Bold for Russian characters -->
    <xsl:attribute-set name="wintitle">
        <xsl:attribute name="font-weight">
            <xsl:choose>
                <xsl:when test="$locale = 'ko'">bold</xsl:when>
                <xsl:otherwise>normal</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="line-height">100%</xsl:attribute>
        <xsl:attribute name="font-family">
			<xsl:choose>
				<xsl:when test="$locale = 'ru'">SansCondBoldRoman-Bold</xsl:when>
				<xsl:otherwise>SansCondBoldRoman</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
        <xsl:attribute name="font-size">
            <xsl:choose>
                <xsl:when test="ancestor::*[contains(@class, ' topic/table ')]">
                    <!-- IA   Tridion upgrade    Oct-2018   Use decreased font size for elements inside table - IB-->
                    <xsl:value-of select="$default-table-font-size"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$default-font-size" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:attribute-set>
    
  <xsl:attribute-set name="menucascade.separator">
    <xsl:attribute name="font-family">SansLFRoman</xsl:attribute>
    <xsl:attribute name="font-size">9pt</xsl:attribute>
  </xsl:attribute-set>
  
      <!-- Nathan McKimpson 10/25/2012: Add outputclass="pagewide" support for screen elements and update formatting to match codeblock -->
      <xsl:attribute-set name="screen">
          <xsl:attribute name="space-before">0.4em</xsl:attribute>
          <xsl:attribute name="space-after">0.8em</xsl:attribute>
          <xsl:attribute name="white-space-treatment">preserve</xsl:attribute>
          <xsl:attribute name="white-space-collapse">false</xsl:attribute>
          <xsl:attribute name="linefeed-treatment">preserve</xsl:attribute>
          <xsl:attribute name="wrap-option">wrap</xsl:attribute>
          <xsl:attribute name="background-color">#f0f0f0</xsl:attribute>
          <xsl:attribute name="font-family">Monospaced</xsl:attribute>
          <xsl:attribute name="line-height">106%</xsl:attribute>
		  <!-- EMC		IB3	  28-Oct-2013  	Issue 362: Font size change for screen -->
          <xsl:attribute name="font-size">
			  <xsl:choose>
				<xsl:when test="ancestor::*[contains(@class,' topic/note ') or contains(@class,' topic/entry ') or contains(@class,' topic/stentry ')]"><xsl:value-of select="$default-font-size"/> - 2pt</xsl:when>
				<xsl:otherwise><xsl:value-of select="$default-font-size"/> - 1pt</xsl:otherwise>
			  </xsl:choose>	
		  </xsl:attribute>
          <xsl:attribute name="margin-left">
              <xsl:choose>
                  <xsl:when test="contains(@outputclass,'pagewide')">
                      -<xsl:value-of select="$side-col-width"/>
                  </xsl:when>
                  <xsl:otherwise/>
              </xsl:choose>
          </xsl:attribute>
   </xsl:attribute-set> 

</xsl:stylesheet>