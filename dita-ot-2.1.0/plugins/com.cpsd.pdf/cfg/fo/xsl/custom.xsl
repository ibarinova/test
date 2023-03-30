<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    version="2.0">
   
    <xsl:import href="../layout-masters-custom.xsl"/>
    
    <xsl:import href="bookmarks-custom.xsl"/>
    <xsl:import href="commons-custom.xsl"/>
    <xsl:import href="front-matter-custom.xsl"/>
    <xsl:import href="glossary-custom.xsl"/>
    <xsl:import href="index-custom.xsl"/>
    <xsl:import href="links-custom.xsl"/>
    <xsl:import href="lists-custom.xsl"/>
    <xsl:import href="lot-lof-custom.xsl"/>
    <xsl:import href="pr-domain-custom.xsl"/>
    <xsl:import href="preface-custom.xsl"/>
    <xsl:import href="reference-elements-custom.xsl"/>
    <xsl:import href="root-processing-custom.xsl"/>
    <xsl:import href="static-content-custom.xsl"/>
    <xsl:import href="sw-domain-custom.xsl"/>
    <xsl:import href="tables-custom.xsl"/>
    <xsl:import href="task-elements-custom.xsl"/>
    <xsl:import href="toc-custom.xsl"/>
    <xsl:import href="topic2textonly-custom.xsl"/>
    <xsl:import href="ui-domain-custom.xsl"/>
    <xsl:import href="zzzcli-reference-custom.xsl"/>

    <!-- customizations of SDL-provided templates -->
    <xsl:import href="trisoft/infoshare.array.xsl"/>
    <xsl:import href="trisoft/infoshare.dita2fo.diff.xsl"/>
    <xsl:import href="trisoft/infoshare.I18N.xsl"/>
    <xsl:import href="trisoft/infoshare.jobticket.xsl"/>
    <xsl:import href="trisoft/infoshare.metadata.xsl"/>
    <xsl:import href="trisoft/infoshare.template.xsl"/>
	<xsl:import href="trisoft/infoshare.params.xsl"/>
    
</xsl:stylesheet>
