<?xml version='1.0'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:_sfe="http://www.arbortext.com/namespace/Styler/StylerFormattingElements" xmlns:exslt="http://exslt.org/common" xmlns:msxsl="urn:schemas-microsoft-com:xslt" version="1.1" exclude-result-prefixes="_sfe exslt msxsl">

<!--<xsl:template match="codeph" >
    <fo:block xsl:use-attribute-sets="codeph">
   	  <xsl:call-template name="maybe-set-id"/>
	  <xsl:if test="count(preceding-sibling::codeph) &gt; 0">
		  <fo:block>
			<xsl:call-template name="getVariable">
				<xsl:with-param name="id" select="'emc_codeph_newline'"/>
			</xsl:call-template>          
		  </fo:block>
	  </xsl:if>
	  <xsl:apply-templates/>
	</fo:block>
</xsl:template>-->
		
<xsl:template match="*[self::synph][parent::codeph]">
	<xsl:choose>
		<xsl:when test="count(preceding-sibling::synph) = 0">
			<fo:inline xsl:use-attribute-sets="synph">
 	   		  <xsl:call-template name="maybe-set-id"/>
			  <xsl:apply-templates/> 
			</fo:inline>
		</xsl:when>
		<xsl:when test="count(preceding-sibling::synph) mod 2 = 1">
			<fo:block xsl:use-attribute-sets="synph">
			  <xsl:if test="not(ancestor::emc_taskbody)">
				  <xsl:attribute name="padding-left">10pt</xsl:attribute>
			  </xsl:if>
			  <xsl:apply-templates/> 
			</fo:block>
		</xsl:when>
		<xsl:when test="(count(preceding-sibling::synph) mod 2 = 0) and not(count(preceding-sibling::synph) = 0) ">
			<fo:block xsl:use-attribute-sets="synph">
		      <xsl:if test="not(ancestor::emc_taskbody)">
				  <xsl:attribute name="padding-left">10pt</xsl:attribute>
			  </xsl:if>
			  <xsl:apply-templates/>
			</fo:block> 			
		</xsl:when>
	</xsl:choose>
</xsl:template>

<xsl:template match="cli_body" priority="9">
	<fo:block xsl:use-attribute-sets="body">
  <xsl:for-each select="cli_prereq">
	<fo:block>
		<fo:block xsl:use-attribute-sets="topic.topic.topic.topic.title" margin-left="0">
			<xsl:call-template name="maybe-set-id"/>
			  <xsl:call-template name="getVariable">
			  <xsl:with-param name="id" select="'emc_cli_prereq_title'"/>
			  </xsl:call-template>
    </fo:block>
    <fo:block xsl:use-attribute-sets="cli_common">
         <xsl:apply-templates/>
    </fo:block>
   </fo:block>
  </xsl:for-each>
  <xsl:for-each select="cli_description">
	<fo:block>
		    <fo:block xsl:use-attribute-sets="topic.topic.topic.topic.title" margin-left="0">
				  <xsl:call-template name="maybe-set-id"/>
					  <xsl:call-template name="getVariable">
						 <xsl:with-param name="id" select="'emc_cli_description_title'"/>
					  </xsl:call-template>
		    </fo:block>
			<fo:block xsl:use-attribute-sets="cli_common">
				<xsl:apply-templates/>
			</fo:block>
		</fo:block>
  </xsl:for-each>
  <xsl:for-each select="cli_syntax">
	<fo:block>
		    <fo:block xsl:use-attribute-sets="topic.topic.topic.topic.title" margin-left="0">
				  <xsl:call-template name="maybe-set-id"/>
					  <xsl:call-template name="getVariable">
						 <xsl:with-param name="id" select="'emc_cli_syntax_title'"/>
					  </xsl:call-template>          
		    </fo:block>
			<fo:block xsl:use-attribute-sets="cli_common">
				<xsl:apply-templates/>
			</fo:block>
		</fo:block>
  </xsl:for-each>
  <xsl:for-each select="cli_options">
	<fo:block>
		    <fo:block xsl:use-attribute-sets="topic.topic.topic.topic.title" margin-left="0">
				  <xsl:call-template name="maybe-set-id"/>
					  <xsl:call-template name="getVariable">
						 <xsl:with-param name="id" select="'emc_cli_options_title'"/>
					  </xsl:call-template>          
            </fo:block>
		    <fo:block xsl:use-attribute-sets="cli_common">
				<xsl:apply-templates/>
			</fo:block>
		</fo:block>
  </xsl:for-each>
  <xsl:for-each select="cli_params">
  	<fo:block>
  		<fo:block xsl:use-attribute-sets="topic.topic.topic.topic.title" margin-left="0">
  			<xsl:call-template name="maybe-set-id"/>
  			<xsl:call-template name="getVariable">
  				<xsl:with-param name="id" select="'emc_cli_params_title'"/>
  			</xsl:call-template>          
  		</fo:block>
  		<fo:block xsl:use-attribute-sets="cli_common">
  			<xsl:apply-templates/>
  		</fo:block>
  	</fo:block>
  </xsl:for-each>
  <xsl:for-each select="cli_args">
  	<fo:block>
  		<fo:block xsl:use-attribute-sets="topic.topic.topic.topic.title" margin-left="0">
  			<xsl:call-template name="maybe-set-id"/>
  			<xsl:call-template name="getVariable">
  				<xsl:with-param name="id" select="'emc_cli_args_title'"/>
  			</xsl:call-template>          
  		</fo:block>
  		<fo:block xsl:use-attribute-sets="cli_common">
  			<xsl:apply-templates/>
  		</fo:block>
  	</fo:block>
  </xsl:for-each>

   <xsl:for-each select="cli_example">
       <fo:block float="left" start-indent="0in">
		  <fo:table width="{$page-width-without-margins}">
			<fo:table-column column-width="{$side-col-1}"/>
			<fo:table-column column-width="{$side-col-2}"/>

			<!-- if example is inside list, indent more to align with text-->
			<xsl:variable name="list-ancestor-count"
			  select="count(ancestor::*[contains(@class,' topic/ol ') or contains(@class,' topic/ul ')])"/>
			<xsl:variable name="column-width">
			  <xsl:choose>
				<xsl:when test="$list-ancestor-count=0">0</xsl:when>
				<xsl:when test="$list-ancestor-count=1">
				  <xsl:value-of select="$list-item-indent"/>
				</xsl:when>
				<xsl:otherwise>
				  <xsl:value-of
					select="$list-item-indent + ($list-ancestor-count*$sublist-item-indent) "/>
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
				<xsl:value-of select="$main-col"/>
				<xsl:text>in</xsl:text>
			  </xsl:attribute>
			</fo:table-column>

			<xsl:if test="*[contains(@class,' topic/title ')]">
			  <fo:table-header>
				<fo:table-row>

				  <!--Suite/EMC   SOW5  16-Feb-2012   fix example title spacing -->
				  <fo:table-cell/>
				  <fo:table-cell/>
				  <fo:table-cell/>
				  <fo:table-cell xsl:use-attribute-sets="cli_example.title" margin-left="0">
					<fo:block id="{@id}">
					  <fo:block>
						<xsl:if test="@id != ''">
						  <xsl:attribute name="id">
							<xsl:value-of select="concat(@id,'should_remain')"/>
						  </xsl:attribute>
						</xsl:if>
						<!--Suite/EMC   SOW5  19-Feb-2012   label should be bold - ck-->
						<fo:inline font-weight="bold">
						  <xsl:call-template name="getVariable">
							<xsl:with-param name="id" select="'Example'"/>
							<xsl:with-param name="theParameters">
							  <number>
								<xsl:number level="any"
								  count="*[contains(@class, ' topic/example ')][child::*[contains(@class, ' topic/title ')]]"
								  from="/"/>
							  </number>
							</xsl:with-param>
						  </xsl:call-template>
						</fo:inline>
						<xsl:text>&#xA0;</xsl:text>
						<xsl:apply-templates select="*[contains(@class,' topic/title ')]"/>
						<fo:retrieve-table-marker retrieve-class-name="continued"/>
					  </fo:block>
					</fo:block>
				  </fo:table-cell>
				</fo:table-row>
			  </fo:table-header>
			</xsl:if>

			<fo:table-body>

			  <fo:table-row>
				<fo:table-cell>
				  <fo:block/>
				</fo:table-cell>
				<fo:table-cell>
				  <fo:block/>
				</fo:table-cell>
				<fo:table-cell>
				  <fo:block/>
				</fo:table-cell>
				<fo:table-cell>

				  <fo:block xsl:use-attribute-sets="example">
					<fo:table>
					  <fo:table-body>
						<!-- Suite/EMC   SOW7    19-Feb-2013   Prevent right margin overflow - rs -->
						<!-- EMC  28-Oct-2013  IB3  Issue 291: Text within <example> does not appear in PDF  -->					
						<xsl:apply-templates select="*[not(contains(@class,' topic/title '))] | text()" mode="from-fig-or-example">
						  <!-- send tunnel parameter parent=example so that child fig/table elements can deduct margins/width accordingly - rs -->
						  <xsl:with-param name="parent" tunnel="yes">example</xsl:with-param>
						</xsl:apply-templates>
					  </fo:table-body>
					</fo:table>
				  </fo:block>
				</fo:table-cell>

			  </fo:table-row>
			</fo:table-body>
		  </fo:table>
		</fo:block>			  
  </xsl:for-each>

  <xsl:for-each select="cli_backend_output">
  	<fo:block>
  		<fo:block xsl:use-attribute-sets="topic.topic.topic.topic.title" margin-left="0">
  			<xsl:call-template name="maybe-set-id"/>
  			<xsl:call-template name="getVariable">
  				<xsl:with-param name="id" select="'emc_cli_backend_output_title'"/>
  			</xsl:call-template>          
  		</fo:block>
  		<fo:block xsl:use-attribute-sets="cli_common">
  			<xsl:apply-templates/>
  		</fo:block>
  	</fo:block>
  </xsl:for-each>
  <xsl:for-each select="cli_postreq">
  	<fo:block>
  		<fo:block xsl:use-attribute-sets="topic.topic.topic.topic.title" margin-left="0">
  			<xsl:call-template name="maybe-set-id"/>
  			<xsl:call-template name="getVariable">
  				<xsl:with-param name="id" select="'emc_cli_postreq_title'"/>
  			</xsl:call-template>          
  		</fo:block>
  		<fo:block xsl:use-attribute-sets="cli_common">
  			<xsl:apply-templates/>
  		</fo:block>
  	</fo:block>
  </xsl:for-each>  
	</fo:block>
</xsl:template>

<xsl:template match="cli_option|cli_arg|cli_param">
    <fo:block>
			
			<fo:block role="cli_option">
				
			  <xsl:call-template name="maybe-set-id"/>
			  <xsl:for-each select="cli_option_desc | cli_arg_desc | cli_param_desc">
				  <xsl:if test="(count(child::*) &lt; 4)">
					<xsl:attribute name="keep-together.within-page">always</xsl:attribute>
				  </xsl:if>				
			  </xsl:for-each>
			  <xsl:apply-templates/>
			</fo:block>
	 </fo:block>
  </xsl:template>

<xsl:template match="cli_option_value|cli_arg_value|cli_param_value" >

	<fo:block xsl:use-attribute-sets="cli_value">
			  <xsl:call-template name="maybe-set-id"/>
			  <xsl:apply-templates/>
	</fo:block>
	
</xsl:template>
  
<xsl:template match="cli_option_desc|cli_arg_desc|cli_param_desc" >
			
	<fo:block xsl:use-attribute-sets="cli_desc">
		<xsl:call-template name="maybe-set-id"/>
		<xsl:apply-templates/>
	</fo:block>
  </xsl:template>
      
<xsl:template match="*[self::synph][not(parent::codeph)]" >
    <fo:block xsl:use-attribute-sets="synph">
    	<xsl:if test="not(ancestor::emc_taskbody)">
    		<xsl:attribute name="padding-left">10pt</xsl:attribute>
    	</xsl:if>
      <xsl:call-template name="maybe-set-id"/>
	  <xsl:apply-templates/> 
    </fo:block>
</xsl:template>

<xsl:template name="maybe-set-id">
    <xsl:param name="attrname" select="'id'"/>
    <xsl:param name="only-if-id-attr" select="'yes'"/>
    <xsl:param name="generated-id-prefix" select="'x'"/>
    <xsl:param name="context-node" select="."/>
    <xsl:if test="not(ancestor::_sfe:HeaderOrFooter)">
      <xsl:choose>
        <xsl:when test="$context-node/@id">
          <xsl:attribute name="{$attrname}">
            <xsl:value-of select="$context-node/@id"/>
          </xsl:attribute>
        </xsl:when>
        <xsl:when test="$only-if-id-attr!='yes'">
          <xsl:attribute name="{$attrname}">
            <xsl:value-of select="$generated-id-prefix"/>
            <xsl:apply-templates select="$context-node" mode="set-id"/>
          </xsl:attribute>
        </xsl:when>
      </xsl:choose>
    </xsl:if>
  </xsl:template>
  
</xsl:stylesheet>

