<?xml version='1.0'?>


<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:dita2xslfo="http://dita-ot.sourceforge.net/ns/200910/dita2xslfo"
    xmlns:opentopic="http://www.idiominc.com/opentopic"
    xmlns:exsl="http://exslt.org/common"
    xmlns:opentopic-index="http://www.idiominc.com/opentopic/index"
    extension-element-prefixes="exsl"
    exclude-result-prefixes="opentopic exsl opentopic-index dita2xslfo"
    version="2.0">

    <!-- 
        Revision History
        ================
        Suite/EMC   SOW7    19-Feb-2013   Prevent right margin overflow
        Suite/EMC   SOW7    24-Feb-2013   Remove Task Context heading
        Suite/EMC   SOW5    19-Mar-2013   fix pagebreak processing for steps
        Natasha     IB2     25-Jun-2013   Added Procedure title to the unordered lists
        EMC 	    IB3     28-Oct-2013	  Issue 342: Example element subheading is not numbered in PDF output of task topics
		EMC 		IB6 	21-Oct-2014   TKT-173: Extra page breaks inserted in Task steps in PDF output
		EMC			IB7		12-Jan-2015	  TKT-211 Localize @importance for step
		EMC 		IB7	  	19-Jan-2015   TKT-73: Increase spacing after <info> tag
    -->
   
    <!-- Suite/EMC   SOW7  18-Feb-2013   add in ootb choicetable template so that it should not be overridden by customized simpletable template - rs -->
    <xsl:template match="*[contains(@class, ' task/choicetable ')]">
        <fo:table xsl:use-attribute-sets="choicetable" table-omit-footer-at-break="true">
            <xsl:call-template name="commonattributes"/>
            <xsl:call-template name="univAttrs"/>
            <xsl:call-template name="globalAtts"/>
            
            <xsl:if test="@relcolwidth">
                <xsl:variable name="fix-relcolwidth">
                    <xsl:apply-templates select="." mode="fix-relcolwidth">
                        <xsl:with-param name="number-cells" select="2"/>
                    </xsl:apply-templates>
                </xsl:variable>
                <xsl:call-template name="createSimpleTableColumns">
                    <xsl:with-param name="theColumnWidthes" select="$fix-relcolwidth"/>
                </xsl:call-template>
            </xsl:if>
            
            <xsl:choose>
                <xsl:when test="*[contains(@class, ' task/chhead ')]">
                    <xsl:apply-templates select="*[contains(@class, ' task/chhead ')]"/>
                </xsl:when>
                <xsl:otherwise>
                    <fo:table-header xsl:use-attribute-sets="chhead">
                        <fo:table-row xsl:use-attribute-sets="chhead__row">
                            <fo:table-cell xsl:use-attribute-sets="chhead.choptionhd">
                                <fo:block xsl:use-attribute-sets="chhead.choptionhd__content">
                                    <!-- EMC IB5 21-Aug-2014 TKT-139: Make "Option"/"Description" headers on <choicetable> consistent for noted output -->
                                    <xsl:call-template name="getVariable">
                                        <xsl:with-param name="id" select="'Option'"/>
                                    </xsl:call-template>
                                    <!--xsl:text>Options</xsl:text-->
                                </fo:block>
                            </fo:table-cell>
                            <fo:table-cell xsl:use-attribute-sets="chhead.chdeschd">
                                <fo:block xsl:use-attribute-sets="chhead.chdeschd__content">
                                    <!-- EMC IB5 21-Aug-2014 TKT-139: Make "Option"/"Description" headers on <choicetable> consistent for noted output -->
                                    <xsl:call-template name="getVariable">
                                        <xsl:with-param name="id" select="'Description'"/>
                                    </xsl:call-template>
                                </fo:block>
                            </fo:table-cell>
                        </fo:table-row>
                    </fo:table-header>
                </xsl:otherwise>
            </xsl:choose>
            <fo:table-body xsl:use-attribute-sets="choicetable__body">
                <xsl:apply-templates select="*[contains(@class, ' task/chrow ')]"/>
                <!-- EMC	9-May-2015		Fix for table footnote issue in production for PDF corruption -->
                <!-- EMC	Hotfix_3.2		23-Jun-2015		TKT 298: Fix for table footnote -->
                <!--fo:table-footer xsl:use-attribute-sets="table.footer"-->
                <fo:table-row>
                    <fo:table-cell number-columns-spanned="2" xsl:use-attribute-sets="tablefootnote">
                        <fo:block>
                            <xsl:apply-templates select="descendant::*[contains(@class,' topic/fn ')]" mode="from-table" />
                        </fo:block>
                    </fo:table-cell>
                </fo:table-row>
                <!--/fo:table-footer-->
            </fo:table-body>
        </fo:table>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' task/postreq ')]">
        <fo:block xsl:use-attribute-sets="postreq">
            <xsl:call-template name="commonattributes"/>
            <xsl:apply-templates select="." mode="dita2xslfo:task-heading">
                <xsl:with-param name="use-label">
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'Task Postreq'"/>
                    </xsl:call-template>
                </xsl:with-param>
            </xsl:apply-templates>
            <fo:block xsl:use-attribute-sets="prereq-space">
                <xsl:apply-templates/>
            </fo:block>
        </fo:block>
    </xsl:template>
	
    <xsl:template match="*[contains(@class, ' task/result ')]">
        <fo:block xsl:use-attribute-sets="result">
            <xsl:call-template name="commonattributes"/>
            <xsl:apply-templates select="." mode="dita2xslfo:task-heading">
                <xsl:with-param name="use-label">
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'Task Result'"/>
                    </xsl:call-template>
                </xsl:with-param>
            </xsl:apply-templates>
            <fo:block xsl:use-attribute-sets="result-space">
            <xsl:apply-templates/>
			</fo:block>
        </fo:block>
    </xsl:template>	
    
    <xsl:template match="*[contains(@class, ' task/prereq ')]">
        <fo:block xsl:use-attribute-sets="prereq">
            <xsl:call-template name="commonattributes"/>
            <xsl:apply-templates select="." mode="dita2xslfo:task-heading">
                <xsl:with-param name="use-label">
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'Task Prereq'"/>
                    </xsl:call-template>
                </xsl:with-param>
            </xsl:apply-templates>
            <fo:block xsl:use-attribute-sets="result-space">
            <xsl:apply-templates/>
			</fo:block>
        </fo:block>
    </xsl:template>

    <!-- IA   Tridion upgrade    Jan-2019   IDPL-4878 - Add 'About this Task' heading for <task>/<context> tag.  - IB-->
    <xsl:template match="*[contains(@class, ' task/context ')]">
        <fo:block xsl:use-attribute-sets="context">
            <xsl:call-template name="commonattributes"/>
            <xsl:apply-templates select="." mode="dita2xslfo:task-heading">
                <xsl:with-param name="use-label">
                    <xsl:call-template name="insertVariable">
                        <xsl:with-param name="theVariableID" select="'Task Context'"/>
                    </xsl:call-template>
                </xsl:with-param>
            </xsl:apply-templates>
            <fo:block xsl:use-attribute-sets="result-space">
                <xsl:apply-templates/>
            </fo:block>
        </fo:block>
    </xsl:template>

    <xsl:template match="*" mode="dita2xslfo:task-heading">
        <!-- Remove condition, to print auto-generated task subheadings  -->
        <xsl:param name="use-label"/>

        <!-- IA   Tridion upgrade    Oct-2018   Add support for DELL othermeta parameters.
                                                Do not add task labels ONLY if 'task-labels' <othermeta> value equal 'no'.  - IB-->
        <xsl:if test="$generate-task-labels">
            <fo:block xsl:use-attribute-sets="task.label">
                <fo:inline><xsl:value-of select="$use-label"/></fo:inline>
            </fo:block>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' task/steps ')]">
        <!-- Suite/EMC   SOW7  14-Feb-2013 Remove condition, to print auto-generated task subheadings  - AW -->
                <fo:block>
                    <xsl:apply-templates select="." mode="dita2xslfo:task-heading">
                        <xsl:with-param name="use-label">
                            <xsl:call-template name="getVariable">
                                <xsl:with-param name="id" select="'Task Steps'"/>
                            </xsl:call-template>
                        </xsl:with-param>
                    </xsl:apply-templates>
                    <fo:list-block xsl:use-attribute-sets="steps">
                        <xsl:call-template name="commonattributes"/>
                        <xsl:apply-templates/>
                    </fo:list-block>
                </fo:block>
    </xsl:template>
    <!-- Natasha IB2 6/25/2013 Added template for un-ordered lists Procedure header-->
    <xsl:template match="*[contains(@class, ' task/steps-unordered ')]">
        <fo:block>
            <xsl:apply-templates select="." mode="dita2xslfo:task-heading">
                <xsl:with-param name="use-label">
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'Task Steps'"/>
                    </xsl:call-template>
                </xsl:with-param>
            </xsl:apply-templates>
            <fo:list-block xsl:use-attribute-sets="steps-unordered">
                <xsl:call-template name="commonattributes"/>
                <xsl:apply-templates/>
            </fo:list-block>
        </fo:block>
    </xsl:template>

    <!-- Suite/EMC  SOW7    19-Feb-2013     Prevent right margin overlow - send tunnel parameter parent=substep to prevent margin overflow START - rs -->
    <xsl:template match="*[contains(@class, ' task/substeps ')]/*[contains(@class, ' task/substep ')]">
        
        <!-- Suite/EMC   SOW5    19-Mar-2013   fix pagebreak processing for steps -->
        <xsl:param name="pagebreak" tunnel="yes">no</xsl:param>
        
        <fo:list-item xsl:use-attribute-sets="substeps.substep">
            <!-- EMC IB6 21-Oct-2014 TKT-173: Extra page breaks inserted in Task steps in PDF output -->
            <xsl:if test="$pagebreak='yes' and self::*[contains(@outputclass, 'pagebreak')]">
                <xsl:attribute name="break-before">page</xsl:attribute>
            </xsl:if>
            
            <fo:list-item-label xsl:use-attribute-sets="substeps.substep__label">
                <fo:block xsl:use-attribute-sets="substeps.substep__label__content">
                    <fo:inline>
                        <xsl:call-template name="commonattributes"/>
                    </fo:inline>
                    <xsl:number format="a. "/>
                </fo:block>
            </fo:list-item-label>
            <fo:list-item-body xsl:use-attribute-sets="substeps.substep__body">
                <fo:block xsl:use-attribute-sets="substeps.substep__content">
                    <xsl:apply-templates>
                        <xsl:with-param name="parent" tunnel="yes">substep</xsl:with-param>
                    </xsl:apply-templates>
                </fo:block>
            </fo:list-item-body>
        </fo:list-item>
    </xsl:template>
    
	<!-- EMC   		 IB3   14-Nov-2013 Issue 347: Task <substep> spacing should match <steps> spacing 6.5pt -->
	<xsl:template match="*[contains(@class, ' task/substeps ')]">
        <fo:list-block xsl:use-attribute-sets="substeps">
            <xsl:call-template name="commonattributes"/>
            <xsl:apply-templates/>
        </fo:list-block>
    </xsl:template>

	<!-- EMC		IB7		12-Jan-2015		TKT-211 Localize @importance for step -->
    <xsl:template match="*[contains(@class, ' task/cmd ')]" priority="1">
        <fo:block xsl:use-attribute-sets="cmd">
            <xsl:call-template name="commonattributes"/>
            <xsl:if test="../@importance='optional'">
                <xsl:call-template name="getVariable">
                    <xsl:with-param name="id" select="'Optional Step'"/>
                </xsl:call-template>
            </xsl:if>
			<xsl:if test="../@importance='required'">
                <xsl:call-template name="getVariable">
                    <xsl:with-param name="id" select="'Required Step'"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:apply-templates/>
      </fo:block>
    </xsl:template>
	<!-- EMC 	IB7	  	19-Jan-2015 	 TKT-73: Increase spacing after <info> tag -->
    <xsl:template match="*[contains(@class, ' task/info ')]">
        <fo:block xsl:use-attribute-sets="info">
            <xsl:call-template name="commonattributes"/>
			<xsl:choose>
			    <xsl:when test="contains(descendant::*[1]/@class, 'table')">
			        <xsl:attribute name="space-before.optimum">6pt</xsl:attribute>
			        <fo:block space-after.optimum="5pt">
			            <xsl:apply-templates select="text()"/>
			        </fo:block>
					<xsl:apply-templates select="*"/>
			    </xsl:when>
			    <xsl:otherwise>
			        <xsl:apply-templates/>
			    </xsl:otherwise>
			</xsl:choose>
        </fo:block>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' task/stepsection ')]">
        <fo:list-item xsl:use-attribute-sets="stepsection">
            <xsl:call-template name="commonattributes"/>
            <fo:list-item-label xsl:use-attribute-sets="stepsection__label">
                <fo:block xsl:use-attribute-sets="stepsection__label__content">
                </fo:block>
            </fo:list-item-label>

            <fo:list-item-body xsl:use-attribute-sets="stepsection__body">
                <fo:block xsl:use-attribute-sets="stepsection__content">
                    <xsl:apply-templates/>
                </fo:block>
            </fo:list-item-body>

        </fo:list-item>
    </xsl:template>

</xsl:stylesheet>
