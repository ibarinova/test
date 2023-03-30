<?xml version='1.0'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:dita2xslfo="http://dita-ot.sourceforge.net/ns/200910/dita2xslfo"
    xmlns:opentopic="http://www.idiominc.com/opentopic"
    xmlns:opentopic-index="http://www.idiominc.com/opentopic/index"
    exclude-result-prefixes="opentopic opentopic-index dita2xslfo"
    version="2.0">
    <!-- 
        Revision History
        ================
		EMC 		IB7	  	19-Jan-2015   TKT-73: Increase spacing after <info> tag
    -->
	
    <!--Ordered steps-->
    <!-- Suite/EMC   SOW7  14-Feb-2013 remove extra space before auto generated title - AW --> 
	<!-- EMC   		 IB3   14-Nov-2013 Issue 347: Task <substep> spacing should match <steps> spacing 6.5pt -->
    <xsl:attribute-set name="steps" use-attribute-sets="ol">
        <xsl:attribute name="space-before.optimum">6.5pt</xsl:attribute>
		<xsl:attribute name="space-after.optimum">6.5pt</xsl:attribute>
    </xsl:attribute-set>
    <!--Unordered steps-->
    <!-- Natasha    IB2 25-Jun-2013 formatting similar to ordered steps-->
	<!-- EMC   		 IB3   14-Nov-2013 Issue 347: Task <substep> spacing should match <steps> spacing 6.5pt -->
    <xsl:attribute-set name="steps-unordered" use-attribute-sets="ul">
        <xsl:attribute name="space-before.optimum">6.5pt</xsl:attribute>
		<xsl:attribute name="space-after.optimum">6.5pt</xsl:attribute>
    </xsl:attribute-set>
    
    <xsl:attribute-set name="context" use-attribute-sets="section">
	        <xsl:attribute name="line-height">12pt</xsl:attribute>
        <xsl:attribute name="space-before">
            <xsl:choose>
                <xsl:when test="count(*) = 0 and normalize-space()=''">0pt</xsl:when>
                <xsl:otherwise>0.6em</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="font-size"><xsl:value-of select="$default-font-size"/></xsl:attribute>
    </xsl:attribute-set>	
	
	<xsl:attribute-set name="prereq-space">
	<xsl:attribute name="space-before.optimum">6pt</xsl:attribute>
    </xsl:attribute-set>
	
		<xsl:attribute-set name="context-space">
	<xsl:attribute name="space-before.optimum">6pt</xsl:attribute>
    </xsl:attribute-set>
		<xsl:attribute-set name="result-space">
	<xsl:attribute name="space-before.optimum">6pt</xsl:attribute>
    </xsl:attribute-set>
	<xsl:attribute-set name="example-space">
	<xsl:attribute name="space-before.optimum">6pt</xsl:attribute>
    </xsl:attribute-set>
	<xsl:attribute-set name="postreq-space">
	<xsl:attribute name="space-before.optimum">6pt</xsl:attribute>
    </xsl:attribute-set>
	

	<!-- Balaji Mani 2-Apr-2013: added for the sapce -->
	<!-- EMC 	IB7	  19-Jan-2015 	 TKT-73: Increase spacing after <info> tag -->
    <xsl:attribute-set name="cmd">
		<xsl:attribute name="space-after.optimum">6pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="info">
	<xsl:attribute name="space-before.optimum"><xsl:choose><xsl:when test="preceding-sibling::*[1][name()='cmd']">0</xsl:when><xsl:otherwise>6</xsl:otherwise></xsl:choose>pt</xsl:attribute>
        <xsl:attribute name="space-after.optimum">6pt</xsl:attribute>
		<xsl:attribute name="padding-bottom">2pt</xsl:attribute>
    </xsl:attribute-set>

	  <xsl:attribute-set name="task.label">
        <xsl:attribute name="font-family">Sans</xsl:attribute>
        <xsl:attribute name="font-weight">bold</xsl:attribute>
        <xsl:attribute name="space-before.optimum"><xsl:choose><xsl:when test="(name()='steps' and normalize-space(preceding-sibling::context)='') or (name()='steps' and not(preceding-sibling::context))">0</xsl:when><xsl:otherwise>6</xsl:otherwise></xsl:choose>pt</xsl:attribute>
        <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
    </xsl:attribute-set>

	<!-- EMC   		 IB3   14-Nov-2013 Issue 347: Task <substep> spacing should match <steps> spacing 6.5pt -->
    <!--Substeps-->	
    <xsl:attribute-set name="substeps" use-attribute-sets="ol">
        <xsl:attribute name="provisional-distance-between-starts">5mm</xsl:attribute>
        <xsl:attribute name="provisional-label-separation">1mm</xsl:attribute>
        <xsl:attribute name="space-after.optimum">6.5pt</xsl:attribute>
        <xsl:attribute name="space-before.optimum">6.5pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="substeps.substep" use-attribute-sets="ol.li">
        <xsl:attribute name="space-after.optimum">6.5pt</xsl:attribute>
        <xsl:attribute name="space-before.optimum">6.5pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="stepsection__body" use-attribute-sets="ul.li__body">
        <xsl:attribute name="start-indent" select="$side-col-width"/>
    </xsl:attribute-set>

</xsl:stylesheet>