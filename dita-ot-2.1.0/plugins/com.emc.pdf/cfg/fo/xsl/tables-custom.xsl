<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:opentopic-func="http://www.idiominc.com/opentopic/exsl/function"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:psmi="http://www.CraneSoftwrights.com/resources/psmi"
  xmlns:dita2xslfo="http://dita-ot.sourceforge.net/ns/200910/dita2xslfo"
  xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
  exclude-result-prefixes="opentopic-func xs dita2xslfo dita-ot"
  version="2.0">


    <!--
    Revision History
    ================
    Suite/EMC   SOW5  16-Mar-2012   table label should be bold
    Suite/EMC   SOW5  18-Mar-2012   remove margin from landscape tables
    Suite/EMC   SOW5  04-Apr-2012   Pagewide and landscape functionality for talbe should apply when no title exists, and improve landscape margins for table.
    Suite/EMC   SOW7  31-Dec-2012   replace continuation notation
    Suite/EMC   SOW7  18-Feb-2013   add in ootb choicetable template so that it should not be overridden by customized simpletable template
    Suite/EMC   SOW7  19-Feb-2013   Prevent right margin overflow
	EMC 	 	IB4	  18-Mar-2014	Commented logic that adds double border for thead, as it causes formatting issue when tables have namest, nameend, morerows attr
	EMC 		IB5   21-Aug-2014   TKT-139: Make "Option"/"Description" headers on <choicetable> consistent for noted output
	EMC 		IB6   21-Oct-2014   TKT-157:Table breaks within bottom row and bottom frame is cut off (PDF)
	EMC				  9-May-2015	Fix for table footnote issue in production for PDF corruption
	EMC	  Hotfix_3.2  23-Jun-2015	TKT 298: Fix for table footnote
	EMC	       IB8	 18-Nov-2015	TKT-262: No pagebreak between <dt> and immediate following <dd> (regression bug)
	-->

    <xsl:variable name="table.rowsep-default" select="'1'"/>
    <xsl:variable name="table.colsep-default" select="'1'"/>

  <!-- Suite Dec-2011:
  1) If table has title, wraps table in outer table and inserts recurring caption.
  2) Inserts continuation markers and numbering on all pages but first (for example, <Table Title> (continued, page 2 of 3) -->
  <xsl:template match="*[contains(@class, ' topic/tgroup ')]" name="tgroup">
    <!-- Suite/EMC   SOW7  19-Feb-2013   Prevent right margin overflow - add parent parameter - rs -->
    <xsl:param name="parent" tunnel="yes" select="''"/>

    <xsl:if test="not(@cols)">
      <xsl:message terminate="yes">
        <xsl:text>ERROR: Number of columns must be specified.</xsl:text>
      </xsl:message>
    </xsl:if>

    <xsl:variable name="scale">
      <xsl:call-template name="getTableScale"/>
    </xsl:variable>

    <xsl:variable name="table">

      <!--If table has title - wraps table in table and inserts recurring caption - rs-->
      <!--<xsl:choose >

        <xsl:when test="preceding-sibling::*[contains(@class,' topic/title ')]">-->
          <!--special EMC processing as described above-->
          <fo:block float="left">
            <xsl:attribute name="space-before">
              <xsl:choose>
                <xsl:when test="not(parent::*[contains(@class, ' task/info ')]) and not(preceding-sibling::*) and ancestor::*[contains(@class, ' topic/li ')]">8pt</xsl:when>
                <xsl:when test="(parent::*[contains(@class, ' task/info ')][preceding-sibling::*]) and not(preceding-sibling::*) and ancestor::*[contains(@class, ' topic/li ')]">3pt</xsl:when>
                <xsl:otherwise>0</xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="space-before.optimum">
              <xsl:choose>
                <xsl:when test="not(parent::*[contains(@class, ' task/info ')]) and not(preceding-sibling::*) and ancestor::*[contains(@class, ' topic/li ')]">8pt</xsl:when>
                <xsl:when test="(parent::*[contains(@class, ' task/info ')][preceding-sibling::*]) and not(preceding-sibling::*) and ancestor::*[contains(@class, ' topic/li ')]">3pt</xsl:when>
                <xsl:otherwise>0</xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
		  <!-- EMC 14-Aug-2013: added to align the dl, parml aliment -->
		  <xsl:attribute name="start-indent"><xsl:choose><xsl:when test="ancestor::*[contains(@class, ' topic/dl ') and not(contains(@class, ' pr-d/parml ')) and ancestor::*[contains(@class, ' task/choices ')]]">0.03</xsl:when><xsl:when test="ancestor::*[contains(@class, ' topic/dl ') and not(contains(@class, ' pr-d/parml '))]">0.14</xsl:when><xsl:when test="ancestor::*[contains(@class, ' pr-d/parml ')]">0.12</xsl:when><xsl:otherwise>0</xsl:otherwise></xsl:choose>in</xsl:attribute>
		  <!-- Balaji Mani 12-June-2013: omit footer break to aviod duplidate for multiple span -->
            <fo:table table-omit-footer-at-break="true">
              <fo:table-column column-width="{$side-col-1}"></fo:table-column>
              <fo:table-column column-width="{$side-col-2}"></fo:table-column>
              <!-- if table is inside list, indent more to align with text-->
              <!-- Suite/EMC   SOW7  19-Feb-2013   Prevent right margin overflow - update column width for substeps - rs -->
              <xsl:variable name="list-ancestor-count" select="count(ancestor::*[contains(@class,' topic/ol ') or contains(@class,' topic/ul ')])"/>
              <xsl:variable name="column-width">
                <xsl:choose>
                  <xsl:when test="$list-ancestor-count=0">0</xsl:when>
                  <xsl:when test="ancestor::*[contains(@class,' topic/ol ') or contains(@class,' topic/ul ')]
                                        [last()]
                                        [contains(@class, ' task/steps ') or contains(@class, ' task/steps-unordered ')]">
                    <xsl:value-of select="$list-item-indent + ($list-ancestor-count*$sublist-item-indent) - 0.035"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$list-item-indent - $list-indent + ($list-ancestor-count*$sublist-item-indent) "/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <fo:table-column>
                <xsl:attribute name="column-width">
                  <xsl:value-of select="$column-width"/>
                  <xsl:text>in</xsl:text>
                </xsl:attribute>
              </fo:table-column>
              <fo:table-column>
                <xsl:attribute name="column-width">
                  <!-- Suite/EMC   SOW7  19-Feb-2013   Prevent right margin overflow - set column width according to parent element - rs -->
                  <xsl:choose>
                    <xsl:when test="parent::*[contains(@outputclass,'landscape')] and parent::*/parent::*[contains(@class,' topic/body ')]">
                      <xsl:choose>
                        <xsl:when test="$parent='example'">
                          <xsl:value-of select="concat($main-col-landscape,'in',' - ',$side-col-1,' - ',$side-col-2)"/>
                        </xsl:when>
                        <xsl:when test="$parent='substep'"/>
                        <xsl:otherwise>
                          <xsl:value-of select="$main-col-landscape"/><xsl:text>in</xsl:text>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:choose>
                        <xsl:when test="$parent='example'">
                          <xsl:value-of select="concat($main-col,'in',' - ',$side-col-1,' - ',$side-col-2)"/>
                        </xsl:when>
                        <xsl:when test="$parent='substep'"/>
                        <xsl:otherwise>
                          <xsl:value-of select="$main-col"/><xsl:text>in</xsl:text>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:attribute>
              </fo:table-column>
              <xsl:if test="preceding-sibling::*[contains(@class,' topic/title ')]">
                <fo:table-header>
                  <fo:table-row>
                    <xsl:choose>
                      <xsl:when test="parent::*/parent::*[contains(@class, ' topic/example ')]">
                        <fo:table-cell id="{@id}" number-columns-spanned="4">
                          <xsl:apply-templates select="preceding-sibling::*[contains(@class,' topic/title ')]" mode="from-tgroup"/>
                        </fo:table-cell>
                      </xsl:when>
                      <xsl:otherwise>
                        <fo:table-cell>
                          <fo:block/>
                        </fo:table-cell>
                        <fo:table-cell>
                          <fo:block/>
                        </fo:table-cell>
                        <fo:table-cell>
                          <fo:block/>
                        </fo:table-cell>
                        <fo:table-cell id="{@id}">
                          <xsl:apply-templates select="preceding-sibling::*[contains(@class,' topic/title ')]" mode="from-tgroup"/>
                      <!-- Intelliarts Consulting   DellEMC Rebranding    10-Oct-2016   Remove '.' symbol from unsuitable place.  - IB-->
                        </fo:table-cell>
                      </xsl:otherwise>
                    </xsl:choose>
                  </fo:table-row>
                </fo:table-header>
              </xsl:if>
              <fo:table-body>
                <fo:table-row >
                  <!-- Suite Dec-2011: create table in a variable to insert either in last cell (default behavior)
                  or in one cell spanning all columns (for pagewide tables) -->
				  	  <!-- Balaji Mani PDF bundle 8-Feb-2013: Comment to disply 100% fixed width -->
                  <xsl:variable name="table">
                    <fo:table xsl:use-attribute-sets="table.tgroup" id="{@id}">
                      <xsl:call-template name="displayAtts">
                        <xsl:with-param name="element" select=".."/>
                      </xsl:call-template>
                      <xsl:apply-templates/>
                    </fo:table>
                  </xsl:variable>
                  <xsl:choose>
                    <!--Suite/EMC   SOW5  18-Mar-2012   remove margin from landsapce tables - ck-->
					<!-- EMC 26-July-2013 Fixed the indentation of table within the glossdef -->
                    <xsl:when test="(parent::*/@pgwide) = '1' or contains(parent::*/@outputclass,'pagewide') or contains(parent::*/@outputclass,'landscape') or ancestor::*[contains(@class, ' topic/example ') or contains(@class, ' topic/fig ') or contains(@class, ' glossentry/glossdef ')]">
                      <fo:table-cell number-columns-spanned="4">
                        <xsl:copy-of select="$table"/>
                      </fo:table-cell>
                    </xsl:when>
                    <xsl:otherwise>
                      <fo:table-cell >
                        <fo:block/>
                      </fo:table-cell>
                      <fo:table-cell>
                        <fo:block/>
                      </fo:table-cell>
                      <fo:table-cell>
                        <fo:block/>
                      </fo:table-cell>
                      <fo:table-cell>
                        <xsl:copy-of select="$table"/>
                      </fo:table-cell>
                    </xsl:otherwise>
                  </xsl:choose>
                </fo:table-row>
				<!-- Balaji Mani 12-June-2013: table-footer added -->
				<!-- EMC	9-May-2015		Fix for table footnote issue in production for PDF corruption -->
				<!-- EMC	Hotfix_3.2		23-Jun-2015		TKT 298: Fix for table footnote -->
                <!--Intelliarts Consulting 2017-04-11     Fixed: TKT-526 - (PDF) table continuation labels should appear only when table is continued. Removed empty row if footnotes don't exist   - IB -->
                <xsl:if test="descendant::*[contains(@class,' topic/fn ')]">
                  <fo:table-row>
                    <xsl:choose>
                      <xsl:when test="(parent::*/@pgwide) = '1' or contains(parent::*/@outputclass,'pagewide') or contains(parent::*/@outputclass,'landscape') or ancestor::*[contains(@class, ' topic/example ') or contains(@class, ' topic/fig ')]">
                        <fo:table-cell number-columns-spanned="4" xsl:use-attribute-sets="tablefootnote">
                          <fo:block>
                            <xsl:apply-templates select="descendant::*[contains(@class,' topic/fn ')]" mode="from-table" />
                          </fo:block>
                        </fo:table-cell>
                      </xsl:when>
                      <xsl:otherwise>
                        <fo:table-cell >
                          <fo:block/>
                        </fo:table-cell>
                        <fo:table-cell>
                          <fo:block/>
                        </fo:table-cell>
                        <fo:table-cell>
                          <fo:block/>
                        </fo:table-cell>
                        <fo:table-cell xsl:use-attribute-sets="tablefootnote">
                          <fo:block>
                            <xsl:apply-templates select="descendant::*[contains(@class,' topic/fn ')]" mode="from-table" />
                          </fo:block>
                        </fo:table-cell>
                      </xsl:otherwise>
                    </xsl:choose>
                  </fo:table-row>
                </xsl:if>
              </fo:table-body>
            </fo:table>
          </fo:block>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="not($scale = '')">
        <xsl:apply-templates select="$table" mode="setTableEntriesScale"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$table"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/thead ')]">
    <fo:table-header xsl:use-attribute-sets="tgroup.thead" id="{@id}">
      <xsl:apply-templates/>
    </fo:table-header>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/thead ')]/*[contains(@class, ' topic/row ')]">
    <fo:table-row xsl:use-attribute-sets="thead.row" id="{@id}" >
      <xsl:apply-templates/>
    </fo:table-row>
  </xsl:template>

  <!-- Suite Dec-2011: Modified template to concatenate identifier to id (and to use generate-id() if no id exists).
  This enables body rows to be easily located and counted in the area tree, in order to insert markers for continuation numbering. - rs -->
  <xsl:template match="*[contains(@class, ' topic/tbody ')]/*[contains(@class, ' topic/row ')]">
    <xsl:variable name="frame" as="xs:string">
      <xsl:variable name="f" select="ancestor::*[contains(@class, ' topic/table ')][1]/@frame"/>
      <xsl:choose>
        <xsl:when test="$f">
          <xsl:value-of select="$f"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$table.frame-default"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <fo:table-row xsl:use-attribute-sets="tbody.row">
      <xsl:variable name="id">
        <xsl:choose>
          <xsl:when test="@id"><xsl:value-of select="concat('bodyrow-',@id,'should_remain')"/></xsl:when>
          <xsl:otherwise><xsl:value-of select="concat('bodyrow-',generate-id(),'should_remain')"/></xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:attribute name="id"><xsl:value-of select="$id"/></xsl:attribute>
	  <!-- EMC IB6 21-Oct-2014 TKT-157:Table breaks within bottom row and bottom frame is cut off (PDF) -->
	  <xsl:if test="((position()+1) = last()) and not($frame = 'none')">
        <!-- IA   Tridion upgrade    Oct-2018   DO NOT add table bottom border if @frame = 'none'. - IB-->
        <xsl:attribute name="border-bottom">solid 1px black</xsl:attribute>
		<xsl:attribute name="border-after-width.conditionality">retain</xsl:attribute>
	  </xsl:if>
      <fo:marker marker-class-name="continued">
          <xsl:if test="preceding-sibling::*[contains(@class, ' topic/row ')]">
            <fo:inline>
              <!-- Suite/EMC   SOW7    31-Dec-2012   replace continuation notation - rs -->
              <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'Continued'"/>
              </xsl:call-template>
            </fo:inline>
          </xsl:if>
      </fo:marker>
      <xsl:apply-templates/>
    </fo:table-row>
  </xsl:template>

  <!--Modified template to include mode, and not to display caption with no. as this is processed in the tgroup template above - rs-->
  <xsl:template match="*[contains(@class,' topic/table ')]/*[contains(@class,' topic/title ')]" mode="from-tgroup">
    <fo:block xsl:use-attribute-sets="table.title" id="{@id}">
      <fo:inline>
        <!--Suite/EMC   SOW5  16-Mar-2012   label should be bold - ck-->
        <fo:inline font-weight="bold">
        <xsl:call-template name="getVariable">
          <xsl:with-param name="id" select="'Table Num'"/>
          <xsl:with-param name="params" as="element()*">
            <number>
              <xsl:number level="any" count="*[contains(@class, ' topic/table ')]/*[contains(@class, ' topic/title ')]" from="/"/>
            </number>
          </xsl:with-param>
        </xsl:call-template>
        </fo:inline>
        <xsl:apply-templates/>
        <fo:retrieve-table-marker retrieve-class-name="continued"/>
      </fo:inline>
    </fo:block>
  </xsl:template>

  <!--Modified template to empty as title is only processed in template with mode=from-tgroup - rs-->
  <xsl:template match="*[contains(@class,' topic/table ')]/*[contains(@class,' topic/title ')]" />

  <!--dl templates-->
  <!-- Balaji Mani PDF Bundle 8-Feb-2013: Removed the bullet symbol from DL -->
  <!-- Balaji Mani PDF Bundle 9-Feb-2013: Remove emdash and indent the para -->
  <!-- EMC 14-Aug-2013 converted the table to block -->
	<xsl:template match="*[contains(@class, ' topic/dl ')]">
        <fo:block xsl:use-attribute-sets="dl" id="{@id}">
            <xsl:apply-templates select="*[contains(@class, ' topic/dlhead ')]"/>
                 <xsl:choose>
                    <xsl:when test="contains(@otherprops,'sortable')">
                        <xsl:apply-templates select="*[contains(@class, ' topic/dlentry ')]">
                            <xsl:sort select="opentopic-func:getSortString(normalize-space( opentopic-func:fetchValueableText(*[contains(@class, ' topic/dt ')]) ))" lang="{$locale}"/>
                        </xsl:apply-templates>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="*[contains(@class, ' topic/dlentry ')]"/>
                    </xsl:otherwise>
                </xsl:choose>
        </fo:block>
    </xsl:template>

 <xsl:template match="*[contains(@class, ' topic/dlentry ')]">
      <fo:block xsl:use-attribute-sets="dlentry" >
           <fo:block xsl:use-attribute-sets="dlentry.dt" id="{@id}">
              <xsl:apply-templates select="*[contains(@class, ' topic/dt ')]"/>
              <xsl:apply-templates select="*[contains(@class, ' topic/dd ')]"/>
          </fo:block>
      </fo:block>
  </xsl:template>

 <!-- EMC	 IB8		18-Nov-2015		TKT-262: No pagebreak between <dt> and immediate following <dd> (regression bug) -->
  <xsl:template match="*[contains(@class, ' topic/dt ')]">
    <fo:block xsl:use-attribute-sets="dlentry.dt__content">
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

 <!-- Balaji Mani PDF Bundle 9-Feb-2013: dd as a block element -->
  <xsl:template match="*[contains(@class, ' topic/dd ')]">
    <fo:block xsl:use-attribute-sets="dlentry.dd__content">
	 <xsl:if test="name(following-sibling::*[1])='dd'"><xsl:attribute name="padding-bottom">7pt</xsl:attribute></xsl:if>
	 <!-- EMC	 IB8		18-Nov-2015		TKT-262: No pagebreak between <dt> and immediate following <dd> (regression bug) -->
	 <xsl:if test="name(preceding-sibling::*[1])='dt'">
		<xsl:attribute name="keep-with-previous.within-page">always</xsl:attribute>
	 </xsl:if>
      <xsl:apply-templates/>
    </fo:block>
  </xsl:template>

      <xsl:template match="*[contains(@class, ' topic/dl ')]/*[contains(@class, ' topic/dlhead ')]">
        <fo:block xsl:use-attribute-sets="dl.dlhead" id="{@id}">
            <fo:block xsl:use-attribute-sets="dl.dlhead__row">
                <xsl:apply-templates/>
            </fo:block>
        </fo:block>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/dlhead ')]/*[contains(@class, ' topic/dthd ')]">
            <fo:block xsl:use-attribute-sets="dlhead.dthd__content">
                <xsl:apply-templates/>
            </fo:block>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/dlhead ')]/*[contains(@class, ' topic/ddhd ')]">
            <fo:block xsl:use-attribute-sets="dlhead.ddhd__content">
                <xsl:apply-templates/>
            </fo:block>
    </xsl:template>


  <!-- Suite Dec-2011: test for landscape outputclass on tables. Only honor outputclass if table is top-level in topic - rs -->
  <xsl:template match="*[contains(@class, ' topic/table ')]">
    <xsl:choose>
      <xsl:when test="contains(@outputclass, 'landscape') and parent::*[contains(@class,' topic/body ')]">
        <psmi:page-sequence master-reference="body-landscape-sequence">
          <xsl:call-template name="insertBodyStaticContents"/>
          <fo:flow flow-name="xsl-region-body">
            <xsl:call-template name="tableSubTemplate"/>
          </fo:flow>
        </psmi:page-sequence>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="tableSubTemplate"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Suite Dec-2011: move table template to subtemplate - rs -->
  <xsl:template name="tableSubTemplate">
    <xsl:variable name="scale">
      <xsl:call-template name="getTableScale"/>
    </xsl:variable>
    <fo:block>
      <xsl:if test="@id != ''">
        <xsl:attribute name="id">
          <xsl:value-of select="concat(@id,'should_remain')"/>
        </xsl:attribute>
      </xsl:if>
      <fo:block xsl:use-attribute-sets="table">
        <xsl:call-template name="commonattributes"/>
        <xsl:if test="not($scale = '')">
          <xsl:attribute name="font-size">
            <xsl:value-of select="concat($scale, '%')"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:apply-templates/>
      </fo:block>
    </fo:block>
  </xsl:template>

  <!-- Suite Jan-2012: test for landscape outputclass on simpletable. Only honor outputclass if simpletable is top-level in topic - rs -->
  <xsl:template match="*[contains(@class, ' topic/simpletable ')]">
    <xsl:choose>
      <xsl:when test="contains(@outputclass, 'landscape') and parent::*[contains(@class,' topic/body ')]">
        <psmi:page-sequence master-reference="body-landscape-sequence">
          <xsl:call-template name="insertBodyStaticContents"/>
          <fo:flow flow-name="xsl-region-body">
            <xsl:call-template name="simpletableSubTemplate"/>
          </fo:flow>
        </psmi:page-sequence>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="simpletableSubTemplate"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Suite Jan-2012: move properties template to sub-template - rs -->
  <xsl:template name="propertiesSubTemplate">
    <fo:table xsl:use-attribute-sets="properties" id="{@id}">
      <xsl:call-template name="univAttrs"/>
      <xsl:call-template name="globalAtts"/>
      <xsl:call-template name="displayAtts">
        <xsl:with-param name="element" select="."/>
      </xsl:call-template>

      <xsl:if test="@relcolwidth">
        <xsl:variable name="fix-relcolwidth">
          <xsl:apply-templates select="." mode="fix-relcolwidth"/>
        </xsl:variable>
        <xsl:call-template name="createSimpleTableColumns">
          <xsl:with-param name="theColumnWidthes" select="$fix-relcolwidth"/>
        </xsl:call-template>
      </xsl:if>

      <xsl:if test="*[contains(@class, ' reference/prophead ')]">
        <xsl:apply-templates select="*[contains(@class, ' reference/prophead ')]"/>
      </xsl:if>

      <fo:table-body xsl:use-attribute-sets="properties__body">
        <xsl:apply-templates select="*[contains(@class, ' reference/property ')]"/>
      </fo:table-body>
    </fo:table>
	<!-- Balaji Mani 2-Aug-13 added property footnote -->
	<fo:table xsl:use-attribute-sets="propertiesFNtable">
	   <fo:table-body xsl:use-attribute-sets="properties__body">
		  <fo:table-row>
			 <fo:table-cell xsl:use-attribute-sets="tablefootnote">
				<fo:block>
				   <xsl:apply-templates select="descendant::*[contains(@class,' topic/fn ')]" mode="from-table" />
				</fo:block>
			 </fo:table-cell>
		  </fo:table-row>
	   </fo:table-body>
	</fo:table>
  </xsl:template>

  <!-- Suite Jan-2012: move simpletable template to sub-template - rs -->
  <xsl:template name="simpletableSubTemplate">
    <xsl:variable name="number-cells" as="xs:integer">
      <!-- Contains the number of cells in the widest row -->
      <xsl:apply-templates select="*[1]" mode="count-max-simpletable-cells"/>
    </xsl:variable>
    <fo:table xsl:use-attribute-sets="simpletable">
      <xsl:call-template name="commonattributes"/>
      <xsl:call-template name="globalAtts"/>
      <xsl:call-template name="displayAtts">
        <xsl:with-param name="element" select="."/>
      </xsl:call-template>

      <xsl:if test="@relcolwidth">
        <xsl:variable name="fix-relcolwidth" as="xs:string">
          <xsl:apply-templates select="." mode="fix-relcolwidth">
            <xsl:with-param name="number-cells" select="$number-cells"/>
          </xsl:apply-templates>
        </xsl:variable>
        <xsl:call-template name="createSimpleTableColumns">
          <xsl:with-param name="theColumnWidthes" select="$fix-relcolwidth"/>
        </xsl:call-template>
      </xsl:if>

      <!-- Toss processing to another template to process the simpletable
        heading, and/or create a default table heading row. -->
      <xsl:apply-templates select="." mode="dita2xslfo:simpletable-heading">
        <xsl:with-param name="number-cells" select="$number-cells"/>
      </xsl:apply-templates>
      <fo:table-body xsl:use-attribute-sets="simpletable__body">
        <xsl:apply-templates select="*[contains(@class, ' topic/strow ')]">
          <xsl:with-param name="number-cells" select="$number-cells"/>
        </xsl:apply-templates>
      </fo:table-body>

    </fo:table>
	<!-- Balaji Mani 2-Aug-13 added simple footnote -->
	<fo:table xsl:use-attribute-sets="simpletableFNtable">
	   <fo:table-body xsl:use-attribute-sets="simpletable__body">
		  <fo:table-row>
			 <fo:table-cell number-columns-spanned="{$number-cells}" xsl:use-attribute-sets="tablefootnote">
				<fo:block>
				   <xsl:apply-templates select="descendant::*[contains(@class,' topic/fn ')]" mode="from-table" />
				</fo:block>
			 </fo:table-cell>
		  </fo:table-row>
	   </fo:table-body>
	</fo:table>
  </xsl:template>

</xsl:stylesheet>