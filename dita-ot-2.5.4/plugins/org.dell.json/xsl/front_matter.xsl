<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot" version="2.0">
    <!-- Table handling -->
<!--process topic title based on output class-->
<xsl:template match="*[contains(@class, ' topic/topic ')]/*[contains(@class, ' topic/title ')]">
	<xsl:if test="contains(@outputclass, 'recinner')">
	<xsl:text>"title":</xsl:text>"<xsl:value-of select="concat(upper-case(substring(.,1,1)),substring(., 2),''[not(last())])"/>",
	</xsl:if>
</xsl:template>
<!--process topic body based on outputclass-->
<xsl:template match="*[contains(@class, ' topic/body ')][contains(@outputclass, 'recinner')]" >
	<xsl:text>"items":</xsl:text>
	[
	<xsl:apply-templates/>
	]
</xsl:template>
<!--process DL-->
<xsl:template name="ddimage" match="*[contains(@class, ' topic/dd ')]/*[contains(@class, ' topic/image ')]">
	<xsl:apply-templates/>
</xsl:template>
<!--process DL within section-->
<xsl:template  match="*[contains(@class, ' topic/section ')]">
	<xsl:text>{</xsl:text>
	<xsl:for-each select="dl/dlentry">
	"<xsl:value-of select="normalize-space(*[contains(@class, ' topic/dt ')])"/>":"<xsl:value-of select="normalize-space(*[contains(@class, ' topic/dd ')])"/><xsl:call-template name="ddimage"/>",
	</xsl:for-each>
	<xsl:apply-templates select="*[contains(@class, ' topic/table ')]" mode="json"/>			
	<xsl:text>}</xsl:text><xsl:if test="position() != last()">,</xsl:if>
</xsl:template>
<!--skip first navigation title-->
<xsl:template match="*[contains(@class,' topic/titlealts ')]/*[contains(@class,' topic/navtitle ')]">
	<xsl:text>"name":</xsl:text>"<xsl:value-of select="normalize-space(.)"/>",
</xsl:template>
<!--process shortdesc based on outputclass-->
<xsl:template match="*[contains(@class,' topic/shortdesc ')]">
	<xsl:choose>
		<xsl:when test= "parent::*[contains(@outputclass, 'recinner')]">
			<xsl:text>"type":</xsl:text>"<xsl:value-of select="normalize-space(.)"/>",
		</xsl:when>
		<xsl:otherwise>
			<xsl:text>"desc":</xsl:text>"<xsl:value-of select="normalize-space(.)"/>",
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>
<!--process abstract -->
<xsl:template match="*[contains(@class,' topic/abstract ')]">
	<xsl:text>"desc":</xsl:text>"<xsl:value-of select="normalize-space(.)"/>",
</xsl:template>
</xsl:stylesheet>

