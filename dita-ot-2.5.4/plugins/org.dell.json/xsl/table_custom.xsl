<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot" version="2.0">
    <!-- Table handling -->
  
<xsl:strip-space elements="*"></xsl:strip-space>
  <xsl:template match="*[contains(@class,' topic/table ')]" name="topic.table">
		<xsl:apply-templates select="//table/title" />
		<xsl:apply-templates select="//table/desc"/>
      <xsl:apply-templates select="." mode="json"/>
  </xsl:template>

<xsl:template match="*[contains(@class, ' topic/tgroup ')]"/>
<xsl:template match="*[contains(@class, ' topic/colspec ')]"/>    
<xsl:variable name="quote">"</xsl:variable>
    <xsl:template match="*[contains(@class, ' topic/table ')]" mode="json">
    <xsl:variable name="cols" select="tgroup/thead/row/entry" />
    <xsl:choose>
    <xsl:when test="@outputclass = 'views'">
    <xsl:text>"views":</xsl:text>[
    <xsl:for-each select="tgroup/tbody/row">
        {
		<xsl:for-each select="entry">
            <xsl:variable name="i" select="position()" />
            "<xsl:value-of select="normalize-space($cols[$i])" />"<xsl:text>: </xsl:text>
            <xsl:choose>
            <xsl:when test="*[contains(@class, ' topic/image ')]" >
            <xsl:apply-templates/><xsl:if test="position() != last()" >,</xsl:if>
            </xsl:when>
			<xsl:when test="*[contains(@class, ' topic/xref ')]" >
            <xsl:apply-templates select="*[contains(@class, ' topic/xref ')]"/><xsl:if test="position() != last()" >,</xsl:if>
            </xsl:when>
            <xsl:when test="*[contains(@class, ' topic/p ')]">
            [
            <xsl:for-each select="p">
            "<xsl:value-of select="normalize-space(.)"/>"<xsl:if test="position() != last()" >,</xsl:if>
			</xsl:for-each>
            ]
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>"</xsl:text><xsl:value-of select="normalize-space(.)"/><xsl:text>"</xsl:text><xsl:if test="position() != last()" ><xsl:text>,</xsl:text></xsl:if>
			</xsl:otherwise>
            </xsl:choose>
            
        </xsl:for-each>
        <xsl:text>}</xsl:text><xsl:if test="position() != last()" ><xsl:text>,</xsl:text></xsl:if>
    </xsl:for-each><xsl:text>]</xsl:text>
    
    </xsl:when>
	<xsl:when test="@outputclass = 'items'">
    <xsl:text>"items":</xsl:text>[
    <xsl:for-each select="tgroup/tbody/row">
        <xsl:text>{</xsl:text><xsl:for-each select="entry">
            <xsl:variable name="i" select="position()" />
            "<xsl:value-of select="normalize-space($cols[$i])" />"<xsl:text>: </xsl:text>
            <xsl:choose>
			<xsl:when test="*[contains(@class, ' topic/xref ')]">
            <xsl:apply-templates select="*[contains(@class, ' topic/xref ')]"/><xsl:if test="position() != last()" >,</xsl:if>
            </xsl:when>
            <xsl:when test="*[contains(@class, ' topic/image ')]" >
            <xsl:apply-templates/><xsl:if test="position() != last()" >,</xsl:if>
            </xsl:when>
            <xsl:when test="*[contains(@class, ' topic/p ')]">
            <xsl:text>[</xsl:text>
            <xsl:for-each select="p">
            "<xsl:value-of select="normalize-space(.)"/>"<xsl:if test="position() != last()" >,</xsl:if>
			</xsl:for-each>
            <xsl:text>]</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>"</xsl:text><xsl:value-of select="normalize-space(.)"/><xsl:text>"</xsl:text><xsl:if test="position() != last()" ><xsl:text>,</xsl:text></xsl:if>
			</xsl:otherwise>
            </xsl:choose>
            
        </xsl:for-each>
        <xsl:text>}</xsl:text><xsl:if test="position() != last()" ><xsl:text>,</xsl:text></xsl:if>
    </xsl:for-each><xsl:text>]</xsl:text>
    
    </xsl:when>
		
    <xsl:otherwise>
	<xsl:text>[</xsl:text>
    <xsl:for-each select="tgroup/tbody/row">
        <xsl:text>{</xsl:text>
		<xsl:for-each select="entry">
         <xsl:variable name="i" select="position()" />
            <xsl:text>"</xsl:text><xsl:value-of select="normalize-space($cols[$i])"/>" <xsl:text>:</xsl:text> 
            <xsl:choose>
			<xsl:when test="*[contains(@class, ' topic/xref ')]" >
            "<xsl:apply-templates select="*[contains(@class, ' topic/xref ')]"/>"<xsl:if test="position() != last()" >,</xsl:if>
            </xsl:when>
            <xsl:when test="*[contains(@class, ' topic/image ')]">
            <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>"</xsl:text><xsl:value-of select="normalize-space(.)"/><xsl:text>"</xsl:text><xsl:if test="position() != last()" ><xsl:text>,</xsl:text></xsl:if>
            </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each> 
        <xsl:text>}</xsl:text><xsl:if test="position() != last()" ><xsl:text>,</xsl:text></xsl:if>
    </xsl:for-each>
	<xsl:text>]</xsl:text>
    </xsl:otherwise>
    </xsl:choose>
    </xsl:template>
<xsl:template  match="*[contains(@class, ' topic/table ')]" mode="recommendation">
<xsl:variable name="cols" select="tgroup/thead/row/entry" />
    <xsl:choose>
<xsl:when test="@outputclass = 'recommendation'">
    <xsl:for-each select="tgroup/tbody/row">
        <xsl:text>"recommendation":</xsl:text>
		<xsl:text>{</xsl:text>
		<xsl:for-each select="entry">
            <xsl:variable name="i" select="position()" />
            "<xsl:value-of select="normalize-space($cols[$i])" />"<xsl:text>: </xsl:text>
            <xsl:choose>
            <xsl:when test="*[contains(@class, ' topic/image ')]" >
            <xsl:apply-templates/><xsl:if test="position() != last()" >,</xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>"</xsl:text><xsl:value-of select="normalize-space(.)"/><xsl:text>"</xsl:text><xsl:if test="position() != last()" ><xsl:text>,</xsl:text></xsl:if>
			</xsl:otherwise>
            </xsl:choose>
            
        </xsl:for-each>
		<xsl:text>}</xsl:text>,
        <xsl:if test="position() != last()" ><xsl:text>,</xsl:text></xsl:if>
    </xsl:for-each>
    
    </xsl:when>
</xsl:choose>

</xsl:template>

<xsl:template name="tabletitle" match="*[contains(@class, ' topic/table ')]/*[contains(@class, ' topic/title ')]" mode="tabletitle1">
    <xsl:text>"Title":</xsl:text> "<xsl:value-of select="."/>",
</xsl:template>
<xsl:template name="tabledesc" match="*[contains(@class, ' topic/table ')]/*[contains(@class, ' topic/desc ')]" mode="tabledesc">
     <xsl:text>"description":</xsl:text> "<xsl:value-of select="normalize-space(.)"/>",
</xsl:template>
</xsl:stylesheet>