<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot" version="2.0">
    <!-- Table handling -->

<xsl:template match="*[contains(@class, ' topic/li ')]">
"<xsl:value-of select="normalize-space(.)"/>"<xsl:if test="position() != last()">,</xsl:if>  
</xsl:template>


<!--template for processing tutorial topics and convert to json format-->

<xsl:template match="*[contains(@class, ' topic/topic ')][contains(@outputclass, 'tutorial')]" priority="5">
		<xsl:text>[</xsl:text>
		<xsl:for-each select="descendant::*[contains(@class, ' topic/section ')]">
			<xsl:text>{</xsl:text>
			<xsl:text>"option":</xsl:text> "<xsl:value-of select="*[contains(@class, 'topic/title')]"/>",
			<xsl:text>"tutorialInfo":</xsl:text>{
			<xsl:text>"label":</xsl:text>"<xsl:value-of select="*[contains(@class, ' sw-d/msgblock ')]"/>",
			<xsl:text>"caption":</xsl:text>"<xsl:apply-templates select="*[contains(@class, ' topic/ph ')]/*[contains(@class, ' topic/xref ')]"/>",
			<xsl:text>"stepCount":</xsl:text>"<xsl:value-of select="count(*[contains(@class, 'topic/ol')]/*[contains(@class, ' topic/li')])"/> steps",
			<xsl:text>"imageUrl":</xsl:text><xsl:apply-templates select="*[contains(@class, ' topic/image ')]"/>,
			<xsl:text>"steps":</xsl:text>[
			<xsl:apply-templates select="*[contains(@class, 'topic/ol')]"/>
			],
			<xsl:text>"pauses":</xsl:text>[
			<xsl:apply-templates select="*[contains(@class, 'topic/ul')]"/> 
			]
			}
			<xsl:apply-templates select="//table/title" mode="tabletitle1"/>
			<xsl:apply-templates select="//table/desc" mode="tabledesc"/>
			<xsl:apply-templates select="//table" mode="json"/>

<xsl:text>}</xsl:text><xsl:if test="position() != last()">,</xsl:if>
    
</xsl:for-each>
<xsl:text>]</xsl:text></xsl:template>				
<!--template for processing FAQ topics-->	
<xsl:template match="*[contains(@class, ' topic/topic ')][contains(@outputclass, 'faq')]" priority="5">
		<xsl:text>[</xsl:text><xsl:for-each select="descendant::*[contains(@class, ' topic/section ')]">
		
			<xsl:text>{</xsl:text>
			<xsl:text>"option":</xsl:text> "<xsl:value-of select="*[contains(@class, 'topic/title')]"/>",
			<xsl:text>"tutorialInfo":</xsl:text>{
			<xsl:text>"caption":</xsl:text>"<xsl:apply-templates select="*[contains(@class, ' topic/ph ')]/*[contains(@class, ' topic/xref ')]"/>",
			<xsl:text>"label":</xsl:text>[<xsl:apply-templates select="*[contains(@class, 'topic/ol')][1]"/>],
			<xsl:text>"steps":</xsl:text>[
			<xsl:apply-templates select="*[contains(@class, 'topic/ol')][2]"/>
			],
			<xsl:text>"pauses":</xsl:text>[
			<xsl:apply-templates select="*[contains(@class, 'topic/ul')]"/> 
			<xsl:text>]</xsl:text>
			<xsl:text>}</xsl:text>
			<xsl:apply-templates select="//table/title" mode="tabletitle1"/>
			<xsl:apply-templates select="//table/desc" mode="tabledesc"/>
			<xsl:apply-templates select="//table" mode="json"/>

<xsl:text>}</xsl:text><xsl:if test="position !=last()">,</xsl:if>
    
</xsl:for-each>
<xsl:text>]</xsl:text>   
</xsl:template>
					
<xsl:template match="*[contains(@class, 'topic/ul')]"><xsl:apply-templates/></xsl:template>
<xsl:template match="*[contains(@class, 'topic/ol')]"><xsl:apply-templates/></xsl:template>
<xsl:template match="*[contains(@class, 'topic/section')]/*[contains(@class, 'topic/title')]">
	<xsl:apply-templates/>
</xsl:template>
</xsl:stylesheet>

