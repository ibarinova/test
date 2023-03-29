<?xml version='1.0' encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">

    <xsl:param name="TEMP-DIR"/>
    <xsl:param name="INPUT-DIR"/>
    <xsl:param name="INPUT-NAME"/>
    <xsl:param name="PROP-FILE-NAME"/>
    <xsl:param name="MERGED-MAP-NAME"/>

    <xsl:variable name="temp-dir-location" select="concat('file:///', translate($TEMP-DIR, '\', '/'),'/')"/>
    <xsl:variable name="input-dir-location" select="concat('file:///', translate($INPUT-DIR, '\', '/'),'/')"/>

    <xsl:variable name="input-doc-uri" select="concat($input-dir-location, $INPUT-NAME)"/>
    <xsl:variable name="input-doc" select="document($input-doc-uri)"/>

    <xsl:variable name="input-met-name" select="concat(substring-before($INPUT-NAME, '.'), '.met')"/>
    <xsl:variable name="input-met-uri" select="concat($input-dir-location, $input-met-name)"/>
    <xsl:variable name="input-met-doc" select="if(doc-available($input-met-uri)) then(document($input-met-uri)) else('')"/>

    <xsl:variable name="jobticket-uri" select="concat($input-dir-location, 'ishjobticket.xml')"/>
    <xsl:variable name="jobticket-doc" select="if(doc-available($jobticket-uri)) then(document($jobticket-uri)) else('')"/>

    <xsl:variable name="prop-file-uri" select="concat($temp-dir-location, $PROP-FILE-NAME)"/>
    <xsl:variable name="merged-multilingual-map-name" select="concat($input-dir-location, $MERGED-MAP-NAME)"/>

    <xsl:variable name="brand-value">
        <xsl:choose>
            <xsl:when test="doc-available($input-met-uri) and normalize-space($input-met-doc/descendant::*[@name = 'FDELLBRAND'])">
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

    <xsl:variable name="restriction-value">
        <xsl:choose>
            <xsl:when test="doc-available($input-met-uri) and normalize-space($input-met-doc/descendant::*[@name = 'FDELLEMCRESTRICTED'])">
                <xsl:value-of select="$input-met-doc/descendant::*[@name = 'FDELLEMCRESTRICTED']"/>
            </xsl:when>
            <xsl:when test="normalize-space($jobticket-doc/descendant::*[@name = 'FDELLEMCRESTRICTED'])">
                <xsl:value-of select="$jobticket-doc/descendant::*[@name = 'FDELLEMCRESTRICTED']"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="''"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
	<xsl:variable name="watermark-value">
        <xsl:choose>
            <xsl:when test="doc-available($input-met-uri) and normalize-space($input-met-doc/descendant::*[@name = 'FDELLINCLUDEWATERMARK'])">
                <xsl:value-of select="$input-met-doc/descendant::*[@name = 'FDELLINCLUDEWATERMARK']"/>
            </xsl:when>
			<xsl:when test="normalize-space($jobticket-doc/descendant::*[@name = 'FDELLINCLUDEWATERMARK'])">
                <xsl:value-of select="$jobticket-doc/descendant::*[@name = 'FDELLINCLUDEWATERMARK']"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="''"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="include-draft-comments-value">
        <xsl:choose>
            <xsl:when test="doc-available($input-met-uri) and normalize-space($input-met-doc/descendant::*[@name = 'FPUBINCLUDECOMMENTS'])">
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

    <xsl:variable name="include-metadata-value">
        <xsl:choose>
            <xsl:when test="doc-available($input-met-uri) and normalize-space($input-met-doc/descendant::*[@name = 'FPUBINCLUDEMETADATA'])">
                <xsl:value-of select="$input-met-doc/descendant::*[@name = 'FPUBINCLUDEMETADATA']"/>
            </xsl:when>
            <xsl:when test="normalize-space($jobticket-doc/descendant::*[@name = 'FPUBINCLUDEMETADATA'])">
                <xsl:value-of select="$jobticket-doc/descendant::*[@name = 'FPUBINCLUDEMETADATA']"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'no'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="include-guids-value">
        <xsl:choose>
            <xsl:when test="doc-available($input-met-uri) and normalize-space($input-met-doc/descendant::*[@name = 'FDELLINCLUDEGUIDS'])">
                <xsl:value-of select="$input-met-doc/descendant::*[@name = 'FDELLINCLUDEGUIDS']"/>
            </xsl:when>
            <xsl:when test="normalize-space($jobticket-doc/descendant::*[@name = 'FDELLINCLUDEGUIDS'])">
                <xsl:value-of select="$jobticket-doc/descendant::*[@name = 'FDELLINCLUDEGUIDS']"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'no'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="combine-languages">
        <xsl:choose>
            <xsl:when test="normalize-space($jobticket-doc/descendant::*[@combinelanguages])">
                <xsl:value-of select="$jobticket-doc/descendant::*[@combinelanguages][1]/@combinelanguages"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'no'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="language-combination">
        <xsl:choose>
            <xsl:when test="normalize-space($jobticket-doc/descendant::*[@name = 'FISHPUBLNGCOMBINATION'])">
                <xsl:value-of select="translate($jobticket-doc/descendant::*[@name = 'FISHPUBLNGCOMBINATION'], '+', ' ')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="''"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="export-start-document">
        <xsl:choose>
            <xsl:when test="normalize-space($jobticket-doc/descendant::*[@name = 'export-start-document'])">
                <xsl:value-of select="translate($jobticket-doc/descendant::*[@name = 'export-start-document'], '+', ' ')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="''"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:template match="/">
        <xsl:result-document method="text" href="{$prop-file-uri}">
            <xsl:text>dell-brand=</xsl:text><xsl:value-of select="$brand-value"/>
            <xsl:text>
restriction-value=</xsl:text><xsl:value-of select="translate(normalize-space($restriction-value), '–', '-')"/>
			<xsl:text>
			watermark-value=</xsl:text><xsl:value-of select="$watermark-value"/>
            <xsl:text>
include-draft-comments=</xsl:text><xsl:value-of select="$include-draft-comments-value"/>
            <xsl:text>
include-metadata=</xsl:text><xsl:value-of select="$include-metadata-value"/>
            <xsl:text>
include-guids=</xsl:text><xsl:value-of select="$include-guids-value"/>
            <xsl:text>
combine-languages=</xsl:text><xsl:value-of select="$combine-languages"/>
            <xsl:text>
language-combination=</xsl:text><xsl:value-of select="$language-combination"/>
            <xsl:if test="lower-case($combine-languages) = 'yes'">
            <xsl:text>
merged-multilingual-map=</xsl:text><xsl:value-of select="$merged-multilingual-map-name"/>
            </xsl:if>
            <xsl:if test="lower-case($combine-languages) = 'yes'">
            <xsl:text>
export-start-document=</xsl:text><xsl:value-of select="$export-start-document"/>
            </xsl:if>
        </xsl:result-document>
        <xsl:if test="lower-case($combine-languages) = 'yes'">
            <xsl:result-document method="xml" href="{$merged-multilingual-map-name}">
                <xsl:copy-of select="$input-doc"/>
            </xsl:result-document>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>