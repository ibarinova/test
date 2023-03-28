<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:xs="http://www.w3.org/2001/XMLSchema"
				xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
				xmlns:related-links="http://dita-ot.sourceforge.net/ns/200709/related-links"
				xmlns:dita2html="http://dita-ot.sourceforge.net/ns/200801/dita2html"
				xmlns:ditamsg="http://dita-ot.sourceforge.net/ns/200704/ditamsg"
				version="2.0"
				exclude-result-prefixes="xs dita-ot related-links dita2html ditamsg ">

	<xsl:template match="*[contains(@class,' task/steps ')]" name="topic.task.steps">
		<!-- If there's one of these elements somewhere in a step, expand the whole step list -->
		<xsl:variable name="step_expand"> <!-- set & save step_expand=yes/no for expanding/compacting list items -->
			<xsl:apply-templates select="." mode="make-steps-compact"/>
		</xsl:variable>
		<xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
		<xsl:apply-templates select="." mode="common-processing-within-steps">
			<xsl:with-param name="step_expand" select="$step_expand"/>
			<xsl:with-param name="list-type" select="'ol'"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
	</xsl:template>

	<xsl:template match="*[contains(@class,' task/steps ') or contains(@class,' task/steps-unordered ')]"
				  mode="common-processing-within-steps">
		<xsl:param name="step_expand"/>
		<xsl:param name="list-type">
			<xsl:choose>
				<xsl:when test="contains(@class,' task/steps ')">ol</xsl:when>
				<xsl:otherwise>ul</xsl:otherwise>
			</xsl:choose>
		</xsl:param>

		<div class="task_steps_wraper{concat(' ', current()/@outputclass)[contains(current()/@outputclass, 'show_hide')]}">
			<xsl:call-template name="setidaname"/>
			<xsl:apply-templates select="." mode="generate-task-label">
				<xsl:with-param name="use-label">
					<xsl:call-template name="getDellString">
						<xsl:with-param name="dell-id">task_procedure-dell</xsl:with-param>
					</xsl:call-template>
				</xsl:with-param>
			</xsl:apply-templates>

			<div class="task_steps_content">
				<xsl:choose>
					<xsl:when test="*[contains(@class,' task/step ')] and not(*[contains(@class,' task/step ')][2])">
						<!-- Single step. Process any stepsection before the step (cannot appear after). -->
						<xsl:apply-templates select="*[contains(@class,' task/stepsection ')]"/>
						<xsl:apply-templates select="*[contains(@class,' task/step ')]" mode="onestep">
							<xsl:with-param name="step_expand" select="$step_expand"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:when test="not(*[contains(@class,' task/stepsection ')])">
						<xsl:apply-templates select="." mode="step-elements-with-no-stepsection">
							<xsl:with-param name="step_expand" select="$step_expand"/>
							<xsl:with-param name="list-type" select="$list-type"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:when
							test="*[1][contains(@class,' task/stepsection ')] and not(*[contains(@class,' task/stepsection ')][2])">
						<!-- Stepsection is first, no other appearances -->
						<xsl:apply-templates select="*[contains(@class,' task/stepsection ')]"/>
						<xsl:apply-templates select="." mode="step-elements-with-no-stepsection">
							<xsl:with-param name="step_expand" select="$step_expand"/>
							<xsl:with-param name="list-type" select="$list-type"/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>
						<!-- Stepsection elements mixed in with steps -->
						<xsl:apply-templates select="." mode="step-elements-with-stepsection">
							<xsl:with-param name="step_expand" select="$step_expand"/>
							<xsl:with-param name="list-type" select="$list-type"/>
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="*" mode="generate-task-label">
		<xsl:param name="use-label"/>
		<xsl:if test="$insert-task-labels and ($GENERATE-TASK-LABELS='YES')">
		<!-- IA   Tridion upgrade    Nov-2018   Add support for DELL 'task-label' othermeta parameter.
                Do not add task labels ONLY if 'task-labels' <othermeta> value equal 'no'.  - IB-->
			<xsl:variable name="headLevel">
				<xsl:variable name="headCount">
					<xsl:value-of select="count(ancestor::*[contains(@class,' topic/topic ')])+1"/>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="$headCount > 6">h6</xsl:when>
					<xsl:otherwise>h<xsl:value-of select="$headCount"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<div class="tasklabel">
				<xsl:element name="{$headLevel}">
					<xsl:attribute name="class">sectiontitle tasklabel</xsl:attribute>
					<xsl:value-of select="$use-label"/>
				</xsl:element>
			</div>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*[contains(@class,' task/prereq ')]" mode="dita2html:section-heading">
		<xsl:apply-templates select="." mode="generate-task-label">
			<xsl:with-param name="use-label">
				<xsl:call-template name="getDellString">
					<xsl:with-param name="dell-id" select="'task_prereq-dell'"/>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="*[contains(@class,' task/context ')]" mode="dita2html:section-heading">
		<xsl:apply-templates select="." mode="generate-task-label">
			<xsl:with-param name="use-label">
				<xsl:call-template name="getDellString">
					<xsl:with-param name="dell-id" select="'task_context-dell'"/>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="*[contains(@class,' task/postreq ')]" mode="dita2html:section-heading">
		<xsl:apply-templates select="." mode="generate-task-label">
			<xsl:with-param name="use-label">
				<xsl:call-template name="getDellString">
					<xsl:with-param name="dell-id" select="'task_postreq-dell'"/>
				</xsl:call-template>
			</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>

</xsl:stylesheet>
