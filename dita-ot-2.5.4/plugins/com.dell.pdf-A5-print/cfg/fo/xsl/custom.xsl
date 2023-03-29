<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0"
                exclude-result-prefixes="#all">

    <xsl:import href="bookmarks.xsl"/>
    <xsl:import href="commons.xsl"/>
    <xsl:import href="front-matter.xsl"/>
    <xsl:import href="glossary.xsl"/>
    <xsl:import href="layout-masters.xsl"/>
    <xsl:import href="links.xsl"/>
    <xsl:import href="lists.xsl"/>
    <xsl:import href="root-processing.xsl"/>
    <xsl:import href="static-content.xsl"/>
    <xsl:import href="task-elements.xsl"/>
    <xsl:import href="toc.xsl"/>
    <xsl:import href="topic.xsl"/>
    <xsl:import href="tables.xsl"/>
    <xsl:import href="ui-domain.xsl"/>

    <xsl:param name="TEMP-DIR"/>
    <xsl:param name="merged-multilingual-map"/>
    <xsl:param name="dell-brand"/>
    <xsl:param name="restricted-access"/>
    <xsl:param name="include-metadata"/>
    <xsl:param name="include-draft-comments"/>
    <xsl:param name="include-guids"/>
    <xsl:param name="combine-languages"/>
    <xsl:param name="language-combination"/>
    <xsl:param name="export-start-document"/>

    <xsl:template match="*[@audience]" priority="5">
        <xsl:variable name="topic-lang" select="ancestor-or-self::*[@xml:lang][last()]/@xml:lang"/>
        <xsl:choose>
            <!-- multi language publication -->
            <xsl:when test="$multilingual">
                <xsl:if test="contains(@audience, $topic-lang)">
                    <xsl:next-match/>
                </xsl:if>
            </xsl:when>
            <!-- single language publication -->
            <xsl:otherwise>
                <xsl:if test="contains(@audience, $language-combination)">
                    <xsl:next-match/>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>