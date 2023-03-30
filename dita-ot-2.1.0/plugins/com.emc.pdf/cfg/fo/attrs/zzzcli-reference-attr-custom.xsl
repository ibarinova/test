<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    version="2.0">
  <!-- Added by Tom Dill 11/09/2011 to support CLI attribute set needed in syntax_custom.xsl -->  
  <xsl:attribute-set name="cli_common">
        <xsl:attribute name="space-after">15pt</xsl:attribute>
        <xsl:attribute name="space-before">0pt</xsl:attribute>
        <xsl:attribute name="margin-left">15pt</xsl:attribute>
        <xsl:attribute name="keep-with-previous">always</xsl:attribute>
		<!-- EMC	28-Oct-2013		IB3		Issues 362: CLI elements to have the default font size -->
        <xsl:attribute name="font-size"><xsl:value-of select="$default-font-size"/></xsl:attribute>
      </xsl:attribute-set>
    
    <!-- Suite Jan-2012: Added cli_value attribute-set for formatting cli_option_value, cli_arg_value, cli_param_value - rs -->
    <xsl:attribute-set name="cli_value" use-attribute-sets="p">
        <xsl:attribute name="margin-left">-15pt</xsl:attribute>
		<!-- EMC	28-Oct-2013		IB3		Issues 362: CLI elements to have the default font size -->
        <xsl:attribute name="font-size"><xsl:value-of select="$default-font-size"/></xsl:attribute>
        <xsl:attribute name="line-height">12pt</xsl:attribute>
        <xsl:attribute name="space-before.optimum">9.00pt</xsl:attribute>
        <xsl:attribute name="space-after.optimum">6.00pt</xsl:attribute>
        <xsl:attribute name="font-family">SansCondBoldRoman</xsl:attribute>
        <xsl:attribute name="widows">2</xsl:attribute>
        <xsl:attribute name="orphans">2</xsl:attribute>
    </xsl:attribute-set>
    
    <!-- Suite Jan-2012: Added cli_desc attribute-set for formatting cli_option_desc, cli_arg_desc, cli_param_desc - rs -->
    <xsl:attribute-set name="cli_desc" use-attribute-sets="p">
        <xsl:attribute name="margin-left">2pt</xsl:attribute>
		<!-- EMC	28-Oct-2013		IB3		Issues 362: CLI elements to have the default font size -->
        <xsl:attribute name="font-size"><xsl:value-of select="$default-font-size"/></xsl:attribute>
        <xsl:attribute name="line-height">12pt</xsl:attribute>
        <xsl:attribute name="space-before.optimum">9.00pt</xsl:attribute>
        <xsl:attribute name="space-after.optimum">6.00pt</xsl:attribute>
        <xsl:attribute name="widows">2</xsl:attribute>
        <xsl:attribute name="orphans">2</xsl:attribute>
    </xsl:attribute-set>
 	 
	<xsl:attribute-set name="codeblock__top">
        <xsl:attribute name="leader-pattern">rule</xsl:attribute>
        <xsl:attribute name="leader-length">100%</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="codeblock__bottom">
        <xsl:attribute name="leader-pattern">rule</xsl:attribute>
        <xsl:attribute name="leader-length">100%</xsl:attribute>
    </xsl:attribute-set>

	<xsl:attribute-set name="cli_example.title">    
		<xsl:attribute name="font-family">SansLFRoman</xsl:attribute>
		<xsl:attribute name="font-size">9pt</xsl:attribute>
		<xsl:attribute name="font-weight">normal</xsl:attribute>
		<xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
		<xsl:attribute name="space-before">5pt</xsl:attribute>
		<xsl:attribute name="padding-bottom">5pt</xsl:attribute>
		<xsl:attribute name="text-align-last">left</xsl:attribute>
		<xsl:attribute name="padding-top">5pt</xsl:attribute>
  </xsl:attribute-set>

</xsl:stylesheet>
