<?xml version="1.0"?>


<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
  <!-- 
    Revision History
    ================  
	EMC 		 25-Oct-2013	Issue 348: Turn off hyphenation in <synph> and <syntaxdiagram> elements
    EMC		IB3	 28-Oct-2013  	Issue 320, 362: Font size change for codeph, codeblock, synph, kwd, delim, oper, sep, option, parmname, var
	EMC		IB5	 20-Aug-2014	Add shaded background to codeblock
	EMC		Hotfix_3.2 		10-Jun-2015		TKT 214 Formatting of embedded parameter list should be similar to definition list
  -->
  
    <!-- Suite Jan-2012: updated formatting -->
    <xsl:attribute-set name="codeph">
        <xsl:attribute name="font-family">Monospaced</xsl:attribute>
        <xsl:attribute name="word-spacing">0pt</xsl:attribute>
		<!-- Balaji Mani PDF Bundle 6-May-2013: codeph as inline element so before and after space is not needed -->
        <xsl:attribute name="space-before.optimum">0pt</xsl:attribute>
        <xsl:attribute name="space-after.optimum">0pt</xsl:attribute>
		<xsl:attribute name="font-size">inherited-property-value(&apos;font-size&apos;)</xsl:attribute> 
    </xsl:attribute-set>

    <!-- Nathan McKimpson 10/25/2012: Add outputclass="pagewide" support for codeblock elements -->
	<!-- Balaji Mani PDF Bundle 1-Apr-2013: conmmented the backgoud color and updated the font -->
    <!-- Natasha IB2 07-12-13 Changed "MonospacedNew" to "Monospaced" that now has Courier New font -->
    <xsl:attribute-set name="codeblock" use-attribute-sets="pre">
        <xsl:attribute name="space-before">0.4em</xsl:attribute>
        <xsl:attribute name="space-after">0.8em</xsl:attribute>
        <xsl:attribute name="white-space-treatment">preserve</xsl:attribute>
        <xsl:attribute name="white-space-collapse">false</xsl:attribute>
        <xsl:attribute name="linefeed-treatment">preserve</xsl:attribute>
        <xsl:attribute name="wrap-option">wrap</xsl:attribute>
        <xsl:attribute name="font-family">Monospaced</xsl:attribute>
        <xsl:attribute name="line-height">106%</xsl:attribute>
        <xsl:attribute name="font-size">
			<xsl:choose>
                <xsl:when test="ancestor::*[contains(@class,' topic/note ') or contains(@class,' topic/entry ') or contains(@class,' topic/stentry ')]"><xsl:value-of select="$default-font-size"/> - 2pt</xsl:when>
                <xsl:otherwise><xsl:value-of select="$default-font-size"/> - 1pt</xsl:otherwise>
            </xsl:choose>
		</xsl:attribute>
        <xsl:attribute name="keep-with-previous.within-page">always</xsl:attribute>
        <!--        &lt;xsl:attribute name=&quot;keep-together.within-page&quot;&gt;always&lt;/xsl:attribute&gt;-->
        <xsl:attribute name="margin-left">
            <xsl:choose>
                <xsl:when test="contains(@outputclass,'pagewide')">
                    -<xsl:value-of select="$side-col-width"/>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:attribute>
		<!-- EMC	IB5		20-Aug-2014		Add shaded background to codeblock -->
		<xsl:attribute name="background-color">#f0f0f0</xsl:attribute>
		<xsl:attribute name="margin-top">16px</xsl:attribute>
		<xsl:attribute name="margin-bottom">16px</xsl:attribute>
		<xsl:attribute name="margin-right">0px</xsl:attribute>		
		<!--xsl:attribute name="padding-top">8px</xsl:attribute>
		<xsl:attribute name="padding-left">16px</xsl:attribute>
		<xsl:attribute name="padding-right">0px</xsl:attribute>
		<xsl:attribute name="padding-bottom">8px</xsl:attribute-->
    </xsl:attribute-set>
   
    <!-- Suite Jan-2012: updated formatting -->
    <xsl:attribute-set name="synph">
        <xsl:attribute name="font-family">Monospaced</xsl:attribute>
		<xsl:attribute name="font-size">inherited-property-value(&apos;font-size&apos;)</xsl:attribute> 
        <!-- EMC 	25-Oct-2013		Issue 348: Turn off hyphenation in <synph> and <syntaxdiagram> elements -->
        <!--<xsl:attribute name="hyphenate">true</xsl:attribute>
        <xsl:attribute name="hyphenation-character"></xsl:attribute> -->
    </xsl:attribute-set>
    
    <!-- Suite Jan-2012: updated formatting -->
    <!-- Nathan McKimpson 24-May-2013: remove italic for ZH-TW and ZH-CN -->
    <xsl:attribute-set name="var">
        <xsl:attribute name="font-style">
          <xsl:choose>
              <xsl:when test="$locale = 'ja' or $locale = 'zh_TW' or $locale = 'zh_CN'">normal</xsl:when>
            <xsl:otherwise>italic</xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
       <xsl:attribute name="font-size">inherited-property-value(&apos;font-size&apos;)</xsl:attribute>
	   <xsl:attribute name="font-family">inherit</xsl:attribute>
		<!-- Balaji Mani PDF Bundle 25-Feb-2013: comment the font -->
        <!-- <xsl:attribute name="font-family">Monospaced</xsl:attribute> -->
    </xsl:attribute-set>

    <!-- Suite Jan-2012: updated formatting -->
    <xsl:attribute-set name="kwd">
		<!-- EMC	31-Oct-2013		IB3		Issue 333: should inherit the font family from the surrounding content -->
        <!--xsl:attribute name="font-weight">bold</xsl:attribute>
        <xsl:attribute name="line-height">100%</xsl:attribute>
        <xsl:attribute name="font-family">Monospaced</xsl:attribute-->
        <xsl:attribute name="hyphenate">false</xsl:attribute>
		<xsl:attribute name="font-size">inherited-property-value(&apos;font-size&apos;)</xsl:attribute> 
    </xsl:attribute-set>

    <!-- Suite Jan-2012: updated formatting -->
    <xsl:attribute-set name="delim">
        <xsl:attribute name="font-family">Monospaced</xsl:attribute>
		<xsl:attribute name="font-size">inherited-property-value(&apos;font-size&apos;)</xsl:attribute> 
    </xsl:attribute-set>
   
    <!-- Suite Jan-2012: updated formatting -->
    <xsl:attribute-set name="oper">
        <xsl:attribute name="font-family">Monospaced</xsl:attribute>
		<xsl:attribute name="font-size">inherited-property-value(&apos;font-size&apos;)</xsl:attribute> 
    </xsl:attribute-set>

    <!-- Suite Jan-2012: updated formatting -->
    <xsl:attribute-set name="sep">
        <xsl:attribute name="font-family">Monospaced</xsl:attribute>
		<xsl:attribute name="font-size">inherited-property-value(&apos;font-size&apos;)</xsl:attribute> 
    </xsl:attribute-set>

	<!-- Balaji Mani PDF Bundle 25-Feb-2013: Option as Courier New -->	
    <!-- Natasha IB2 07-12-13 Changed "MonospacedNew" to "Monospaced" that now has Courier New font -->
	<xsl:attribute-set name="option">
		<xsl:attribute name="font-family">Monospaced</xsl:attribute>
		<xsl:attribute name="font-size">inherited-property-value(&apos;font-size&apos;)</xsl:attribute> 
    </xsl:attribute-set>
    

	<!-- Balaji Mani PDF Bundle 25-Feb-2013: parmname as Courier New -->
    <!-- Natasha IB2 07-12-13 Changed "MonospacedNew" to "Monospaced" that now has Courier New font -->
	<xsl:attribute-set name="parmname">
		<xsl:attribute name="font-family">Monospaced</xsl:attribute>
		<xsl:attribute name="font-size">inherited-property-value(&apos;font-size&apos;)</xsl:attribute> 
    </xsl:attribute-set>
    
    <!-- Nathan McKimpson 22-May-2013: Added parameter list attribute-sets -->
    <xsl:attribute-set name="parml">
        <xsl:attribute name="space-before.optimum">5pt</xsl:attribute>
        <xsl:attribute name="space-after.optimum">5pt</xsl:attribute>
    </xsl:attribute-set>
    
    <xsl:attribute-set name="plentry">
    </xsl:attribute-set>
    
    <xsl:attribute-set name="pt" use-attribute-sets="base-font">
        <xsl:attribute name="font-weight">normal</xsl:attribute>
        <xsl:attribute name="text-indent">0em</xsl:attribute>
        <xsl:attribute name="end-indent">24pt</xsl:attribute>
    </xsl:attribute-set>
    
    <xsl:attribute-set name="pd" use-attribute-sets="base-font">
        <xsl:attribute name="space-before">0.3em</xsl:attribute>
        <xsl:attribute name="space-after">0.5em</xsl:attribute>
        <xsl:attribute name="start-indent">1.98in</xsl:attribute>
        <xsl:attribute name="end-indent">0pt</xsl:attribute>
		<!-- EMC	Hotfix_3.2 		10-Jun-2015		TKT 214 Formatting of embedded parameter list should be similar to definition list -->
		<xsl:attribute name="margin">0pt 0pt 0pt 20pt</xsl:attribute>
    </xsl:attribute-set>

	<!-- EMC 	25-Oct-2013		Issue 348: Turn off hyphenation in <synph> and <syntaxdiagram> elements -->
	<xsl:attribute-set name="syntaxdiagram">
		<xsl:attribute name="hyphenate">false</xsl:attribute>
	</xsl:attribute-set>	
 </xsl:stylesheet>

