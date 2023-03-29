<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the com.citrix.qa project hosted on 
     Sourceforge.net.-->
<!-- (c) Copyright Citrix Systems, Inc. All Rights Reserved. -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" exclude-result-prefixes="fo xs fn">

<xsl:template name="nesting_elements">

<!-- Nesting problems -->
	
<xsl:if test=".//p//note"><li class="incorrectnest"><span>Incorrect nesting Error: </span>NOTE embedded in P element</li></xsl:if>
<xsl:if test=".//p//dl/dlentry"><li class="incorrectnest"><span>Incorrect nesting Error: </span>DL embedded in P element</li></xsl:if>
<xsl:if test=".//p//table and not(.//entry//p//table)"><li class="incorrectnest"><span>Incorrect nesting Error: </span>TABLE embedded in P element</li></xsl:if>
<xsl:if test=".//table//p"><li class="tagwarning"><span>Validator warning: </span>P embedded in TABLE element</li></xsl:if>
<xsl:if test=".//dl//dt[p]"><li class="incorrectnest"><span>Incorrect nesting Error: </span>P embedded inside a DD</li></xsl:if>
<xsl:if test=".//p//ol"><li class="incorrectnest"><span>Incorrect nesting Error: </span>OL embedded in P element</li></xsl:if>
<xsl:if test=".//p//ul"><li class="incorrectnest"><span>Incorrect nesting Error: </span>UL embedded in P element</li></xsl:if>
<xsl:if test=".//ol//p"><li class="tagwarning"><span>Validator warning: </span>P embedded in OL element</li></xsl:if>
<xsl:if test=".//ul//p"><li class="tagwarning"><span>Validator warning: </span>P embedded in UL element</li></xsl:if>
</xsl:template>
</xsl:stylesheet>