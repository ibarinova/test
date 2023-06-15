<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:dita2html="http://dita-ot.sourceforge.net/ns/200801/dita2html"
                xmlns:ditamsg="http://dita-ot.sourceforge.net/ns/200704/ditamsg"                
                xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
                xmlns:table="http://dita-ot.sourceforge.net/ns/201007/dita-ot/table"
                xmlns:simpletable="http://dita-ot.sourceforge.net/ns/201007/dita-ot/simpletable"
                version="2.0"
                exclude-result-prefixes="xs dita2html ditamsg dita-ot table simpletable">


	<xsl:template match="*[contains(@class, ' topic/simpletable ')]
                            [not(contains(@class,' reference/properties '))]
                            [not(contains(@class,' task/choicetable '))]" mode="get-output-class">
		<xsl:variable name="class">
			<xsl:value-of select="'all'"/>
			<xsl:choose>
				<xsl:when test="ancestor::*[contains(@class, ' topic/li ')] or ancestor::*[contains(@class, ' topic/dd ')]">
					<xsl:value-of select="' no-pgwide'"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="' pgwide'"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:sequence select="$class"/>
	</xsl:template>

	<xsl:template match="*[contains(@class, ' topic/simpletable ')]" name="topic.simpletable">
		<xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>

		<xsl:call-template name="spec-title"/>
		<table>
			<xsl:apply-templates select="." mode="table:common"/>
			<xsl:call-template name="dita2html:simpletable-cols"/>

			<xsl:apply-templates select="*[contains(@class, ' topic/sthead ')]"/>
			<xsl:apply-templates select="." mode="generate-table-header"/>

			<tbody>
				<xsl:apply-templates select="*[contains(@class, ' topic/strow ')]"/>
			</tbody>
		</table>

		<xsl:if test="not(ancestor::*[contains(@class, ' topic/table ') or contains(@class,' topic/simpletable ')]) and
                (descendant::*[contains(@class, ' topic/fn ')] or descendant::*[contains(@class, ' topic/xref ')][@type = 'fn'])">

			<xsl:variable name="table">
				<xsl:copy-of select="."/>
			</xsl:variable>
			<xsl:call-template name="gen-table-endnotes">
				<xsl:with-param name="table" select="$table"/>
			</xsl:call-template>
		</xsl:if>

		<xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
	</xsl:template>

</xsl:stylesheet>