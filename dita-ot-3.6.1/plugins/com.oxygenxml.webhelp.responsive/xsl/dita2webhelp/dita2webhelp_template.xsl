<?xml version="1.0" encoding="UTF-8"?>
<!--
    
Oxygen Webhelp plugin
Copyright (c) 1998-2022 Syncro Soft SRL, Romania.  All rights reserved.

-->

<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:relpath="http://dita2indesign/functions/relpath"
  xmlns:toc="http://www.oxygenxml.com/ns/webhelp/toc"
  xmlns:oxygen="http://www.oxygenxml.com/functions"
  exclude-result-prefixes="#all"
  version="2.0">
  
  <xsl:import href="dita2webhelpImpl.xsl"/>
  
  <!--
    XSLT extension point for the stylesheet used to produce an HTML file for each DITA topic. 
  -->
  <dita:extension 
    id="com.oxygenxml.webhelp.xsl.dita2webhelp" 
    behavior="org.dita.dost.platform.ImportXSLAction" 
    xmlns:dita="http://dita-ot.sourceforge.net"/>
  
  <!-- WH-1439 com.oxygenxml.webhelp.xsl.dita2webhelp extension point -->
  <xsl:import href="template:xsl/com.oxygenxml.webhelp.xsl.dita2webhelp"/>
</xsl:stylesheet>