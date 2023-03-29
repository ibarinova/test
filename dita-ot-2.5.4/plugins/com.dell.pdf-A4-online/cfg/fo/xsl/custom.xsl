<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                version="2.0"
                exclude-result-prefixes="#all">

    <xsl:import href="bookmarks.xsl"/>
    <xsl:import href="commons.xsl"/>
    <xsl:import href="front-matter.xsl"/>
    <xsl:import href="layout-masters.xsl"/>
    <xsl:import href="links.xsl"/>
    <xsl:import href="lists.xsl"/>
    <xsl:import href="reference-elements.xsl"/>
    <xsl:import href="root-processing.xsl"/>
    <xsl:import href="static-content.xsl"/>
    <xsl:import href="task-elements.xsl"/>
    <xsl:import href="toc.xsl"/>
    <xsl:import href="topic.xsl"/>
    <xsl:import href="tables.xsl"/>
	<xsl:import href="pr-domain-custom.xsl"/>
    <xsl:import href="glossary.xsl"/>
	<xsl:import href="landscape.xsl"/>
	<xsl:import href="lot-lof-custom.xsl"/>
    <xsl:import href="ui-domain.xsl"/>
    <xsl:import href="pagebreak.xsl"/>

    <xsl:param name="dell-brand"/>
    <xsl:param name="restricted-access"/>
	<xsl:param name="watermark-access"/>
    <xsl:param name="include-metadata"/>
    <xsl:param name="include-draft-comments"/>
    <xsl:param name="include-guids"/>
    <xsl:param name="args.input.location"/>

    <xsl:variable name="input-dir-location" select="concat('file:///', translate($args.input.location, '\', '/'),'/')"/>

    <xsl:variable name="artwork-dir" select="concat($customizationDir.url, 'common/artwork/')"/>
    <xsl:variable name="artwork-logo-dir" select="concat($artwork-dir, 'logo/')"/>

    <xsl:variable name="DECR" as="xs:boolean" select="if(lower-case($restricted-access) = 'highly restricted - confidential') then(true()) else(false())"/>
    <xsl:variable name="DEC" as="xs:boolean" select="if(lower-case($restricted-access) = 'restricted - confidential') then(true()) else(false())"/>
    <xsl:variable name="DEI" as="xs:boolean" select="if(lower-case($restricted-access) = 'internal use - confidential') then(true()) else(false())"/>

    <xsl:variable name="restriction-value">
        <xsl:choose>
            <xsl:when test="$DECR">
                <xsl:call-template name="getVariable">
                    <xsl:with-param name="id" select="'Highly Restricted Confidential'"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$DEC">
                <xsl:call-template name="getVariable">
                    <xsl:with-param name="id" select="'Restricted Confidential'"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$DEI">
                <xsl:call-template name="getVariable">
                    <xsl:with-param name="id" select="'Restricted Internal'"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
	</xsl:variable>
	<xsl:variable name="DDRAFT" as="xs:boolean" select="if(upper-case($watermark-access) = 'DRAFT') then(true()) else(false())"/>
	<xsl:variable name="DBETA" as="xs:boolean" select="if(upper-case($watermark-access) = 'BETA') then(true()) else(false())"/>
	<xsl:variable name="watermark-value">
        <xsl:choose>
            <xsl:when test="$DDRAFT">
                <xsl:call-template name="getVariable">
                    <xsl:with-param name="id" select="'DRAFT'"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$DBETA">
                <xsl:call-template name="getVariable">
                    <xsl:with-param name="id" select="'BETA'"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:variable>
</xsl:stylesheet>