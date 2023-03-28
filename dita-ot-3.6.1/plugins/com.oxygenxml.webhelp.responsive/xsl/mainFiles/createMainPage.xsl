<?xml version="1.0" encoding="UTF-8"?><!--
    
Oxygen Webhelp plugin
Copyright (c) 1998-2022 Syncro Soft SRL, Romania.  All rights reserved.

--><xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:toc="http://www.oxygenxml.com/ns/webhelp/toc" xmlns:oxygen="http://www.oxygenxml.com/functions" xmlns:index="http://www.oxygenxml.com/ns/webhelp/index" exclude-result-prefixes="#all" version="2.0">
    
  <xsl:import href="createMainPageImpl.xsl"/>

  <!--
    XSLT extension point for the stylesheet used to produce the main HTML page 
    in the Webhelp Responsive transformation. 
  -->
  
  
  <!-- WH-1439 xsl/com.oxygenxml.webhelp.xsl.createMainPage extension point -->
  <xsl:import xmlns:dita="http://dita-ot.sourceforge.net" href="template:xsl/com.oxygenxml.webhelp.xsl.createMainPage"/>  
</xsl:stylesheet>