<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                exclude-result-prefixes="xs"
                version="2.0">

    <xsl:template match="*[contains(@class, ' reference/reference ')]" mode="processTopic"
                  name="processReference" priority="3">
        <xsl:choose>
            <xsl:when test="$isTechnote and contains(@outputclass, 'notice')">
                <fo:block xsl:use-attribute-sets="break.page">
                    <fo:block-container xsl:use-attribute-sets="notices-data_container_technote">
                        <fo:block xsl:use-attribute-sets="notices-copyrights_content_technote">
                            <xsl:apply-templates select="*[contains(@class,' topic/body ')]"/>
                        </fo:block>
                    </fo:block-container>
                </fo:block>
            </xsl:when>
            <xsl:when test="$isNochap and contains(@outputclass, 'notice')">
                <fo:block xsl:use-attribute-sets="break.page">
                    <fo:block-container xsl:use-attribute-sets="notices-data_container_technote">
                        <fo:block xsl:use-attribute-sets="notices-copyrights_content_technote">
                            <xsl:apply-templates select="*[contains(@class,' topic/body ')]"/>
                        </fo:block>
                    </fo:block-container>
                </fo:block>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="." mode="commonTopicProcessing"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
