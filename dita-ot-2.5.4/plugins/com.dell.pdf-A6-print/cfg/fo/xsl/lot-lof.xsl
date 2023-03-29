<?xml version='1.0'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:dita2xslfo="http://dita-ot.sourceforge.net/ns/200910/dita2xslfo"
                xmlns:opentopic="http://www.idiominc.com/opentopic"
                xmlns:opentopic-index="http://www.idiominc.com/opentopic/index"
                xmlns:ot-placeholder="http://suite-sol.com/namespaces/ot-placeholder"
                exclude-result-prefixes="opentopic opentopic-index dita2xslfo ot-placeholder"
                version="2.0">

    <xsl:template match="ot-placeholder:tablelist" name="createTableList">
        <xsl:if test="not($multilingual) and //*[contains(@class, ' topic/table ')]/*[contains(@class, ' topic/title ' )]">
            <!--exists tables with titles-->
            <fo:page-sequence master-reference="toc-sequence" xsl:use-attribute-sets="page-sequence.lot">
                <xsl:call-template name="insertTocStaticContents"/>
                <fo:flow flow-name="xsl-region-body">
                    <fo:block start-indent="0in">
                        <xsl:call-template name="createLOTHeader"/>

                        <xsl:apply-templates
                                select="//*[contains (@class, ' topic/table ')][child::*[contains(@class, ' topic/title ' )]]"
                                mode="list.of.tables"/>
                    </fo:block>
                </fo:flow>

            </fo:page-sequence>
        </xsl:if>
    </xsl:template>

    <xsl:template match="ot-placeholder:figurelist" name="createFigureList">
        <xsl:if test="not($multilingual) and //*[contains(@class, ' topic/fig ')]/*[contains(@class, ' topic/title ' )]">
            <!--exists figures with titles-->
            <fo:page-sequence master-reference="toc-sequence" xsl:use-attribute-sets="page-sequence.lof">

                <xsl:call-template name="insertTocStaticContents"/>
                <fo:flow flow-name="xsl-region-body">
                    <fo:block start-indent="0in">
                        <xsl:call-template name="createLOFHeader"/>

                        <xsl:apply-templates
                                select="//*[contains (@class, ' topic/fig ')][child::*[contains(@class, ' topic/title ' )]]"
                                mode="list.of.figures"/>
                    </fo:block>
                </fo:flow>

            </fo:page-sequence>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
