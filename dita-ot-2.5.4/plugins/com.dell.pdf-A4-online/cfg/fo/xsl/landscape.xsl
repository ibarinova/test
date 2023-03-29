<?xml version="1.0"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:psmi="http://www.CraneSoftwrights.com/resources/psmi"
                version="2.0">

    <xsl:template match="*[contains(@class, ' topic/body ')]/*[contains(@outputclass, 'landscape')]">
        <psmi:page-sequence master-reference="body-sequence-landscape">
            <xsl:call-template name="insertBodyStaticContents"/>
            <fo:flow flow-name="xsl-region-body">
                <fo:block>
                    <xsl:next-match/>
                </fo:block>
            </fo:flow>
        </psmi:page-sequence>
    </xsl:template>

    <xsl:template match="*" mode="processTopic">
        <!--        <fo:block xsl:use-attribute-sets="topic">-->
        <xsl:apply-templates select="." mode="commonTopicProcessing"/>
        <!--        </fo:block>-->
    </xsl:template>

    <xsl:template match="*[contains(@class, ' task/task ')]" mode="processTopic"
                  name="processTask">
        <!--        <fo:block xsl:use-attribute-sets="task">-->
        <xsl:apply-templates select="." mode="commonTopicProcessing"/>
        <!--        </fo:block>-->
    </xsl:template>

    <xsl:template match="*[contains(@class, ' concept/concept ')]" mode="processTopic"
                  name="processConcept">
        <!--        <fo:block xsl:use-attribute-sets="concept">-->
        <xsl:apply-templates select="." mode="commonTopicProcessing"/>
        <!--        </fo:block>-->
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/body ')]" priority="2">
        <xsl:variable name="level" as="xs:integer">
            <xsl:apply-templates select="." mode="get-topic-level"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="not(node())"/>
            <xsl:when test="$level = 1">
                <!--                <fo:block xsl:use-attribute-sets="body__toplevel">-->
                <xsl:apply-templates/>
                <!--                </fo:block>-->
            </xsl:when>
            <xsl:when test="$level = 2">
                <!--                <fo:block xsl:use-attribute-sets="body__secondLevel">-->
                <xsl:apply-templates/>
                <!--                </fo:block>-->
            </xsl:when>
            <xsl:otherwise>
                <!--                <fo:block xsl:use-attribute-sets="body">-->
                <xsl:apply-templates/>
                <!--                </fo:block>-->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>