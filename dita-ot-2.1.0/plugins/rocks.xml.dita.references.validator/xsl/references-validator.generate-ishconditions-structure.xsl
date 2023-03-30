<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xr="http://xml.rocks"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="xr xs"
                version="2.0">

    <xsl:import href="references-validator.common-functions.xsl"/>

    <xsl:param name="sourcedir"/>

    <xsl:variable name="sourcedir-path" select="translate($sourcedir, '\', '/')"/>

    <xsl:variable name="base-uri" select="base-uri()"/>
    <xsl:variable name="base-name" select="tokenize($base-uri,'/')[last()]"/>

    <xsl:template match="/">
        <xsl:apply-templates select="*[contains(@class, ' map/map ')]" mode="root-map"/>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' map/topicmeta ')
                            and not(contains(@class, ' bookmap/bookmeta '))]" priority="10"/>
    <xsl:template match="*[contains(@class, ' topic/related-links ')]" priority="10"/>
    <xsl:template match="*[contains(@class, ' map/reltable ')]" priority="10"/>
    <xsl:template match="*[contains(@class, ' topic/metadata ')]" priority="10"/>

    <xsl:template match="*[contains(@class, ' map/map ')]" mode="root-map">
        <xsl:variable name="ishcondition" select="xr:prepareIshconditionValue(@ishcondition)"/>
        <node>
            <xsl:attribute name="name" select="name()"/>
            <xsl:attribute name="id" select="@id"/>
            <xsl:attribute name="root-name" select="$base-name"/>
            <xsl:attribute name="ishcondition" select="$ishcondition"/>
            <children>
                <xsl:choose>
                    <xsl:when test="normalize-space(@ishcondition)">
                        <xsl:apply-templates mode="inside-ishcondition"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates/>
                    </xsl:otherwise>
                </xsl:choose>
            </children>
        </node>
    </xsl:template>

    <xsl:template match="*" mode="href">
        <xsl:variable name="href" select="if(@conref) then(@conref) else(@href)"/>

        <xsl:variable name="ref-file-name" >
            <xsl:choose>
                <xsl:when test="contains($href, '#')">
                    <xsl:value-of select="substring-before($href, '#')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$href"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="ref-file-path" select="concat('file:///', $sourcedir-path, '/', $ref-file-name)"/>
        <xsl:variable name="ref-file-doc" select="document($ref-file-path)"/>
        <xsl:variable name="ref-id"
                      select="$ref-file-doc/*[contains(@class, ' map/map ') or contains(@class, ' topic/topic ')]/@id"/>

        <href>
            <xsl:attribute name="href" select="$href"/>
            <xsl:attribute name="ref-id" select="$ref-id"/>
            <xsl:apply-templates select="$ref-file-doc/*[contains(@class, ' map/map ') or contains(@class, ' topic/topic ')]"/>
            <xsl:apply-templates/>
        </href>
    </xsl:template>

    <xsl:template match="*" mode="href-inside-ishcondition">
        <xsl:variable name="href" select="if(@conref) then(@conref) else(@href)"/>

        <xsl:variable name="ref-file-name" >
            <xsl:choose>
                <xsl:when test="contains($href, '#')">
                    <xsl:value-of select="substring-before($href, '#')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$href"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="ref-file-path" select="concat('file:///', $sourcedir-path, '/', $ref-file-name)"/>
        <xsl:variable name="ref-file-doc" select="document($ref-file-path)"/>
        <xsl:variable name="ref-id"
                      select="$ref-file-doc/*[contains(@class, ' map/map ') or contains(@class, ' topic/topic ')]/@id"/>

        <href>
            <xsl:attribute name="href" select="$href"/>
            <xsl:attribute name="ref-id" select="$ref-id"/>
            <xsl:apply-templates select="$ref-file-doc/*[contains(@class, ' map/map ') or contains(@class, ' topic/topic ')]" mode="inside-ishcondition"/>
            <xsl:apply-templates mode="inside-ishcondition"/>
        </href>
    </xsl:template>

    <xsl:template match="*[not(ancestor::*[normalize-space(@ishcondition)])][not(normalize-space(@ishcondition))]">
        <xsl:choose>
            <xsl:when
                    test="(@href or @conref) and (contains(@class, ' map/topicref ')
                                                    or contains(@class, ' topic/ph ')
                                                    or contains(@class, ' topic/ol ')
                                                    or contains(@class, ' topic/cite ')
                                                    or contains(@class, ' topic/p ')
                                                    or contains(@class, ' topic/keyword '))">
                <xsl:apply-templates select="." mode="href"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[not(@id)][not(normalize-space(@ishcondition))]" mode="inside-ishcondition">
        <xsl:choose>
            <xsl:when test="(@href or @conref) and (contains(@class, ' map/topicref ')
                                                    or contains(@class, ' topic/ph ')
                                                    or contains(@class, ' topic/ol ')
                                                    or contains(@class, ' topic/cite ')
                                                    or contains(@class, ' topic/p ')
                                                    or contains(@class, ' topic/keyword '))">
                <xsl:apply-templates select="." mode="href-inside-ishcondition" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="inside-ishcondition"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[@id][not(normalize-space(@ishcondition))]" mode="inside-ishcondition">
        <node>
            <xsl:attribute name="name" select="name()"/>
            <xsl:attribute name="id" select="@id"/>
            <xsl:attribute name="ishcondition" select="xr:prepareIshconditionValue(@ishcondition)"/>
            <children>
                <xsl:choose>
                    <xsl:when test="(@href or @conref) and (contains(@class, ' map/topicref ')
                                                    or contains(@class, ' topic/ph ')
                                                    or contains(@class, ' topic/ol ')
                                                    or contains(@class, ' topic/cite ')
                                                    or contains(@class, ' topic/p ')
                                                    or contains(@class, ' topic/keyword '))">
                        <xsl:apply-templates select="." mode="href-inside-ishcondition"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates mode="inside-ishcondition"/>
                    </xsl:otherwise>
                </xsl:choose>
            </children>
        </node>
    </xsl:template>

    <xsl:template match="*[normalize-space(@ishcondition)]">
        <xsl:apply-templates select="." mode="ishcondition-elem"/>
    </xsl:template>

    <xsl:template match="*[normalize-space(@ishcondition)]" mode="inside-ishcondition">
        <xsl:apply-templates select="." mode="ishcondition-elem"/>
    </xsl:template>

    <xsl:template match="*" mode="ishcondition-elem">
        <node>
            <xsl:attribute name="name" select="name()"/>
            <xsl:attribute name="id" select="@id"/>
            <xsl:attribute name="ishcondition" select="xr:prepareIshconditionValue(@ishcondition)"/>
            <children>
                <xsl:choose>
                    <xsl:when test="(@href or @conref) and (contains(@class, ' map/topicref ')
                                                    or contains(@class, ' topic/ph ')
                                                    or contains(@class, ' topic/ol ')
                                                    or contains(@class, ' topic/cite ')
                                                    or contains(@class, ' topic/p ')
                                                    or contains(@class, ' topic/keyword '))">
                        <xsl:apply-templates select="." mode="href-inside-ishcondition"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates mode="inside-ishcondition"/>
                    </xsl:otherwise>
                </xsl:choose>
            </children>
        </node>
    </xsl:template>

    <xsl:template match="text()" priority="10"/>
    <xsl:template match="text()" priority="10" mode="inside-ishcondition"/>

</xsl:stylesheet>
