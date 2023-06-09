<?xml version="1.0" encoding="UTF-8"?>
<!--
This file is part of the DITA Open Toolkit project.

Copyright 2012 Jarno Elovirta

See the accompanying LICENSE file for applicable license.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">
  
  <xsl:import href="dita2postImpl.xsl"/>
  
  <xsl:output method="xml"
				indent="no"
				encoding="UTF-8"
				omit-xml-declaration="yes"/>

  <!-- root rule -->
  <xsl:template match="/">
  
  <xsl:apply-templates/>
  
  </xsl:template>

</xsl:stylesheet>
