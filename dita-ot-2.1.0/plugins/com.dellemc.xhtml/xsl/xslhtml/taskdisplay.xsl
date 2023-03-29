<?xml version="1.0" encoding="UTF-8" ?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:related-links="http://dita-ot.sourceforge.net/ns/200709/related-links"
                xmlns:dita2html="http://dita-ot.sourceforge.net/ns/200801/dita2html"
                exclude-result-prefixes="related-links dita2html"
				version="2.0">

	<xsl:template match="*" mode="add-step-importance-flag">
		<xsl:choose>
			<xsl:when test="@importance='optional'">
				<strong>
					<xsl:call-template name="getVariable">
						<xsl:with-param name="id" select="'Step optional 1'"/>
					</xsl:call-template>
				</strong>
			</xsl:when>
			<xsl:when test="@importance='required'">
				<strong>
					<xsl:call-template name="getVariable">
						<xsl:with-param name="id" select="'Step required 1'"/>
					</xsl:call-template>
				</strong>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*[contains(@class, ' topic/link ')][@type='task']" mode="related-links:result-group"
				  name="related-links:result.task" as="element(linklist)">
		<xsl:param name="links" as="node()*"/>
		<xsl:if test="normalize-space(string-join($links, ''))">
			<linklist class="- topic/linklist " outputclass="relinfo reltasks">
				<title class="- topic/title ">
					<xsl:call-template name="getVariable">
						<xsl:with-param name="id" select="'Related Tasks Open'"/>
					</xsl:call-template>
				</title>
				<xsl:copy-of select="$links"/>
			</linklist>
		</xsl:if>
	</xsl:template>

	<!-- EMC 		15-Oct-2014		Customized from webhelp, changed the path of GIF files -->
	<xsl:template match="*[contains(@class,' task/steps ')]" name="topic.task.steps">
		<xsl:variable name="step_expand"> <!-- set & save step_expand=yes/no for expanding/compacting list items -->
			<xsl:apply-templates select="." mode="make-steps-compact"/>
		</xsl:variable>
		<xsl:choose>
            <xsl:when test="contains(@outputclass,'show_hide_expanded') and @id">
                <p>
                    <!--<div class="p collapsible">-->
                    <xsl:call-template name="commonattributes"/>
                    <xsl:call-template name="setid"/>
                    <xsl:element name="a">
                        <xsl:attribute name="href">
                            <xsl:text>javascript:toggleTwisty('</xsl:text>
                            <xsl:value-of select="@id"/>
                            <xsl:text>');</xsl:text>
                        </xsl:attribute>
                        <xsl:element name="img">
                            <xsl:attribute name="class">show_hide_expanded</xsl:attribute>
                            <xsl:attribute name="src">
                                <xsl:value-of select="'expanded.gif'"/>
                            </xsl:attribute>
                        </xsl:element>
                    </xsl:element>
                    <xsl:element name="div">
                        <xsl:attribute name="id">
                            <xsl:value-of select="@id"/>
                        </xsl:attribute>
                        <xsl:apply-templates select="." mode="common-processing-within-steps">
                            <xsl:with-param name="step_expand" select="$step_expand"/>
                            <xsl:with-param name="list-type" select="'ol'"/>
                        </xsl:apply-templates>
                    </xsl:element>
                    <!--</div>-->
                </p>
            </xsl:when>
            <xsl:when test="contains(@outputclass,'show_hide') and @id">
				<p>
					<!--<div class="p collapsible">-->
					<xsl:call-template name="commonattributes"/>
					<xsl:call-template name="setid"/>
					<xsl:element name="a">
						<xsl:attribute name="href">
							<xsl:text>javascript:toggleTwisty('</xsl:text>
							<xsl:value-of select="@id"/>
							<xsl:text>');</xsl:text>
						</xsl:attribute>
						<xsl:element name="img">
							<xsl:attribute name="class">show_hide_expanded</xsl:attribute>
							<xsl:attribute name="src">
								<xsl:value-of select="'collapse.gif'"/>
							</xsl:attribute>
						</xsl:element>
					</xsl:element>
					<xsl:element name="div">
						<xsl:attribute name="id">
							<xsl:value-of select="@id"/>
						</xsl:attribute>
                        <xsl:attribute name="style">
                            <xsl:value-of select="'display: none;'"/>
                        </xsl:attribute>
						<xsl:apply-templates select="." mode="common-processing-within-steps">
							<xsl:with-param name="step_expand" select="$step_expand"/>
							<xsl:with-param name="list-type" select="'ol'"/>
						</xsl:apply-templates>
					</xsl:element>
					<!--</div>-->
				</p>
				<!-- 20-Nov-2013 'show_hide_expanded' should be open be default, when the page is opened. -->
				<!--script type="text/javascript">
                  <xsl:text>hideTwisty('</xsl:text>
                  <xsl:value-of select="@id"/>
                  <xsl:text>');</xsl:text>
                </script-->
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="." mode="common-processing-within-steps">
					<xsl:with-param name="step_expand" select="$step_expand"/>
					<xsl:with-param name="list-type" select="'ol'"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- EMC	15-Oct-2014		Added priority to avoid the conflict with the simpletable -->
	<!-- Comtech Services 10/24/2013 added to conditionalize the footnotes for tables -->
	<!-- render any contained footnotes as endnotes.  Links back to reference point -->
	<!-- choice table is like a simpletable - 2 columns, set heading -->
    <xsl:template match="*[contains(@class,' task/choicetable ')]" name="topic.task.choicetable" priority="5">
        <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
        <xsl:call-template name="setaname"/>
        <xsl:value-of select="$newline"/>
        <table border="1" frame="hsides" rules="rows" cellpadding="4" cellspacing="0" summary="" class="choicetableborder">
            <xsl:call-template name="commonattributes"/>
            <xsl:apply-templates select="." mode="generate-table-summary-attribute"/>
            <xsl:call-template name="setid"/>
            <xsl:value-of select="$newline"/>
            <xsl:call-template name="dita2html:simpletable-cols"/>
            <!--If the choicetable has no header - output a default one-->
            <xsl:variable name="chhead" as="element()?">
                <xsl:choose>
                    <xsl:when test="exists(*[contains(@class,' task/chhead ')])">
                        <xsl:sequence select="*[contains(@class,' task/chhead ')]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="gen" as="element(gen)?">
                            <xsl:call-template name="gen-chhead"/>
                        </xsl:variable>
                        <xsl:sequence select="$gen/*"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:apply-templates select="$chhead"/>
            <tbody>
                <xsl:apply-templates select="*[contains(@class, ' task/chrow ')]"/>
            </tbody>
        </table>
        <xsl:value-of select="$newline"/>
        <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
        <xsl:if test="not(ancestor::*[contains(@class, ' topic/table ') or contains(@class,' topic/simpletable ')]) and
                (descendant::*[contains(@class, ' topic/fn ') or (contains(@class, ' topic/xref ')and @type = 'fn')])">
            <xsl:variable name="table">
                <xsl:copy-of select="."/>
            </xsl:variable>
            <xsl:call-template name="gen-table-endnotes">
                <xsl:with-param name="table" select="$table"/>
            </xsl:call-template>
        </xsl:if>

    </xsl:template>

    <xsl:template match="*[contains(@class,' task/choices ')]" name="topic.task.choices">
        <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
        <xsl:call-template name="setaname"/>
        <ul>
            <xsl:call-template name="commonattributes"/>
            <xsl:call-template name="setid"/>
            <xsl:attribute name="class"><xsl:value-of select="concat('ul choices', ' disc')"/></xsl:attribute>
            <xsl:apply-templates/>
        </ul><xsl:value-of select="$newline"/>
        <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
    </xsl:template>

    <!-- Comtech Services 09/09/2013 remove context gentext -->
    <xsl:template match="*[contains(@class,' task/context ')]" mode="dita2html:section-heading">
        <!--<xsl:apply-templates select="." mode="generate-task-label">
          <xsl:with-param name="use-label">
            <xsl:call-template name="getString">
              <xsl:with-param name="stringName" select="'task_context'"/>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:apply-templates>-->
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

    <xsl:template match="*[contains(@class,' task/taskbody ')]/*[contains(@class,' topic/example ')]/*[contains(@class,' topic/title ')]"
            mode="dita2html:section-heading" priority="10">
        <xsl:param name="headLevel">
            <xsl:variable name="headCount" select="count(ancestor::*[contains(@class, ' topic/topic ')])+1"/>
            <xsl:choose>
                <xsl:when test="$headCount > 6">h6</xsl:when>
                <xsl:otherwise>h<xsl:value-of select="$headCount"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:param>
        <xsl:if test="$insert-task-labels">
            <!-- IA   Tridion upgrade    Oct-2018   Add support for DELL 'task-label' othermeta parameter.
          Do not add task labels ONLY if 'task-labels' <othermeta> value equal 'no'.  - IB-->
            <xsl:element name="{$headLevel}">
                <xsl:attribute name="class">sectiontitle</xsl:attribute>
                <xsl:call-template name="commonattributes">
                    <xsl:with-param name="default-output-class" select="'sectiontitle'"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:element>

        </xsl:if>
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
        <xsl:apply-templates select="." mode="generate-task-label">
            <xsl:with-param name="use-label">
                <xsl:call-template name="getVariable">
                    <xsl:with-param name="id" select="'Steps Open'"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:apply-templates>
        <xsl:choose>
            <xsl:when
                    test="*[contains(@class,' task/step ')] and not(*[contains(@class,' task/step ')][2])">
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
    </xsl:template>

    <!--
         To override the task label for a specific element, match that element with this mode.
         For example, you can turn off labels for <context> with this rule:
         <xsl:template match="*[contains(@class,' task/context ')]" mode="generate-task-label"/>
    -->
    <!-- EMC	IB7		31-Dec-2014		Added logic to read the translated strings from the external file -->
    <xsl:template match="*" mode="generate-task-label">
        <xsl:param name="use-label"/>
        <xsl:if test="$GENERATE-TASK-LABELS='YES' and $insert-task-labels">
            <xsl:variable name="headLevel">
                <xsl:variable name="headCount">
                    <xsl:value-of select="count(ancestor::*[contains(@class,' topic/topic ')])+1"/>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="$headCount > 6">h6</xsl:when>
                    <xsl:otherwise>h<xsl:value-of select="$headCount"/></xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <div class="tasklabel">
                <xsl:element name="{$headLevel}">
                    <xsl:attribute name="class">sectiontitle tasklabel</xsl:attribute>
                    <!--xsl:value-of select="$use-label"/-->
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="$use-label"/>
                    </xsl:call-template>
                </xsl:element>
            </div>
        </xsl:if>
    </xsl:template>

    <!-- EMC		IB7		12-Jan-2015		TKT-211 Localize ”Optional” and “Required” in elements with @importance -->
    <xsl:template match="*[contains(@class,' task/step ')]">
        <xsl:apply-templates select="." mode="steps"/>
    </xsl:template>
</xsl:stylesheet>
