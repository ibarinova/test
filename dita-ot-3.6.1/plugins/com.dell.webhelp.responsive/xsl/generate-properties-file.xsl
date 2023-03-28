<?xml version='1.0' encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">

    <xsl:param name="TEMP-DIR"/>
    <xsl:param name="INPUT-DIR"/>
    <xsl:param name="INPUT-NAME"/>
    <xsl:param name="PROP-FILE-NAME"/>
    <xsl:param name="include-outfilemode" select="'no'"/>

    <xsl:variable name="temp-dir-location" select="concat('file:///', translate($TEMP-DIR, '\', '/'),'/')"/>
    <xsl:variable name="input-dir-location" select="concat('file:///', translate($INPUT-DIR, '\', '/'),'/')"/>

    <xsl:variable name="input-met-name" select="concat(substring-before($INPUT-NAME, '.'), '.met')"/>
    <xsl:variable name="input-met-uri" select="concat($input-dir-location, $input-met-name)"/>
    <xsl:variable name="input-met-doc">
        <xsl:choose>
            <xsl:when test="doc-available($input-met-uri)">
                <xsl:copy-of select="document($input-met-uri)/*"/>
            </xsl:when>
            <xsl:otherwise>
                <dummy/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="jobticket-uri" select="concat($input-dir-location, 'ishjobticket.xml')"/>
    <xsl:variable name="jobticket-doc">
        <xsl:choose>
            <xsl:when test="doc-available($jobticket-uri)">
                <xsl:copy-of select="document($jobticket-uri)/*"/>
            </xsl:when>
            <xsl:otherwise>
                <dummy/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="prop-file-uri" select="concat($temp-dir-location, $PROP-FILE-NAME)"/>
        
    <xsl:variable name="brand-value">
        <xsl:choose>
            <xsl:when test="normalize-space($input-met-doc/descendant::*[@name = 'FDELLBRAND'])">
                <xsl:value-of select="$input-met-doc/descendant::*[@name = 'FDELLBRAND']"/>
            </xsl:when>
            <xsl:when test="normalize-space($jobticket-doc/descendant::*[@name = 'FDELLBRAND'])">
                <xsl:value-of select="$jobticket-doc/descendant::*[@name = 'FDELLBRAND']"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'Dell EMC'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="include-draft-comments-value">
        <xsl:choose>
            <xsl:when test="normalize-space($input-met-doc/descendant::*[@name = 'FPUBINCLUDECOMMENTS'])">
                <xsl:value-of select="$input-met-doc/descendant::*[@name = 'FPUBINCLUDECOMMENTS']"/>
            </xsl:when>
            <xsl:when test="normalize-space($jobticket-doc/descendant::*[@name = 'FPUBINCLUDECOMMENTS'])">
                <xsl:value-of select="$jobticket-doc/descendant::*[@name = 'FPUBINCLUDECOMMENTS']"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'no'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
	<!-- Created new variable include-outfile-mode-value to get the value from the ui for output file generation mode -->
	<xsl:variable name="include-outfile-mode-value">
        <xsl:choose>
            <xsl:when test="normalize-space($input-met-doc/descendant::*[@name = 'FPUBINCLUDEOUTFILEMODE'])">
                <xsl:value-of select="$input-met-doc/descendant::*[@name = 'FPUBINCLUDEOUTFILEMODE']"/>
            </xsl:when>
            <xsl:when test="normalize-space($jobticket-doc/descendant::*[@name = 'FPUBINCLUDEOUTFILEMODE'])">
                <xsl:value-of select="$jobticket-doc/descendant::*[@name = 'FPUBINCLUDEOUTFILEMODE']"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$include-outfilemode"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
	<!-- Created new variable include-outfile-mode-value to get the value from the ui for output file generation mode -->

    <xsl:variable name="required-dellemc-plugin">
        <xsl:message>Brand Selected is : <xsl:value-of select="$brand-value"/></xsl:message>
        <xsl:choose>
            <!-- run Alienware WebHelp plugin -->
            <xsl:when test="$brand-value = 'Alienware'">dellemc-webhelp-responsive.alienware</xsl:when>
            <!-- run Legacy Dell WebHelp plugin -->
            <xsl:when test="$brand-value = 'Dell'">dellemc-webhelp-responsive.dell</xsl:when>
            <!-- run DellEMC WebHelp plugin -->
            <xsl:when test="$brand-value = 'Dell EMC'">dellemc-webhelp-responsive.dellemc</xsl:when>
            <!-- run DellTechnologies WebHelp plugin -->
            <xsl:when test="$brand-value = 'Dell Technologies'">dellemc-webhelp-responsive.delltechnologies</xsl:when>
            <!-- run Non-Brand WebHelp plugin -->
            <xsl:when test="$brand-value = 'Non-brand'">dellemc-webhelp-responsive.nonbrand</xsl:when>
            <!-- run base Legacy EMC WebHelp plugin -->
            <xsl:otherwise>dellemc-webhelp-responsive</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:template match="/">
		<xsl:message>Required plugin selected is : <xsl:value-of select="$required-dellemc-plugin"/></xsl:message>
        <xsl:result-document method="text" href="{$prop-file-uri}">
            <xsl:text>required-dellemc-plugin=</xsl:text><xsl:value-of select="$required-dellemc-plugin"/>
            <xsl:text>
</xsl:text>
            <xsl:text>dell-brand=</xsl:text><xsl:value-of select="$brand-value"/>
            <xsl:text>
</xsl:text>
            <xsl:text>include-draft-comments=</xsl:text><xsl:value-of select="lower-case($include-draft-comments-value)"/>
			<xsl:text>
</xsl:text>
			<!-- Writing variable include-outfile-mode-value value to the web-help.properties file -->
			<xsl:text>include-outfile-mode=</xsl:text><xsl:value-of select="lower-case($include-outfile-mode-value)"/>
        </xsl:result-document>
    </xsl:template>
</xsl:stylesheet>