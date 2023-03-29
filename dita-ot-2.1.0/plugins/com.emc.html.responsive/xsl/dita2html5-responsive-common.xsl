<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                version="2.0"
                exclude-result-prefixes="xs">

    <xsl:variable name="newline" select="'&#10;'"/>

    <xsl:template name="insertTopicTitle-emc">
        <xsl:param name="level" select="6"/>

        <xsl:element name="h{$level}">
            <xsl:attribute name="class">
                <xsl:value-of select="concat('topictitle', $level)"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template name="insertMeta-emc">
        <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
        <xsl:value-of select="$newline"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <xsl:value-of select="$newline"/>
    </xsl:template>

    <xsl:template name="insertCssLinks-emc">
        <link rel="stylesheet" type="text/css" href="normalize.css" />
        <xsl:value-of select="$newline"/>
        <link rel="stylesheet" type="text/css" href="emc.min.css" />
        <xsl:value-of select="$newline"/>
        <link rel="stylesheet" type="text/css" href="emc-techdoc.css" />
        <xsl:value-of select="$newline"/>
        <xsl:text disable-output-escaping="yes">
            &lt;!--[if lt IE 9]&gt;
            &lt;script&gt;
                document.createElement('header');
                document.createElement('nav');
                document.createElement('section');
                document.createElement('article');
                document.createElement('aside');
                document.createElement('figure');
                document.createElement('footer');
            &lt;/script&gt;
            &lt;![endif]--&gt;
        </xsl:text>
    </xsl:template>

    <xsl:template name="insertScripts-emc">
        <script type="text/javascript" src="jquery-1.11.2.js"></script>
        <xsl:value-of select="$newline"/>
        <script type="text/javascript" src="jquery.appear.js"></script>
        <xsl:value-of select="$newline"/>
        <script type="text/javascript" src="respond.js"></script>
        <xsl:value-of select="$newline"/>
        <script type="text/javascript" src="uwcore.min.js"></script>
        <xsl:value-of select="$newline"/>
        <!--  IA   Tridion upgrade    Jan-2019 IDPL-5014 - Fortify flag on EMC.com output: "Avoid dynamic code intepretation".
            emc.min.js was flagged by Fortify. It is outdated now and can be removed if required  - IB-->
        <script type="text/javascript" src="emc.min.js"></script>
        <xsl:value-of select="$newline"/>
        <script type="text/javascript" src="emc-techdoc.js"></script>
        <xsl:value-of select="$newline"/>
    </xsl:template>
</xsl:stylesheet>
