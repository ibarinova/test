<?xml version="1.0"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
  <!--
    Revision History
    ================
    EMC		IB3	 28-Oct-2013  	Issue 362, 320: Font size change for cmdname, filepath, msgblock, userinput, varname
	EMC		IB4	 21-May-2014	systemoutput should be Tahoma Bold for Russian characters
	EMC	    IB5	 20-Aug-2014	Add shaded background to msgblock
  -->

    <!-- Nathan McKimpson 24-May-2013: updated formatting -->
    <xsl:attribute-set name="cmdname">
        <xsl:attribute name="font-weight">normal</xsl:attribute>
        <xsl:attribute name="line-height">100%</xsl:attribute>
        <xsl:attribute name="font-family">Monospaced</xsl:attribute>
		<xsl:attribute name="font-size">inherited-property-value(&apos;font-size&apos;)</xsl:attribute>
    </xsl:attribute-set>

    <!-- Suite Jan-2012: updated formatting -->
    <xsl:attribute-set name="varname">
        <!-- IA   Tridion upgrade    Oct-2018   <varname> should be italic for all languages (TKT-409) - IB-->
        <xsl:attribute name="font-style">italic</xsl:attribute>
		<xsl:attribute name="font-family">inherit</xsl:attribute>
    </xsl:attribute-set>

    <!-- Nathan McKimpson 2013-May-18: Remove hard-coded font-size so the font-size can be inherited from a surrounding element  -->
    <xsl:attribute-set name="filepath">
        <xsl:attribute name="font-family">Monospaced</xsl:attribute>
		<xsl:attribute name="font-size">inherited-property-value(&apos;font-size&apos;)</xsl:attribute>
    </xsl:attribute-set>

    <!-- Nathan McKimpson 10/25/2012: Add outputclass="pagewide" support for msgblock elements and update formatting to match codeblock -->
    <xsl:attribute-set name="msgblock" use-attribute-sets="pre common.block">
        <xsl:attribute name="space-before">0.4em</xsl:attribute>
        <xsl:attribute name="space-after">0.8em</xsl:attribute>
        <xsl:attribute name="white-space-treatment">preserve</xsl:attribute>
        <xsl:attribute name="white-space-collapse">false</xsl:attribute>
        <xsl:attribute name="linefeed-treatment">preserve</xsl:attribute>
        <xsl:attribute name="wrap-option">wrap</xsl:attribute>
        <xsl:attribute name="font-family">Monospaced</xsl:attribute>
        <xsl:attribute name="line-height">106%</xsl:attribute>
        <xsl:attribute name="font-size">
			<xsl:choose>
				<xsl:when test="ancestor::*[contains(@class,' topic/note ') or contains(@class,' topic/entry ') or contains(@class,' topic/stentry ')]"><xsl:value-of select="$default-font-size"/> - 2pt</xsl:when>
				<xsl:otherwise><xsl:value-of select="$default-font-size"/> - 1pt</xsl:otherwise>
            </xsl:choose>
		</xsl:attribute>
        <xsl:attribute name="keep-with-previous.within-page">always</xsl:attribute>
        <xsl:attribute name="margin-left">
            <xsl:choose>
                <xsl:when test="contains(@outputclass,'pagewide')">
                    -<xsl:value-of select="$side-col-width"/>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:attribute>
		<!-- EMC	IB5		20-Aug-2014		Add shaded background to msgblock -->
		<xsl:attribute name="background-color">#f0f0f0</xsl:attribute>
		<xsl:attribute name="margin-top">16px</xsl:attribute>
		<xsl:attribute name="margin-bottom">16px</xsl:attribute>
		<xsl:attribute name="margin-right">0px</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="userinput" use-attribute-sets="base-font">
        <xsl:attribute name="font-family">Monospaced</xsl:attribute>
		<xsl:attribute name="font-weight">bold</xsl:attribute>
        <xsl:attribute name="font-size"><xsl:value-of select="$default-font-size"/> - 1pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="systemoutput">
		<xsl:attribute name="font-family">Monospaced</xsl:attribute>
        <xsl:attribute name="font-size"><xsl:value-of select="$default-font-size"/></xsl:attribute>
    </xsl:attribute-set>

</xsl:stylesheet>