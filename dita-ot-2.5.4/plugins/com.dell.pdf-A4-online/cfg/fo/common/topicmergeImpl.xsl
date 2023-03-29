<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:ot-placeholder="http://suite-sol.com/namespaces/ot-placeholder"
                xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
                exclude-result-prefixes="xs dita-ot">

    <xsl:variable name="isNochap" select="if(contains(/descendant::*[contains(@class, ' bookmap/bookmap ')][1]/@outputclass, 'nochap')) then(true()) else(false())"/>
    <xsl:variable name="isTechnote" select="if(contains(/descendant::*[contains(@class, ' bookmap/bookmap ')][1]/@outputclass, 'technote')) then(true()) else(false())"/>

    <xsl:template match="*[contains(@class,' map/topicref ')]
                        [contains(@class, ' bookmap/chapter ')
                            or contains(@class, ' bookmap/appendix ')
                            or contains(@class, ' bookmap/part ')]
                        [preceding-sibling::*[1][contains(@class, ' bookmap/frontmatter ')
                                                or contains(@class, ' bookmap/bookmeta ')
                                                or contains(@class, ' bookmap/booktitle ')]][$isNochap]" mode="build-tree">
        <!--merge NoChap 1-st chapter/appendix/part-->

        <xsl:choose>
            <xsl:when test="not(normalize-space(@first_topic_id) = '')">
                <xsl:apply-templates select="key('topic',@first_topic_id)" mode="first-chapter-topic">
                    <xsl:with-param name="parentId" select="generate-id()"/>
                </xsl:apply-templates>
                <xsl:if test="@first_topic_id != @href">
                    <xsl:apply-templates select="key('topic',@href)">
                        <xsl:with-param name="parentId" select="generate-id()"/>
                    </xsl:apply-templates>
                </xsl:if>
            </xsl:when>
            <xsl:when test="not(normalize-space(@href) = '')">
                <xsl:apply-templates select="key('topic',@href)" mode="first-chapter-topic">
                    <xsl:with-param name="parentId" select="generate-id()"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="normalize-space(@href) = ''">
                <topic id="{generate-id()}" class="+ topic/topic pdf2-d/placeholder ">
                    <title class="- topic/title ">
                    </title>
                    <xsl:apply-templates mode="build-tree"/>
                    <xsl:apply-templates mode="build-tree"
                                         select="following-sibling::*[contains(@class, ' bookmap/chapter ')
                                            or contains(@class, ' bookmap/appendix ')
                                            or contains(@class, ' bookmap/part ')]/*"/>
                </topic>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[contains(@class,' map/topicref ')]
                        [contains(@class, ' bookmap/chapter ')
                            or contains(@class, ' bookmap/appendix ')
                            or contains(@class, ' bookmap/part ')]
                        [preceding-sibling::*[contains(@class, ' bookmap/chapter ')
                                or contains(@class, ' bookmap/appendix ')
                                or contains(@class, ' bookmap/part ')]][$isNochap]" mode="build-tree">
        <!-- ignore processing for non-first chapter/appendix/part in No-chap pub-->
    </xsl:template>

    <xsl:template match="*[contains(@class,' bookmap/backmatter ')][$isNochap]" mode="build-tree"/>
    <xsl:template match="*[contains(@class,' bookmap/backmatter ')][$isNochap]"/>
    <xsl:template match="*[contains(@class,' bookmap/booklists ')][$isNochap]"/>

    <xsl:template match="*[contains(@class,' bookmap/backmatter ')][$isTechnote]" mode="build-tree"/>
    <xsl:template match="*[contains(@class,' bookmap/backmatter ')][$isTechnote]"/>
    <xsl:template match="*[contains(@class,' bookmap/booklists ')][$isTechnote]"/>

    <xsl:template match="*[contains(@class,' topic/topic ')]" mode="first-chapter-topic">

        <xsl:param name="parentId"/>
        <xsl:variable name="idcount">
            <!--for-each is used to change context.  There's only one entry with a key of $parentId-->
            <xsl:for-each select="key('topicref',$parentId)">
                <xsl:value-of select="count(preceding::*[@href = current()/@href][not(ancestor::*[contains(@class, ' map/reltable ')])]) + count(ancestor::*[@href = current()/@href])"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:copy>
            <xsl:apply-templates select="@*[name() != 'id']"/>
            <xsl:variable name="new_id">
                <xsl:choose>
                    <xsl:when test="number($idcount) &gt; 0">
                        <xsl:value-of select="concat(@id,'_ssol',$idcount)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@id"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:attribute name="id">
                <xsl:value-of select="$new_id"/>
            </xsl:attribute>
            <xsl:apply-templates>
                <xsl:with-param name="newid" select="$new_id"/>
            </xsl:apply-templates>
            <xsl:apply-templates select="key('topicref',$parentId)/*" mode="build-tree"/>
            <xsl:apply-templates mode="build-tree"
                                 select="key('topicref',$parentId)/following-sibling::*[contains(@class, ' bookmap/chapter ')
                                            or contains(@class, ' bookmap/appendix ')
                                            or contains(@class, ' bookmap/part ')]/*"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="*[contains(@class,' map/topicref ')]
                        [contains(@class, ' bookmap/chapter ')
                            or contains(@class, ' bookmap/appendix ')
                            or contains(@class, ' bookmap/part ')]
                        [not($isNochap)][not($isTechnote)]
                        [normalize-space(@href) = '']" mode="build-tree">
        <topic id="{generate-id()}" class="+ topic/topic pdf2-d/placeholder ">
            <title class="- topic/title ">
            </title>
            <xsl:apply-templates mode="build-tree"/>
        </topic>
    </xsl:template>

</xsl:stylesheet>
