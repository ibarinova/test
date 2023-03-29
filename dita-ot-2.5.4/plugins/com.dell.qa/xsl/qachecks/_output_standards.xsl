<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the com.citrix.qa project hosted on 
     Sourceforge.net.-->
<!-- (c) Copyright Citrix Systems, Inc. All Rights Reserved. -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" exclude-result-prefixes="fo xs fn">

  
<xsl:template name="output_standards">

<!-- Stuff to make the output work -->
<!-- <xsl:if test="//concept[not(prolog)]|//task[not(prolog)]"><li class="ditaerror">Topic does not include a prolog</li></xsl:if> -->
<!-- <xsl:if test=".//draft-comment[not(@otherprops='DraftStatusOn')]"><li class="info"><span>INFO: </span>Draft-Comment does not have DraftStatusOn</li></xsl:if> -->
<xsl:if test=".//bookmap[not(@linking='none')]"><li class="metaerror"><span>Metadata Error: </span>BOOKMAP does not have attribute linking as none</li></xsl:if>
<xsl:if test=".//dlentry/dd[position()>1]"><li class="incorrectnest"><span>Incorrect nesting Error: </span>DLEntry has more than one definition (DD)</li></xsl:if>
<xsl:if test=".//row[not(node())]"><li class="missingcontent"><span>Missing content Error: </span>Delete empty table rows</li></xsl:if>
<xsl:if test=".//*[contains(translate(@outputclass,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'pagebreak')]"><li class="tagwarning"><span>Validator warning: </span>Confirm proper use of outputclass=”pagebreak” for <xsl:value-of select="name()"/> element</li></xsl:if>

<!--<xsl:if test=".[not(@xml:lang)]|//task[not(@xml:lang)]|//reference[not(@xml:lang)]"><li class="tagerror"><span>ERROR: </span>Topic does not have xml:lang attribute set on element: <xsl:value-of select="./@xtrc"/></li></xsl:if>
-->

</xsl:template>
</xsl:stylesheet>