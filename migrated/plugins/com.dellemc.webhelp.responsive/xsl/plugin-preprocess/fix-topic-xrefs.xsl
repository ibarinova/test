<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ia="http://intelliarts.com"
                exclude-result-prefixes="#all"
                version="2.0">
<!-- Adding a sample comment -->
    <xsl:import href="../dell-webhelp-functions.xsl"/>

    <xsl:param name="properties-xml"/>
    <xsl:param name="dell-brand" select="'EMC'"/>


    <!--<xsl:variable name="doctype" select="ia:gen-doctype(unparsed-text(document-uri(.)))"/>-->

    <xsl:variable name="properties-xml-uri" select="concat('file://', translate($properties-xml, '\', '/'))"/>
    <xsl:variable name="properties-xml-doc" select="document($properties-xml-uri)"/>

    <xsl:variable name="base-name" select="tokenize(base-uri(),'/')[last()]"/>
    <xsl:variable name="base-dir" select="substring-before(base-uri(),$base-name)"/>

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/xref ')][@href][not(@scope = 'external')]">
        <xsl:variable name="href-filename" select="ia:getFileNameFromHref(@href)"/>
        <xsl:variable name="new-name" select="$properties-xml-doc/descendant::*[matches(@name, $href-filename)][1]/@new-name"/>
        <xsl:variable name="href-id" select="substring-after(@href, '#')"/>
        <xsl:copy>
            <xsl:attribute name="href">
                <xsl:choose>
                    <xsl:when test="$dell-brand = ('Dell', 'Dell EMC', 'Alienware', 'Non-brand') and ($properties-xml-doc/descendant::*[matches(@name, $href-filename)][1]/@chunked = 'true')">
                        <xsl:value-of select="$properties-xml-doc/descendant::*[matches(@name, $href-filename)][1]/@chunked-href"/>
                    </xsl:when>
                    <xsl:when test="$new-name = ''">
                        <xsl:value-of select="@href"/>
                    </xsl:when>
                    <xsl:when test="$href-id != ''">
                        <xsl:value-of select="concat($new-name, '#', $href-id)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$new-name"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates select="@*[not(name() = 'href')]"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/link ')][@href][not(@role)]">
        <xsl:variable name="href-filename" select="ia:getFileNameFromHref(@href)"/>
        <xsl:variable name="new-name" select="$properties-xml-doc/descendant::*[matches(@name, $href-filename)][1]/@new-name"/>
        <xsl:message>File name is : <xsl:value-of select="$new-name"/></xsl:message>
        <xsl:copy>
            <xsl:attribute name="href">
                <xsl:choose>
                    <xsl:when test="normalize-space($new-name)">
                        <xsl:value-of select="$new-name"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@href"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates select="@*[not(name() = 'href')]"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>