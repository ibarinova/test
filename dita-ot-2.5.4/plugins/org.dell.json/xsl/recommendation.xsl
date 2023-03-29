<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot" version="2.0">
    <!-- template for recommendation topics -->
<xsl:template match="*[contains(@class, ' topic/topic ')][contains(@outputclass, 'recommendation')]">
	<xsl:apply-templates select="//*[contains(@class, ' topic/table ')][1]" mode="recommendation"/>
	<xsl:apply-templates select="//*[contains(@class, ' topic/table ')]/*[contains(@class, ' topic/title ')]" mode="tabletitle1"/>
	<xsl:apply-templates select="//*[contains(@class, ' topic/table ')]/*[contains(@class, ' topic/desc ')]" mode="tabledesc"/>
	<xsl:apply-templates select="//*[contains(@class, ' topic/table ')][2]" mode="json"/>
</xsl:template>
		
				
</xsl:stylesheet>

