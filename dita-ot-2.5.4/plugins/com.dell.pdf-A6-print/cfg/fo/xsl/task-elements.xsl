<?xml version='1.0'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:dita2xslfo="http://dita-ot.sourceforge.net/ns/200910/dita2xslfo"
                xmlns:opentopic="http://www.idiominc.com/opentopic"
                xmlns:opentopic-index="http://www.idiominc.com/opentopic/index"
                exclude-result-prefixes="opentopic opentopic-index dita2xslfo"
                version="2.0">

    <xsl:template match="*[contains(@class, ' task/prereq ')]">
        <fo:block xsl:use-attribute-sets="prereq">
            <xsl:call-template name="commonattributes"/>
            <xsl:if test="$task-labels-required">
                <xsl:apply-templates select="." mode="dita2xslfo:task-heading">
                    <xsl:with-param name="use-label">
                        <xsl:apply-templates select="." mode="dita2xslfo:retrieve-task-heading">
                            <xsl:with-param name="pdf2-string">task_prereq-dell</xsl:with-param>
                            <xsl:with-param name="common-string">task_prereq</xsl:with-param>
                        </xsl:apply-templates>
                    </xsl:with-param>
                </xsl:apply-templates>
            </xsl:if>
            <fo:block xsl:use-attribute-sets="prereq__content">
                <xsl:apply-templates/>
            </fo:block>
        </fo:block>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' task/context ')]">
        <fo:block xsl:use-attribute-sets="context">
            <xsl:call-template name="commonattributes"/>
            <xsl:if test="$task-labels-required">
                <xsl:apply-templates select="." mode="dita2xslfo:task-heading">
                    <xsl:with-param name="use-label">
                        <xsl:apply-templates select="." mode="dita2xslfo:retrieve-task-heading">
                            <xsl:with-param name="pdf2-string">task_context-dell</xsl:with-param>
                            <xsl:with-param name="common-string">task_context</xsl:with-param>
                        </xsl:apply-templates>
                    </xsl:with-param>
                </xsl:apply-templates>
            </xsl:if>
            <fo:block xsl:use-attribute-sets="context__content">
                <xsl:apply-templates/>
            </fo:block>
        </fo:block>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' task/taskbody ')]/*[contains(@class, ' topic/example ')]">
        <fo:block xsl:use-attribute-sets="task.example">
            <xsl:call-template name="commonattributes"/>
            <xsl:if test="$task-labels-required">

                <xsl:choose>
                    <xsl:when test="*[contains(@class, ' topic/title ')]">
                        <xsl:apply-templates select="*[contains(@class, ' topic/title ')]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="." mode="dita2xslfo:task-heading">
                            <xsl:with-param name="use-label">
                                <xsl:apply-templates select="." mode="dita2xslfo:retrieve-task-heading">
                                    <xsl:with-param name="pdf2-string">task_example-dell</xsl:with-param>
                                    <xsl:with-param name="common-string">task_example</xsl:with-param>
                                </xsl:apply-templates>
                            </xsl:with-param>
                        </xsl:apply-templates>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
            <fo:block xsl:use-attribute-sets="task.example__content">
                <xsl:apply-templates
                        select="*[not(contains(@class, ' topic/title '))]|text()|processing-instruction()"/>
            </fo:block>
        </fo:block>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' task/postreq ')]">
        <fo:block xsl:use-attribute-sets="postreq">
            <xsl:call-template name="commonattributes"/>
            <xsl:if test="$task-labels-required">
                <xsl:apply-templates select="." mode="dita2xslfo:task-heading">
                    <xsl:with-param name="use-label">
                        <xsl:apply-templates select="." mode="dita2xslfo:retrieve-task-heading">
                            <xsl:with-param name="pdf2-string">task_postreq-dell</xsl:with-param>
                            <xsl:with-param name="common-string">task_postreq</xsl:with-param>
                        </xsl:apply-templates>
                    </xsl:with-param>
                </xsl:apply-templates>
            </xsl:if>
            <fo:block xsl:use-attribute-sets="postreq__content">
                <xsl:apply-templates/>
            </fo:block>
        </fo:block>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' task/steps ')]" name="steps">
        <xsl:if test="$task-labels-required">
            <xsl:apply-templates select="." mode="dita2xslfo:task-heading">
                <xsl:with-param name="use-label">
                    <xsl:apply-templates select="." mode="dita2xslfo:retrieve-task-heading">
                        <xsl:with-param name="pdf2-string">task_procedure-dell</xsl:with-param>
                        <xsl:with-param name="common-string">task_procedure</xsl:with-param>
                    </xsl:apply-templates>
                </xsl:with-param>
            </xsl:apply-templates>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="count(*[contains(@class, ' task/step ')]) eq 1">
                <fo:block>
                    <xsl:call-template name="commonattributes"/>
                    <xsl:apply-templates mode="onestep"/>
                </fo:block>
            </xsl:when>
            <xsl:otherwise>
                <fo:list-block xsl:use-attribute-sets="steps">
                    <xsl:call-template name="commonattributes"/>
                    <xsl:apply-templates/>
                </fo:list-block>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' task/steps-unordered ')]" name="steps-unordered">
        <xsl:if test="$task-labels-required">
            <xsl:apply-templates select="." mode="dita2xslfo:task-heading">
                <xsl:with-param name="use-label">
                    <xsl:apply-templates select="." mode="dita2xslfo:retrieve-task-heading">
                        <xsl:with-param name="pdf2-string">task_procedure-dell</xsl:with-param>
                        <xsl:with-param name="common-string">task_procedure_unordered</xsl:with-param>
                    </xsl:apply-templates>
                </xsl:with-param>
            </xsl:apply-templates>
        </xsl:if>
        <fo:list-block xsl:use-attribute-sets="steps-unordered">
            <xsl:call-template name="commonattributes"/>
            <xsl:apply-templates/>
        </fo:list-block>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' task/result ')]">
        <fo:block xsl:use-attribute-sets="result">
            <xsl:call-template name="commonattributes"/>
            <xsl:if test="$task-labels-required">
                <xsl:apply-templates select="." mode="dita2xslfo:task-heading">
                    <xsl:with-param name="use-label">
                        <xsl:apply-templates select="." mode="dita2xslfo:retrieve-task-heading">
                            <xsl:with-param name="pdf2-string">Task Result</xsl:with-param>
                            <xsl:with-param name="common-string">task_results</xsl:with-param>
                        </xsl:apply-templates>
                    </xsl:with-param>
                </xsl:apply-templates>
            </xsl:if>
            <fo:block xsl:use-attribute-sets="result__content">
                <xsl:apply-templates/>
            </fo:block>
        </fo:block>
    </xsl:template>

</xsl:stylesheet>
