<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the com.citrix.qa project hosted on 
     Sourceforge.net.-->
<!-- (c) Copyright Citrix Systems, Inc. All Rights Reserved. -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">

<xsl:template name="nesting_elements">

<!-- Nesting problems -->
<xsl:if test=".//p//ol/li"><li class="tagwarning">Validator Warning: OL embedded in P element</li></xsl:if>
<xsl:if test=".//p//ul/li"><li class="tagwarning">Validator Warning: UL embedded in P element</li></xsl:if>
<xsl:if test=".//p//note"><li class="tagwarning">Validator Warning: NOTE embedded in P element</li></xsl:if>
<xsl:if test=".//p//dl/dlentry"><li class="tagwarning">Validator Warning: DL embedded in P element</li></xsl:if>
<xsl:if test=".//p//simpletable"><li class="tagwarning">Validator Warning: SimpleTable embedded in P element</li></xsl:if>
<xsl:if test=".//dl//simpletable"><li class="tagwarning">Validator Warning: SimpleTable embedded in DL element</li></xsl:if>
<xsl:if test=".//p//table"><li class="tagwarning">Validator Warning: TABLE embedded in P element</li></xsl:if>
<xsl:if test=".//dl//table"><li class="tagerror">Validator Error: TABLE embedded in DL element</li></xsl:if>
<xsl:if test=".//dl//dd[p]"><li class="tagerror">Validator Error: P embedded inside a DD</li></xsl:if>
<xsl:if test=".//dl//dt[p]"><li class="tagerror">Validator Error: P embedded inside a DT</li></xsl:if>
<xsl:if test=".//dl//dl//dl"><li class="tagwarning">Validator Warning: DL element nesting is two levels or greater.</li></xsl:if>
<xsl:if test=".//simpletable//stentry[p]"><li class="tagwarning">Validator Warning: P embedded inside a simpletable</li></xsl:if>
<xsl:if test=".//table//entry[p]"><li class="tagwarning">Validator Warning: P embedded inside a table entry</li></xsl:if>



</xsl:template>
</xsl:stylesheet>