<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:qa="****Function Processing****" exclude-result-prefixes="fo xs fn qa">
<!-- Use this function to handle the following checks...shows error in xmlspy, but 2.0 should be able to handle xsl:function-->

<xsl:template name="accessibility_errors">
<!--  nshadrina: 11/2018 TKT-666 accessibility errors added -->
<xsl:if test=".//table[not(title)]"><li class="accerror"><span>Accessibility: </span>Table is missing title element.</li></xsl:if>
<xsl:if test=".//table[not(desc)] or .//table/desc[normalize-space()='']"><li class="accerror"><span>Accessibility: </span>table is missing desc element or it is empty</li></xsl:if>

<xsl:if test=".//image[not(alt)] or .//image/alt[normalize-space()='']"><li class="accerror"><span>Accessibility: </span>image does not have an alt tag or alt tag is empty</li></xsl:if>
</xsl:template>
</xsl:stylesheet>