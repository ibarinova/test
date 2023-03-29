<?xml version="1.0" encoding="UTF-8" ?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:related-links="http://dita-ot.sourceforge.net/ns/200709/related-links"
                xmlns:dita2html="http://dita-ot.sourceforge.net/ns/200801/dita2html"
                exclude-result-prefixes="related-links dita2html"
				version="2.0">

	<xsl:template match="*[contains(@class,' task/steps ')]" name="topic.task.steps">
		<xsl:variable name="step_expand"> <!-- set & save step_expand=yes/no for expanding/compacting list items -->
			<xsl:apply-templates select="." mode="make-steps-compact"/>
		</xsl:variable>
        <xsl:apply-templates select="." mode="common-processing-within-steps">
            <xsl:with-param name="step_expand" select="$step_expand"/>
            <xsl:with-param name="list-type" select="'ol'"/>
        </xsl:apply-templates>
	</xsl:template>

	<xsl:template match="*[contains(@class,' task/prereq ')]" mode="dita2html:section-heading">
		<xsl:apply-templates select="." mode="generate-task-label">
			<xsl:with-param name="use-label">
				<xsl:call-template name="getVariable">
					<xsl:with-param name="id" select="'Prerequisite Open'"/>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="*[contains(@class,' task/result ')]" mode="dita2html:section-heading">
		<xsl:apply-templates select="." mode="generate-task-label">
			<xsl:with-param name="use-label">
				<xsl:call-template name="getVariable">
					<xsl:with-param name="id" select="'Result Open'"/>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="*[contains(@class,' task/postreq ')]" mode="dita2html:section-heading">
		<xsl:apply-templates select="." mode="generate-task-label">
			<xsl:with-param name="use-label">
				<xsl:call-template name="getVariable">
					<xsl:with-param name="id" select="'Postrequisite Open'"/>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="*[contains(@class,' task/taskbody ')]/*[contains(@class,' topic/example ')][not(*[contains(@class,' topic/title ')])]"
				  mode="dita2html:section-heading">
		<xsl:apply-templates select="." mode="generate-task-label">
			<xsl:with-param name="use-label">
				<xsl:call-template name="getVariable">
					<xsl:with-param name="id" select="'Example Open'"/>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>
</xsl:stylesheet>
