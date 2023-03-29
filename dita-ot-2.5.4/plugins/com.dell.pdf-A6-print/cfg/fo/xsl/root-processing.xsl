<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
                version="2.0"
                exclude-result-prefixes="#all">

    <xsl:template match="*[contains(@class, ' bookmap/notices ')]" mode="generatePageSequences">
        <xsl:if test="*[contains(@class, ' map/topicref ')]">
            <xsl:call-template name="processTopicNotices"/>
        </xsl:if>
    </xsl:template>

    <xsl:template name="createMetadata">
        <xsl:variable name="title" as="xs:string?">
            <xsl:apply-templates select="$firstPublicationDitamap" mode="dita-ot:title-metadata"/>
        </xsl:variable>
        <xsl:if test="exists($title)">
            <axf:document-info name="document-title" value="{$title}"/>
            <axf:document-info name="displaydoctitle" value="true"/>
            <axf:document-info name="title" value="{$title}"/>
        </xsl:if>
        <!--axf:document-info name="subject" value="The document subject"/-->
        <xsl:variable name="author" as="xs:string?">
            <xsl:apply-templates select="$firstPublicationDitamap" mode="dita-ot:author-metadata"/>
        </xsl:variable>
        <xsl:if test="exists($author)">
            <axf:document-info name="author" value="{$author}"/>
        </xsl:if>
        <xsl:variable name="keywords" as="xs:string*">
            <xsl:choose>
                <xsl:when test="$multilingual">
                    <xsl:for-each select="$all-merged-ditamaps">
                        <xsl:variable name="current-uri" select="concat($temp-dir-location, @href)"/>
                        <xsl:variable name="current-doc" select="document($current-uri)"/>
                        <xsl:apply-templates select="$current-doc" mode="dita-ot:keywords-metadata"/>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="." mode="dita-ot:keywords-metadata"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="exists($keywords)">
            <axf:document-info name="keywords">
                <xsl:attribute name="value">
                    <xsl:value-of select="$keywords" separator="&#10;"/>
                </xsl:attribute>
            </axf:document-info>
        </xsl:if>
        <xsl:variable name="subject" as="xs:string?">
            <xsl:apply-templates select="." mode="dita-ot:subject-metadata"/>
        </xsl:variable>
        <xsl:if test="exists($subject)">
            <axf:document-info name="subject" value="{$subject}"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="/" mode="dita-ot:title-metadata" as="xs:string?">
        <xsl:choose>
            <xsl:when test="exists($firstPublicationDitamap-map/descendant::*[contains(@class,' bookmap/mainbooktitle ')])">
                <xsl:variable name="booktitle">
                    <xsl:variable name="mainbooktitle">
                        <xsl:value-of>
                            <xsl:apply-templates select="$firstPublicationDitamap-map/descendant::*[contains(@class, ' bookmap/booktitle ')][1]/descendant::*[contains(@class,' bookmap/mainbooktitle ')][1]" mode="dita-ot:text-only"/>
                        </xsl:value-of>
                    </xsl:variable>
                    <xsl:variable name="booktitlealt">
                        <xsl:for-each select="$firstPublicationDitamap-map/descendant::*[contains(@class, ' bookmap/booktitle ')][1]/*[contains(@class,' bookmap/booktitlealt ')]">
                            <xsl:apply-templates select="." mode="dita-ot:text-only"/>
                            <xsl:text> </xsl:text>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:value-of select="$mainbooktitle"/>
                    <xsl:if test="normalize-space($booktitlealt) and normalize-space($mainbooktitle)">
                        <xsl:text> </xsl:text>
                    </xsl:if>
                    <xsl:if test="normalize-space($booktitlealt)">
                        <xsl:value-of select="$booktitlealt"/>
                    </xsl:if>
                </xsl:variable>
                <xsl:value-of select="normalize-space($booktitle)"/>
            </xsl:when>
            <xsl:when test="exists($map/*[contains(@class, ' bookmap/booktitle ')]/*[contains(@class,' bookmap/mainbooktitle ')])">
                <xsl:value-of>
                    <xsl:apply-templates select="$map/*[contains(@class, ' bookmap/booktitle ')]/*[contains(@class,' bookmap/mainbooktitle ')][1]" mode="dita-ot:text-only"/>
                </xsl:value-of>
            </xsl:when>
            <xsl:when test="exists($map/*[contains(@class,' topic/title ')])">
                <xsl:value-of>
                    <xsl:apply-templates select="$map/*[contains(@class,' topic/title ')][1]" mode="dita-ot:text-only"/>
                </xsl:value-of>
            </xsl:when>
            <xsl:when test="exists(//*[contains(@class, ' map/map ')]/@title)">
                <xsl:value-of select="//*[contains(@class, ' map/map ')]/@title"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of>
                    <xsl:apply-templates select="descendant::*[contains(@class, ' topic/topic ')][1]/*[contains(@class, ' topic/title ')]" mode="dita-ot:text-only"/>
                </xsl:value-of>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="/" mode="dita-ot:author-metadata" as="xs:string?">
        <xsl:choose>
            <xsl:when test="exists($map/descendant::*[contains(@class, ' bookmap/organization ')][ancestor::*[contains(@class, ' bookmap/bookrights ')]])">
                <xsl:value-of select="$map/descendant::*[contains(@class, ' bookmap/organization ')][ancestor::*[contains(@class, ' bookmap/bookrights ')]][1]"/>
            </xsl:when>
            <xsl:when test="exists($firstPublicationDitamap-map/descendant::*[contains(@class, ' xnal-d/personname ')])">
                <xsl:for-each select="$firstPublicationDitamap-map/descendant::*[contains(@class, ' xnal-d/personname ')][1]">
                    <!-- Requires locale specific processing -->
                    <xsl:value-of>
                        <xsl:apply-templates select="*[contains(@class, ' xnal-d/firstname ')]/node()" mode="dita-ot:text-only"/>
                        <xsl:text> </xsl:text>
                        <xsl:apply-templates select="*[contains(@class, ' xnal-d/lastname ')]/node()" mode="dita-ot:text-only"/>
                    </xsl:value-of>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="exists($map/descendant::*[contains(@class, ' xnal-d/personname ')])">
                <xsl:for-each select="$map/descendant::*[contains(@class, ' xnal-d/personname ')][1]">
                    <!-- Requires locale specific processing -->
                    <xsl:value-of>
                        <xsl:apply-templates select="*[contains(@class, ' xnal-d/firstname ')]/node()" mode="dita-ot:text-only"/>
                        <xsl:text> </xsl:text>
                        <xsl:apply-templates select="*[contains(@class, ' xnal-d/lastname ')]/node()" mode="dita-ot:text-only"/>
                    </xsl:value-of>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="exists($map/descendant::*[contains(@class, ' xnal-d/organizationname ')])">
                <xsl:value-of>
                    <xsl:apply-templates select="$map/descendant::*[contains(@class, ' xnal-d/organizationname ')][1]" mode="dita-ot:text-only"/>
                </xsl:value-of>
            </xsl:when>
            <xsl:when test="exists($firstPublicationDitamap-map/descendant::*[contains(@class, ' xnal-d/organizationname ')])">
                <xsl:value-of>
                    <xsl:apply-templates select="$firstPublicationDitamap-map/descendant::*[contains(@class, ' xnal-d/organizationname ')][1]" mode="dita-ot:text-only"/>
                </xsl:value-of>
            </xsl:when>
            <xsl:when test="exists($firstPublicationDitamap-map/descendant::*[contains(@class, ' bookmap/bookmeta ')]/*[contains(@class, ' topic/author ')])">
                <xsl:value-of>
                    <xsl:apply-templates select="$firstPublicationDitamap-map/descendant::*[contains(@class, ' bookmap/bookmeta ')][1]/*[contains(@class, ' topic/author ')]" mode="dita-ot:text-only"/>
                </xsl:value-of>
            </xsl:when>
            <xsl:when test="exists($map/descendant::*[contains(@class, ' bookmap/bookmeta ')]/*[contains(@class, ' topic/author ')])">
                <xsl:value-of>
                    <xsl:apply-templates select="$map/descendant::*[contains(@class, ' bookmap/bookmeta ')][1]/*[contains(@class, ' topic/author ')]" mode="dita-ot:text-only"/>
                </xsl:value-of>
            </xsl:when>
            <xsl:when test="exists($firstPublicationDitamap-map/descendant::*[contains(@class, ' bookmap/bookmeta ')]/descendant::*[contains(@class, ' bookmap/organization ')])">
                <xsl:value-of select="$firstPublicationDitamap-map/descendant::*[contains(@class, ' bookmap/bookmeta ')][1]/descendant::*[contains(@class, ' bookmap/organization ')][1]"/>
            </xsl:when>
            <xsl:when test="exists($map/descendant::*[contains(@class, ' bookmap/bookmeta ')]/descendant::*[contains(@class, ' bookmap/organization ')])">
                <xsl:value-of select="$map/descendant::*[contains(@class, ' bookmap/bookmeta ')][1]/descendant::*[contains(@class, ' bookmap/organization ')][1]"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="/" mode="dita-ot:keywords-metadata" as="xs:string*">
        <xsl:variable name="keywords" select="/descendant::*[contains(@class, ' bookmap/bookmeta ')][1]/*[contains(@class, ' topic/keywords ')]/*[contains(@class, 'topic/keyword ')]" as="element()*"/>
        <xsl:for-each select="$keywords">
            <xsl:if test="normalize-space(.)">
                <xsl:value-of>
                    <xsl:apply-templates select="." mode="dita-ot:text-only"/>
                </xsl:value-of>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="/" mode="dita-ot:subject-metadata" as="xs:string?">
        <xsl:choose>
            <xsl:when test="exists($firstPublicationDitamap-map/descendant::*[contains(@class, ' bookmap/bookmeta ')][1]/*[contains(@class, ' map/shortdesc ')])">
                <xsl:value-of>
                    <xsl:apply-templates select="$firstPublicationDitamap-map/descendant::*[contains(@class, ' bookmap/bookmeta ')][1]/*[contains(@class, ' map/shortdesc ')]" mode="dita-ot:text-only"/>
                </xsl:value-of>
            </xsl:when>
            <xsl:when test="exists($firstPublicationDitamap-map/descendant::*[contains(@class, ' topic/shortdesc ')])">
                <xsl:value-of>
                    <xsl:apply-templates select="$firstPublicationDitamap-map/descendant::*[contains(@class, ' topic/shortdesc ')][1]" mode="dita-ot:text-only"/>
                </xsl:value-of>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>