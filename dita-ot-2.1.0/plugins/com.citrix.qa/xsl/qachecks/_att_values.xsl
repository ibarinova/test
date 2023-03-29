<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the com.citrix.qa project hosted on 
     Sourceforge.net.-->
<!-- (c) Copyright Citrix Systems, Inc. All Rights Reserved. -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" >

<xsl:template name="att_values">

<!-- List variables found in the topic -->
<xsl:if test=".//*[exists(@otherprops)]"><li class="tagwarning">Validator Warning: @otherprops values should not be used. Conditions are handled through Trisoft ishconditions.</li></xsl:if>
<xsl:if test=".//*[exists(@audience)]"><li class="tagwarning">Validator Warning: @audience values should not be used. Conditions are handled through Trisoft ishconditions.</li></xsl:if>
<xsl:if test=".//*[exists(@platform)]"><li class="tagwarning">Validator Warning: @platform values should not be used. Conditions are handled through Trisoft ishconditions.</li></xsl:if>
<xsl:if test=".//*[exists(@product)]"><li class="tagwarning">Validator Warning: @product values should not be used. Conditions are handled through Trisoft ishconditions.</li></xsl:if>


<!-- Unsupported outputclass attributes: Added by jholmber 11-27-2012
<xsl:if test=".//*[exists(@outputclass) and not(@outputclass='landscape') and not(@outputclass='nopagebreak') and not(@outputclass='pagebreak') and not(@outputclass='pagewide') and not(@outputclass='show_hide') and not(@outputclass='show_hide_expanded')] ">
	<li class="tagerror">Validator Error: Unsupported outputclass attribute value(s):&#160; 
		 
		  <xsl:for-each select=".//*[exists(@outputclass) and not(@outputclass='landing_page') and not(@outputclass='landscape') and not(@outputclass='nochap') and not(@outputclass='nopagebreak') and not(@outputclass='pagebreak') and not(@outputclass='pagewide') and not(@outputclass='rsa') and not(@outputclass='confidential') and not(@outputclass='show_hide') and not(@outputclass='show_hide_expanded')]/@outputclass">   
		    
		      <xsl:value-of select="."/>&#160;
		    
		  </xsl:for-each>
		
	</li>
</xsl:if> -->


</xsl:template>
</xsl:stylesheet>