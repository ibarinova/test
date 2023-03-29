<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                version="2.0">

    <xsl:variable name="page-width">210mm</xsl:variable>
    <xsl:variable name="page-height">297mm</xsl:variable>

    <xsl:variable name="page-margins">13mm</xsl:variable>
    <xsl:variable name="page-margin-top">23mm</xsl:variable>
    <xsl:variable name="page-margin-bottom">26mm</xsl:variable>

    <xsl:variable name="side-col-width">0pt</xsl:variable>

    <xsl:variable name="default-font-size">9pt</xsl:variable>
    <xsl:variable name="default-line-height">11pt</xsl:variable>
    <xsl:variable name="table.frame-default">all</xsl:variable>
	<xsl:variable name="table.rowsep-default" select="'1'"/>
    <xsl:variable name="table.colsep-default" select="'1'"/>
    <xsl:variable name="mirror-page-margins" select="true()"/>
    <xsl:variable name="task-labels-required" select="if(/descendant::*[contains(@class, ' topic/othermeta ')][@name = 'task-labels']/@content = 'yes') then true() else false()"/>
    <xsl:variable name="mini-toc-required" select="if(/descendant::*[contains(@class, ' topic/othermeta ')][@name = 'mini-toc'][1]/@content = 'no') then false() else true()"/>

    <xsl:variable name="model.number">
        <xsl:value-of select="/descendant::*[contains(@class, ' bookmap/bookid ')][1]/*[contains(@class, ' bookmap/bookpartno ')][1]"   />
    </xsl:variable>

    <xsl:variable name="type.number">
        <xsl:value-of select="/descendant::*[contains(@class, ' bookmap/bookid ')][1]/*[contains(@class, ' bookmap/booknumber ')][1]"/>
    </xsl:variable>

    <xsl:variable name="computer.model">
        <xsl:apply-templates select="/descendant::*[contains(@class, ' topic/prodinfo ')][1]/*[contains(@class, ' topic/platform ')][1]"/>
    </xsl:variable>

    <xsl:variable name="completed.month">
        <xsl:apply-templates select="/descendant::*[contains(@class, ' bookmap/published ')][1]/*[contains(@class, ' bookmap/completed ')]/*[contains(@class, ' bookmap/month ')]"/>
    </xsl:variable>

    <xsl:variable name="release.date">
        <xsl:if test="normalize-space($completed.month)">
            <xsl:value-of select="$completed.month"/>
            <xsl:text> </xsl:text>
        </xsl:if>
	<xsl:apply-templates select="/descendant::*[contains(@class, ' bookmap/published ')][1]/*[contains(@class, ' bookmap/completed ')]/*[contains(@class, ' bookmap/year ')]"/>
    </xsl:variable>

    <xsl:variable name="book.revision">
        <xsl:value-of select="/descendant::*[contains(@class, ' bookmap/bookid ')]/*[contains(@class, ' bookmap/volume ')]"/>
    </xsl:variable>

    <xsl:variable name="book.vrm">
        <xsl:value-of select="/descendant::*[contains(@class, ' topic/vrm ')][1]/@version"/>
    </xsl:variable>

    <xsl:variable name="book.releasedate" select="/descendant::*[contains(@class, ' topic/othermeta ')][@name = 'PDF-releasedate'][1]/@content"/>
    <xsl:variable name="book.docnumber" select="/descendant::*[contains(@class, ' topic/othermeta ')][@name = 'PDF-docnumber'][1]/@content"/>
    <xsl:variable name="book.currentversion" select="/descendant::*[contains(@class, ' topic/othermeta ')][@name = 'PDF-currentversion'][1]/@content"/>
    <xsl:variable name="book.previousversion" select="/descendant::*[contains(@class, ' topic/othermeta ')][@name = 'PDF-previousversion'][1]/@content"/>
    <xsl:variable name="release.type" select="lower-case(/descendant::*[contains(@class, ' topic/othermeta ')][@name = 'release-type'][1]/@content)"/>

	 <xsl:variable name="use-vrm-string_ver" select="if(contains(/descendant::*[contains(@class, ' bookmap/bookmap ')][1]/@outputclass, 'vrm_prefix_ver')) then(true()) else(false())"/>
	
	<xsl:variable name="use-vrm-string_rel" select="if(contains(/descendant::*[contains(@class, ' bookmap/bookmap ')][1]/@outputclass, 'vrm_prefix_rel')) then(true()) else(false())"/>
	
    <xsl:variable name="use-part-number" select="if(contains(/descendant::*[contains(@class, ' bookmap/bookmap ')][1]/@outputclass, 'part_number')) then(true()) else(false())"/>
	<xsl:variable name="use-regulatory-number" select="if(contains(/descendant::*[contains(@class, ' bookmap/bookmap ')][1]/@outputclass, 'regulatory')) then(true()) else(false())"/>

    <xsl:variable name="dell-font-family">
        <xsl:choose>
            <xsl:when test="$dell-brand = 'Non-brand'">univers</xsl:when>
            <xsl:when test="$dell-brand = 'Alienware'">alienware</xsl:when>
            <xsl:otherwise>sans-serif</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="use-bold-font">
        <xsl:choose>
            <xsl:when test="$isTechnote">
                <xsl:sequence select="true()"/>
            </xsl:when>
            <xsl:when test="$isNochap">
                <xsl:sequence select="true()"/>
            </xsl:when>
            <xsl:when test="$dell-brand = 'Non-brand'">
                <xsl:sequence select="true()"/>
            </xsl:when>
            <xsl:when test="$dell-brand = 'Alienware'">
                <xsl:sequence select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="dell-bold-font-weight">
        <xsl:choose>
            <xsl:when test="$use-bold-font">bold</xsl:when>
            <xsl:otherwise>normal</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="dell-bold-font-family">
        <xsl:choose>
            <xsl:when test="$dell-brand = 'Non-brand'"><xsl:value-of select="$dell-font-family"/></xsl:when>
            <xsl:when test="$dell-brand = 'Alienware'"><xsl:value-of select="$dell-font-family"/></xsl:when>
            <xsl:when test="$isTechnote">sans-reg</xsl:when>
            <xsl:when test="$isNochap">sans-reg</xsl:when>
            <xsl:otherwise>sans-bold</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="isTechnote" select="if(contains(/descendant::*[contains(@class, ' bookmap/bookmap ')][1]/@outputclass, 'technote')) then(true()) else(false())"/>
    <xsl:variable name="isNochap" select="if(contains(/descendant::*[contains(@class, ' bookmap/bookmap ')][1]/@outputclass, 'nochap')) then(true()) else(false())"/>

    <xsl:variable name="generate-front-cover" select="if($isTechnote or $isNochap) then(false()) else(true())"/>
    <xsl:variable name="generate-toc" select="if($isTechnote or $isNochap) then(false()) else(true())"/>

    <xsl:variable name="rsa_red">cmyk(0, 93, 95, 0)</xsl:variable>
    <xsl:variable name="dell_gray">rgb(128, 130, 133)</xsl:variable>
    <xsl:variable name="dell_blue">#0076CE</xsl:variable>

    <xsl:variable name="addTopicNumbering" select="if(/descendant::*[contains(@class, ' topic/othermeta ')][@name = 'numbered-headings'][1]/@content = 'yes') then(true()) else(false())" as="xs:boolean"/>

    <xsl:variable name="addXrefsPageNumbering" select="if(lower-case(/descendant::*[contains(@class, ' topic/othermeta ')][@name = 'xref-page-numbers'][1]/@content) = 'yes') then(true()) else(false())" as="xs:boolean"/>

    <xsl:variable name="imageDefaultAlignment"
                  select="if(lower-case(/descendant::*[contains(@class, ' topic/othermeta ')][@name = 'image_default_alignment'][1]/@content) = ('left', 'center', 'right'))
                            then(descendant::*[contains(@class, ' topic/othermeta ')][@name = 'image_default_alignment'][1]/@content)
                            else('center')"/>

	<!--Support for LEMC outputclass branded-->
	<xsl:variable name="BRAND-TEXT">
        <xsl:value-of>Dell&#xA0;EMC&#xA0;</xsl:value-of>
    </xsl:variable>
</xsl:stylesheet>