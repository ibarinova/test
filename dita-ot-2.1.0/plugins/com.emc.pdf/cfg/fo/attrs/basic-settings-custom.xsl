<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                exclude-result-prefixes="xs"
                version="2.0">

    <!--
      Revision History
      ================
      Comtech/EMC AdvTraining 24-Jan-2013 Added a check for the barcode outputclass
      Suite/EMC   SOW5    19-Jan-2012   Updated margins and page layout measurements
      Suite/EMC   SOW5    24-Jan-2012   Updated Draft method
      Suite/EMC   SOW5    07-Feb-2012   Updated margins and page layout measurements to match FM
      Suite/EMC   SOW5    05-Mar-2012   Updated index top margin
      Suite/EMC   Nochap  13-Aug-2012   Add beta parameter based on value of outputformat
      Suite/EMC   Nochap  20-Aug-2012   check for EMC, and Nochap, outputclass
      Suite/EMC   SOW7    31-Dec-2012   remove processing for continuation notation
      EMC    AlternateBranding     01-Jul-2015  Mark Moulder  Added variable BRAND for PDF output
    -->

    <!-- Suite Dec-2011: Add areatree and areatree-file parameters used in re-processing the fo with the areatree -->
    <!-- Suite/EMC   SOW7    31-Dec-2012   remove processing for continuation notation - rs -->
    <!--<xsl:param name="AREATREE"/>
    <xsl:param name="areatree-file">
      <xsl:value-of select="concat('file:///',replace($AREATREE,'\\','/'))"/>
    </xsl:param>-->

    <!-- EMC    AlternateBranding     01-Jul-2015  Mark Moulder  Added variable BRAND for PDF output -->
    <xsl:import href="../xsl/trisoft/infoshare.metadata.xsl"/>

    <!-- Suite SOW5  24-Jan-2012  Add draft parameter based on value of outputformat - ck-->
    <xsl:variable name="DRAFT-PDF">
        <xsl:variable name="getMetadataValueaa">
            <xsl:value-of select="document($jobTicket,/)/job-specification/parameter[@name = 'outputformat']"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="contains($getMetadataValueaa,'Draft')">yes</xsl:when>
            <xsl:otherwise>no</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <!-- Suite/EMC Nochap  13-Aug-2012  Add beta parameter based on value of outputformat - AW-->
    <xsl:variable name="BETA">
        <xsl:variable name="getMetadataValueaa">
            <xsl:value-of select="document($jobTicket,/)/job-specification/parameter[@name = 'outputformat']"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="contains($getMetadataValueaa,'Beta')">yes</xsl:when>
            <xsl:otherwise>no</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <!-- Suite/EMC Nochap 20-Aug-2012 check for EMC, and Nochap, outputclass -->
    <xsl:variable name="NOCHAP">
        <xsl:choose>
            <xsl:when test="//bookmap[contains(@outputclass,'nochap')]">yes</xsl:when>
            <xsl:otherwise>no</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>


    <!-- Comtech/EMC AdvTraing 24-Jan-2013 Add variable for barcode outputclass -->
    <xsl:variable name="BARCODE">
        <xsl:choose>
            <xsl:when test="//bookmap[contains(@outputclass,'barcode')]">yes</xsl:when>
            <xsl:otherwise>no</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <!-- Intelliarts Consulting   SolutionsPDF    10-Mar-2017   Add variable for SolutionsPDF outputclass   - IB-->
    <xsl:variable name="SOLUTIONS">
        <xsl:choose>
            <xsl:when test="//bookmap[contains(@outputclass,'solutions')]">yes</xsl:when>
            <xsl:otherwise>no</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <!-- Suite/EMC   SOW6  28-Dec-2012   	0007666: Bold font missing in TH-ZW and KO - ck -->
    <!-- Suite/EMC   SOW7  4-April-2013  	0008763: Headings in Contents (TOC) page are not bold in Czech (CS) PDF output - aw -->
    <xsl:param name="addBoldWeight">
        <!--<xsl:variable name="xmlLang" select="//*[@xml:lang][1]/@xml:lang"/>-->
        <xsl:choose>
            <xsl:when
                    test="$locale = 'ja' or $locale = 'ru' or $locale = 'ko' or $locale = 'zh_CN' or $locale = 'zh_TW' or $locale = 'cs'">
                <xsl:text>yes</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>no</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:param>

    <!-- Intelliarts Consulting   DellEMC Rebranding    10-Oct-2016   Set of existed BRAND values Starts here - IB-->
    <xsl:variable name="BRAND-RSA">RSA</xsl:variable>
    <xsl:variable name="BRAND-EMC">Legacy EMC</xsl:variable>
    <xsl:variable name="BRAND-DELL-EMC">Dell EMC</xsl:variable>
    <xsl:variable name="BRAND-MOZY">Mozy</xsl:variable>
    <!-- Intelliarts Consulting   DellEMC Rebranding    10-Oct-2016   Set of existed BRAND values Ends here - IB-->

    <!-- EMC    AlternateBranding     01-Jul-2015  Mark Moulder  Added variable BRAND for PDF output. -->
    <!-- Intelliarts Consulting   DellEMC Rebranding    10-Oct-2016   Move this variable to the top so we could use it onwards  - IB-->
    <!-- Intelliarts Consulting   DellEMC Rebranding    11-Nov-2016   Change default brand from Dell to EMC   - IB-->
    <xsl:variable name="BRAND">
        <xsl:call-template name="getMetadataValue">
            <xsl:with-param name="fieldname">FDELLBRAND</xsl:with-param>
            <xsl:with-param name="fieldlevel">lng</xsl:with-param>
            <xsl:with-param name="document.id" select="$export-document-id"/>
            <xsl:with-param name="default">
                <!-- IA   Tridion upgrade    Oct-2018   Remove EMC default value. Use DellEMC instead. - IB-->
                <xsl:value-of select="$BRAND-DELL-EMC"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="BRAND-IS-RSA" as="xs:boolean"
                  select="if(matches($BRAND, $BRAND-RSA, 'i')) then(true()) else(false())"/>
    <xsl:variable name="BRAND-IS-EMC" as="xs:boolean"
                  select="if(matches($BRAND, $BRAND-EMC, 'i')) then(true()) else(false())"/>
    <xsl:variable name="BRAND-IS-DELL-EMC" as="xs:boolean"
                  select="if(matches($BRAND, $BRAND-DELL-EMC, 'i')) then(true()) else(false())"/>
    <xsl:variable name="BRAND-IS-MOZY" as="xs:boolean"
                  select="if(matches($BRAND, $BRAND-MOZY, 'i')) then(true()) else(false())"/>

    <!-- mckimn 25-April-2017 prepend brand name to content wrapped in keyword with outputclass="prodname" -->
    <xsl:variable name="BRAND-TEXT">
        <!-- IA   Tridion upgrade    Oct-2018   Remove EMC default value. Use DellEMC instead. - IB-->
        <xsl:value-of>Dell&#xA0;EMC&#xA0;</xsl:value-of>
    </xsl:variable>

    <!-- Colors -->
    <!--Note from RS: The difference between emc_blue and pantone_279 were very slight; in addition the use of one over the other was inconsistent in the specs.-->
    <!--Assumption for now is that all should be emc_blue.-->
    <xsl:variable name="emc_blue">rgb(102,137,204)</xsl:variable><!--RGB # 6689cc -->
    <!-- Intelliarts Consulting   DellEMC Rebranding    10-Oct-2016   Add Dell blue color - IB-->
    <xsl:variable name="dell_blue">rgb(0,125,184)</xsl:variable><!--RGB #007DB8  -->
    <!-- Thomas Dill 2011-May-25: Added for RSA template updates -->
    <xsl:variable name="rsa_red">cmyk(0, 93, 95, 0)</xsl:variable>
    <xsl:variable name="emc_gray">cmyk(0, 0, 0, 0.6)</xsl:variable>
    <!-- TODO: check if pantone_279 is being used. If not, remove -->

    <xsl:variable name="pantone_279">cmyk(0.73, 0.31, 0, 0)</xsl:variable>

    <!--font sizes-->
    <xsl:variable name="default-font-size">10pt</xsl:variable>
    <xsl:variable name="default-table-font-size">9pt</xsl:variable>

    <!--page layout-->

    <!-- Suite/EMC   SOW5  07-Feb-2012   Updated margins and page layout measurements START - ck -->
    <!-- Suite/EMC   SOW5  19-Jan-2012   Updated margins and page layout measurements START - rs -->
    <xsl:variable name="page-width">8.268in</xsl:variable>
    <xsl:variable name="page-height">11in</xsl:variable>
    <xsl:variable name="page-margin-top">1in</xsl:variable>
    <xsl:variable name="page-margin-top-smaller">0.625in</xsl:variable>
    <!-- Balaji Mani 18-June-2013: added landscape top -->
    <xsl:variable name="page-margin-landscape-top">0.75in</xsl:variable>
    <xsl:variable name="page-margin-top-frontpage">
        <!-- Intelliarts Consulting   DellEMC Rebranding    10-Oct-2016   Set specific DellEMC and Dell Mozy front-matter metrics  - IB-->
        <!-- Intelliarts Consulting   DellEMC Rebranding    17-Oct-2016   Set specific RSA front-matter metrics. All other brands have the same measures  - IB-->
        <xsl:choose>
            <xsl:when test="$BRAND-IS-RSA">4.138in</xsl:when>
            <xsl:otherwise>3.55in</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="page-margin-top-toc">1.875in</xsl:variable>
    <xsl:variable name="image-margin-top-frontpage">
        <!-- Intelliarts Consulting   DellEMC Rebranding    10-Oct-2016   Set specific DellEMC and Dell Mozy front-matter metrics  - IB-->
        <!-- Intelliarts Consulting   DellEMC Rebranding    17-Oct-2016   Set specific RSA front-matter metrics. All other brands have the same measures  - IB-->
        <!-- Intelliarts Consulting   SolutionsPDF    10-Mar-2017   Add specific margins for frontmatter page for Solutions PDF  - IB-->
        <xsl:choose>
            <xsl:when test="$SOLUTIONS = 'yes'">-0.79in</xsl:when>
            <xsl:when test="$BRAND-IS-RSA">-4.144in</xsl:when>
            <xsl:otherwise>-3.556in</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="page-margin-bottom">0.625in</xsl:variable>
    <!-- Intelliarts Consulting   DellEMC Rebranding    17-Oct-2016   Increase bottom margin for frontmatter page for nochap publications (mini TOC overlaid bottom logo)  - IB-->
    <xsl:variable name="page-margin-bottom-nochap">1.225in</xsl:variable>

    <!-- Intelliarts Consulting   SolutionsPDF    09-Mar-2017   Add specific margins for frontmatter page for Solutions PDF  - IB-->
    <xsl:variable name="page-margin-top-solutions">0.79in</xsl:variable>
    <xsl:variable name="page-margin-bottom-solutions">0in</xsl:variable>
    <xsl:variable name="page-margin-inside-solutions">0.55in</xsl:variable>

    <xsl:variable name="page-margin-bottom-index">0.625in</xsl:variable>
	<!-- Dimitri: Decrease page margins. -->
    <!--xsl:variable name="page-margin-outside">0.625in</xsl:variable-->
    <xsl:variable name="page-margin-outside">0.5in</xsl:variable>
    <xsl:variable name="page-margin-outside-index">0.625in</xsl:variable>
    <xsl:variable name="page-margin-inside-frontpage">
        <!-- Intelliarts Consulting   DellEMC Rebranding    10-Oct-2016   Set specific DellEMC and Dell Mozy front-matter metrics  - IB-->
        <!-- Intelliarts Consulting   DellEMC Rebranding    17-Oct-2016   Set specific RSA front-matter metrics. All other brands have the same measures  - IB-->
        <!-- Intelliarts Consulting   SolutionsPDF    10-Mar-2017   Add specific margins for frontmatter page for Solutions PDF  - IB-->
        <xsl:choose>
            <xsl:when test="$SOLUTIONS = 'yes'">
                <xsl:value-of select="$page-margin-inside-solutions"/>
            </xsl:when>
            <xsl:when test="$BRAND-IS-RSA">2.375in</xsl:when>
            <xsl:otherwise>0.55in</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="page-margin-outside-frontpage">
        <!-- Intelliarts Consulting   DellEMC Rebranding    10-Oct-2016   Set specific DellEMC and Dell Mozy front-matter metrics  - IB-->
        <!-- Intelliarts Consulting   DellEMC Rebranding    17-Oct-2016   Set specific RSA front-matter metrics. All other brands have the same measures  - IB-->
        <!-- Intelliarts Consulting   SolutionsPDF    10-Mar-2017   Add specific margins for frontmatter page for Solutions PDF  - IB-->
        <xsl:choose>
            <xsl:when test="$SOLUTIONS = 'yes'">
                <xsl:value-of select="$page-margin-inside-solutions"/>
            </xsl:when>
            <xsl:when test="$BRAND-IS-RSA">0.5in</xsl:when>
            <xsl:otherwise>0.55in</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
	<!-- Dimitri: Decrease page margins. -->
    <!--xsl:variable name="page-margin-inside">0.625in</xsl:variable-->
    <xsl:variable name="page-margin-inside">0.5in</xsl:variable>
    <xsl:variable name="page-margin-inside-index">0.625</xsl:variable>
	<!-- Dimitri: Decrease body indent (text, table, image). -->
    <!--xsl:variable name="side-col-1">1.5in</xsl:variable>
    <xsl:variable name="side-col-2">0.25in</xsl:variable>
    <xsl:variable name="side-col-width">1.75in</xsl:variable-->
	<!-- Body text. -->
    <xsl:variable name="side-col-1">1in</xsl:variable>
	<!-- Table. -->
    <xsl:variable name="side-col-2">0.2in</xsl:variable>
	<!-- Image. -->
    <xsl:variable name="side-col-width">1.25in</xsl:variable>
    <xsl:variable name="main-col">5.268</xsl:variable>
    <xsl:variable name="main-col-landscape">7.786</xsl:variable>
    <xsl:variable name="page-width-without-margins">7in</xsl:variable>
    <xsl:variable name="page-width-without-margins-landscape">9.5in</xsl:variable>

    <!--<xsl:variable name="header-margin-top"></xsl:variable>
    <xsl:variable name="header-margin-"></xsl:variable>-->
    <xsl:variable name="table-footnote-column-width">6.65in</xsl:variable>

    <xsl:variable name="list-indent">0.20</xsl:variable>
    <xsl:variable name="list-item-indent">0.225</xsl:variable>
    <xsl:variable name="sublist-item-indent">0.20</xsl:variable>

    <xsl:variable name="mirror-page-margins" select="true()"/>
    <xsl:variable name="generate-front-cover" select="true()"/>
    <xsl:variable name="generate-back-cover" select="false()"/>
    <xsl:variable name="generate-toc" select="true()"/>
    <!--for color coded metadata-->
    <xsl:variable name="export-document-id">
        <xsl:call-template name="getJobTicketParam">
            <xsl:with-param name="varname">export-document</xsl:with-param>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="INCLUDEMETADATA">
        <xsl:call-template name="getJobTicketParam">
            <xsl:with-param name="varname">FPUBINCLUDEMETADATA</xsl:with-param>
        </xsl:call-template>
    </xsl:variable>

    <!-- IA   Tridion upgrade    Oct-2018   Add support for DELL othermeta parameters - IB-->
    <xsl:variable name="generate-mini-toc" as="xs:boolean" select="if(/descendant::*[contains(@class, 'topic/othermeta')][@name = 'mini-toc'][last()]/@content = 'no') then(false()) else(true())"/>
    <xsl:variable name="generate-task-labels" as="xs:boolean" select="if(/descendant::*[contains(@class, 'topic/othermeta')][@name = 'task-labels'][last()]/@content = 'no') then(false()) else(true())"/>

    <!-- IA   Tridion upgrade    Mar-2019 IDPL-5477: Adapt 3 PDF output formats to support CPSD documenation.
                                Omit chapters number if bookmap has @outputclass = 'omit_chapter_numbers'.  - IB-->
    <xsl:variable name="omit-chapter-numbers" select="if(/descendant::*[contains(@outputclass, 'omit_chapter_numbers')]) then(true()) else(false())"/>

    <!-- IA   Tridion upgrade    Oct-2018   Add support for 'DELLINCLUDEGUIDS' property STARTS HERE - IB-->
    <xsl:variable name="DELLINCLUDEGUIDS-value">
        <xsl:call-template name="getJobTicketParam">
            <xsl:with-param name="varname">FDELLINCLUDEGUIDS</xsl:with-param>
        </xsl:call-template>
        <!--<xsl:text>no</xsl:text>-->
        <!--<xsl:text>yes</xsl:text>-->
    </xsl:variable>
    <xsl:variable name="insert-topic-guid" as="xs:boolean" select="if(lower-case($DELLINCLUDEGUIDS-value) = 'yes') then(true()) else(false())"/>
    <!-- IA   Tridion upgrade    Oct-2018   Add support for 'DELLINCLUDEGUIDS' property ENDS HERE - IB-->

    <!-- IA   Tridion upgrade    Oct-2018   Add support for 'DELLRESTRICTED' property STARTS HERE. - IB-->
    <xsl:variable name="DELLRESTRICTED-value">
        <xsl:call-template name="getJobTicketParam">
            <xsl:with-param name="varname">FDELLEMCRESTRICTED</xsl:with-param>
        </xsl:call-template>
    </xsl:variable>

    <!-- IA   Tridion upgrade    Oct-2018   Select which watermark use in PDF. - IB-->
    <xsl:variable name="DECR" as="xs:boolean" select="if(upper-case($DELLRESTRICTED-value) = 'DELL EMC CONFIDENTIAL RESTRICTED') then(true()) else(false())"/>
    <xsl:variable name="DEC" as="xs:boolean" select="if(upper-case($DELLRESTRICTED-value) = 'DELL EMC CONFIDENTIAL') then(true()) else(false())"/>
    <xsl:variable name="DEI" as="xs:boolean" select="if(upper-case($DELLRESTRICTED-value) = 'DELL EMC INTERNAL') then(true()) else(false())"/>
    <!-- IA   Tridion upgrade    Oct-2018   Add support for 'DELLRESTRICTED' property ENDS HERE - IB-->

</xsl:stylesheet>
