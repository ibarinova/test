<?xml version="1.0" encoding="UTF-8" ?>

<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ditamsg="http://dita-ot.sourceforge.net/ns/200704/ditamsg"
                xmlns:related-links="http://dita-ot.sourceforge.net/ns/200709/related-links"
                xmlns:relpath="http://dita2indesign/functions/relpath"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="related-links ditamsg relpath xs">

    <xsl:template match="*[contains(@class, ' topic/related-links ')]" name="topic.related-links"
                  use-when="not(starts-with(system-property('DOT_VERSION'), '1.'))">
        <nav role="navigation">
            <xsl:call-template name="commonattributes"/>
            <xsl:if test="$include.roles = ('child', 'descendant')">
                <xsl:call-template name="ul-child-links"/>
                <!--handle child/descendants outside of linklists in collection-type=unordered or choice-->
                <xsl:call-template name="ol-child-links"/>
                <!--handle child/descendants outside of linklists in collection-type=ordered/sequence-->
            </xsl:if>

            <xsl:variable name="links-role">
                <xsl:for-each select="descendant::*[contains(@class, ' topic/link ')][normalize-space(@role)]
                                            [not(related-links:omit-from-unordered-links(.))]
                                            [generate-id(.) = generate-id(key('hideduplicates', related-links:hideduplicates(.))[1])]">
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </xsl:variable>
            <xsl:variable name="links-no-role">
                <xsl:for-each select="descendant::*[contains(@class, ' topic/link ')][not(normalize-space(@role))]
                                            [not(related-links:omit-from-unordered-links(.))]
                                            [generate-id(.) = generate-id(key('hideduplicates', related-links:hideduplicates(.))[1])]">
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </xsl:variable>

            <xsl:variable name="links-filtered">
                <xsl:copy-of select="$links-role"/>
                <xsl:for-each select="$links-no-role/*">
                    <xsl:variable name="current-href" select="@href"/>
                    <xsl:if test="not($links-role/descendant::*[@href = $current-href])">
                        <xsl:copy-of select="."/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:variable>

            <xsl:variable name="unordered-links" as="element(linklist)*">
                <xsl:apply-templates select="." mode="related-links:group-unordered-links">
                    <xsl:with-param name="nodes" select="$links-filtered/*"/>
                </xsl:apply-templates>
            </xsl:variable>
            <xsl:apply-templates select="$unordered-links"/>
            <!--linklists - last but not least, create all the linklists and their links, with no sorting or re-ordering-->
<!--            <xsl:apply-templates select="*[contains(@class, ' topic/linklist ')]"/>-->
        </nav>
    </xsl:template>

    <!--
        Need to override the default DITA OT behavior of Reference, tasks and concepts which was grouped
        as Related Information in latest version of Oxygen Webhelp is re-enabled and overrided individually
        for Concepts, Tasks and References as Related Concepts, Related Tasks and Releated Informations
    -->
    <!-- Overriding code starts here -->

    <!-- References have their own group. -->
    <xsl:template match="*[contains(@class, ' topic/link ')][@type='reference']" mode="related-links:get-group"
                  name="related-links:group.reference"
                  as="xs:string">
        <xsl:text>reference</xsl:text>
    </xsl:template>

    <!-- Priority of reference group. -->
    <xsl:template match="*[contains(@class, ' topic/link ')][@type='reference']" mode="related-links:get-group-priority"
                  name="related-links:group-priority.reference"
                  as="xs:integer">
        <xsl:sequence select="1"/>
    </xsl:template>

    <!-- Reference wrapper for HTML: "Related reference" in <div>. -->
    <xsl:template match="*[contains(@class, ' topic/link ')][@type='reference']" mode="related-links:result-group"
                  name="related-links:result.reference" as="element()">
        <xsl:param name="links"/>
        <xsl:if test="exists($links)">
            <linklist class="- topic/linklist " outputclass="relinfo relref">
                <xsl:copy-of select="ancestor-or-self::*[@xml:lang][1]/@xml:lang"/>
                <title class="- topic/title ">
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'Related reference'"/>
                    </xsl:call-template>
                </title>
                <xsl:copy-of select="$links"/>
            </linklist>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/link ')][@type='task']" mode="related-links:get-group"
                  name="related-links:group.task"
                  as="xs:string">
        <xsl:text>task</xsl:text>
    </xsl:template>

    <!-- Priority of task group. -->
    <xsl:template match="*[contains(@class, ' topic/link ')][@type='task']" mode="related-links:get-group-priority"
                  name="related-links:group-priority.task"
                  as="xs:integer">
        <xsl:sequence select="2"/>
    </xsl:template>

    <!-- Task wrapper for HTML: "Related tasks" in <div>. -->
    <xsl:template match="*[contains(@class, ' topic/link ')][@type='task']" mode="related-links:result-group"
                  name="related-links:result.task" as="element()">
        <xsl:param name="links" as="node()*"/>
        <xsl:if test="exists($links)">
            <linklist class="- topic/linklist " outputclass="relinfo reltasks">
                <xsl:copy-of select="ancestor-or-self::*[@xml:lang][1]/@xml:lang"/>
                <title class="- topic/title ">
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'Related tasks'"/>
                    </xsl:call-template>
                </title>
                <xsl:copy-of select="$links"/>
            </linklist>
        </xsl:if>
    </xsl:template>

    <!-- Concepts have their own group. -->
    <xsl:template match="*[contains(@class, ' topic/link ')][@type='concept']" mode="related-links:get-group"
                  name="related-links:group.concept"
                  as="xs:string">
        <xsl:text>concept</xsl:text>
    </xsl:template>

    <!-- Priority of concept group. -->
    <xsl:template match="*[contains(@class, ' topic/link ')][@type='concept']" mode="related-links:get-group-priority"
                  name="related-links:group-priority.concept"
                  as="xs:integer">
        <xsl:sequence select="3"/>
    </xsl:template>

    <!-- Wrapper for concept group: "Related concepts" in a <div>. -->
    <xsl:template match="*[contains(@class, ' topic/link ')][@type='concept']" mode="related-links:result-group"
                  name="related-links:result.concept" as="element()">
        <xsl:param name="links" as="node()*"/>
        <xsl:if test="exists($links)">
            <linklist class="- topic/linklist " outputclass="relinfo relconcepts">
                <xsl:copy-of select="ancestor-or-self::*[@xml:lang][1]/@xml:lang"/>
                <title class="- topic/title ">
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'Related concepts'"/>
                    </xsl:call-template>
                </title>
                <xsl:copy-of select="$links"/>
            </linklist>
        </xsl:if>
    </xsl:template>

    <!-- Overriding code ends here -->

    <xsl:template match="*" mode="add-href-attribute">
        <xsl:choose>
            <xsl:when test="@keyref and $ditamap-doc/descendant::*[contains(@class, ' mapgroup-d/keydef ')][@keys = current()/@keyref][1][normalize-space(@href)]">
                <xsl:attribute name="href">
                    <xsl:apply-templates select="$ditamap-doc/descendant::*[contains(@class, ' mapgroup-d/keydef ')][@keys = current()/@keyref][1]" mode="determine-final-href"/>
                </xsl:attribute>
            </xsl:when>
            <xsl:when test="@href and normalize-space(@href)">
                <xsl:attribute name="href">
                    <xsl:apply-templates select="." mode="determine-final-href"/>
                </xsl:attribute>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>