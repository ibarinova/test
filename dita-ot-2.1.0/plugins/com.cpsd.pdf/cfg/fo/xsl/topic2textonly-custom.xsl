<?xml version="1.0"?>
<!-- This file is part of the DITA Open Toolkit project hosted on 
     Sourceforge.net. See the accompanying license.txt file for 
     applicable licenses.-->
<!-- (c) Copyright IBM Corporation 2010. All Rights Reserved. -->
<xsl:stylesheet version="2.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
  exclude-result-prefixes="dita-ot"
  >
  
  <!-- mckimn 25-April-2017 prepend brand name to content wrapped in keyword with outputclass="prodname" -->
  <xsl:template match="*[contains(@class,' topic/keyword ')][@outputclass='branded']" mode="dita-ot:text-only">
    <xsl:value-of select="$BRAND-TEXT"/>
    <xsl:apply-templates mode="dita-ot:text-only"/>
  </xsl:template>
  
</xsl:stylesheet>
