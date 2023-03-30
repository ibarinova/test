<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" version="2.0">
	<!-- ============================================================== -->
    <xsl:import href="infoshare.array.xsl"/>

    <xsl:param name="template" select="'infoshare.template.manual.xml'"/>
    <xsl:param name="DEFAULTLANG" select="'en'"/>
    <!-- ============================================================== -->
    <xsl:template name="add.style">
		<xsl:param name="style"/>
		<xsl:param name="language"/>
		
		<xsl:message>add.style <xsl:value-of select="$style"/> - <xsl:value-of select="$language"/></xsl:message>
		<xsl:variable name="style.count">
			<xsl:call-template name="array.count">
				<xsl:with-param name="array" select="$style"/>
				<xsl:with-param name="delimiter" select="' '"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:call-template name="add.style.items">
			<xsl:with-param name="delimiter" select="' '"/>
			<xsl:with-param name="style" select="$style"/>
			<xsl:with-param name="language" select="$language"/>
			<xsl:with-param name="style.count" select="$style.count"/>
			<xsl:with-param name="style.index" select="'1'"/>
		</xsl:call-template>
	</xsl:template>
	<!-- ============================================================== -->
	<xsl:template name="add.style.items">
		<xsl:param name="delimiter"/>
		<xsl:param name="style"/>
		<xsl:param name="language"/>
		<xsl:param name="style.count"/>
		<xsl:param name="style.index"/>
		<xsl:variable name="style.item">
			<xsl:call-template name="array.item">
				<xsl:with-param name="array" select="$style"/>
				<xsl:with-param name="delimiter" select="' '"/>
				<xsl:with-param name="index" select="'1'"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$style.count >= $style.index">
				<xsl:choose>
					<xsl:when test="$template != '#none#'">
						<!-- set font -->
						<xsl:choose>
							<!-- font defined in style has precedence over fonts defined in template -->
							<xsl:when test="document($template)/*/styles/style[@name=$style.item]/formatting[@name='font-family']">
								<xsl:attribute name="font-family">
									<xsl:value-of select="document($template)/*/styles/style[@name=$style.item]/formatting[@name='font-family']/."/>
								</xsl:attribute>
							</xsl:when>
							<!-- if no font is defined in style take font defined in template -->
							<xsl:otherwise>
								<xsl:attribute name="font-family">
									<xsl:call-template name="get.font">
										<xsl:with-param name="language" select="$language"/>
									</xsl:call-template>
								</xsl:attribute>
							</xsl:otherwise>
						</xsl:choose>
						<!-- set all other formatting -->
						<xsl:for-each select="document($template)/*/styles/style[@name=$style.item]/formatting">
							<xsl:if test="not(@name='font-family')">
								<xsl:attribute name="{@name}"><xsl:value-of select="."/></xsl:attribute>
							</xsl:if>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<!-- DO NOTHING -->
					</xsl:otherwise>
				</xsl:choose>
				<xsl:call-template name="add.style.items">
					<xsl:with-param name="delimiter" select="' '"/>
					<xsl:with-param name="style" select="substring-after($style,$delimiter)"/>
					<xsl:with-param name="style.count" select="$style.count"/>
					<!-- added number() function-->
					<xsl:with-param name="style.index" select="number($style.index) + 1"/>
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<!-- ============================================================== -->
	<xsl:template name="add.writing-mode">
	  <xsl:param name="language"/>
    	 <!--xsl:message>writing mode called with: <xsl:value-of select="$language"/></xsl:message-->
	  <xsl:attribute name="writing-mode">
		  <xsl:choose>
		  		  <!-- right to left / top to bottom -->
		  		  <xsl:when test="$language = 'ar'">rl-tb</xsl:when>
		  		  <xsl:when test="$language = 'ar-eg'">rl-tb</xsl:when>
		  		  <xsl:when test="$language = 'he'">rl-tb</xsl:when>
		  		  <xsl:when test="$language = 'he-il'">rl-tb</xsl:when>
		  		  <!-- top to bottom / right to left -->
		
			  		<!-- left to right / top to bottom -->
		        <xsl:otherwise>lr-tb</xsl:otherwise>
		      </xsl:choose>
	    </xsl:attribute>
	    <xsl:attribute name="xml:lang"><xsl:value-of select="$language"/></xsl:attribute>
	    <xsl:attribute name="language"><xsl:value-of select="$language"/></xsl:attribute>
 	</xsl:template>
	<!-- ============================================================== -->
	<xsl:template name="get.font">
		<xsl:param name="language"/>
		<xsl:choose>
			<xsl:when test="document($template)/*/fonts/font[@xml:lang=$language]">
				<!--xsl:message>get.font: language <xsl:value-of select="$language"/> - <xsl:value-of select="document($template)/*/fonts/font[@xml:lang=$language]/."/></xsl:message-->
				<xsl:value-of select="document($template)/*/fonts/font[@xml:lang=$language]/."/>
			</xsl:when>
			<xsl:when test="document($template)/*/fonts/font[@xml:lang=$DEFAULTLANG]">
				<!--xsl:message>get.font: default language <xsl:value-of select="$DEFAULTLANG"/> - <xsl:value-of select="document($template)/*/fonts/font[@xml:lang=$DEFAULTLANG]/."/></xsl:message-->
				<xsl:value-of select="document($template)/*/fonts/font[@xml:lang=$DEFAULTLANG]/."/>
			</xsl:when>
			<xsl:otherwise>Arial Unicode MS</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- ============================================================== -->
	<xsl:template name="get.page-setup.param">
		<xsl:param name="param"/>
		<xsl:choose>
			<xsl:when test="document($template)/*/page-setup/param[@name=$param]">
				<xsl:value-of select="document($template)/*/page-setup/param[@name=$param]/."/>
			</xsl:when>
			<xsl:otherwise>[param not found]</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- ============================================================== -->
	<xsl:template name="get.cover.background-image">
		<xsl:choose>
			<xsl:when test="document($template)/*/page-setup/cover">
				<xsl:attribute name="background-image">
					<xsl:value-of select="document($template)/*/page-setup/cover/@background-image"/>
				</xsl:attribute> 
			</xsl:when>
			<xsl:otherwise>[background-image not found]</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- ============================================================== -->
	<xsl:template name="get.footer.extent">
		<xsl:choose>
			<xsl:when test="document($template)/*/page-setup/footer">
				<xsl:attribute name="extent">
					<xsl:value-of select="document($template)/*/page-setup/footer/@extent"/>
				</xsl:attribute> 
			</xsl:when>
			<xsl:otherwise>[footer extent not found]</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- ============================================================== -->
	<xsl:template name="get.header.extent">
		<xsl:choose>
			<xsl:when test="document($template)/*/page-setup/header">
				<xsl:attribute name="extent">
					<xsl:value-of select="document($template)/*/page-setup/footer/@extent"/>
				</xsl:attribute> 
			</xsl:when>
			<xsl:otherwise>[header extent not found]</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- ============================================================== -->
	<xsl:template name="get.margins">
		<xsl:choose>
			<xsl:when test="document($template)/*/page-setup/margins">
				<xsl:attribute name="margin-bottom">
					<xsl:value-of select="document($template)/*/page-setup/margins/@margin-bottom"/>				
				</xsl:attribute> 
				<xsl:attribute name="margin-left">
					<xsl:value-of select="document($template)/*/page-setup/margins/@margin-left"/>
				</xsl:attribute> 
				<xsl:attribute name="margin-right">
					<xsl:value-of select="document($template)/*/page-setup/margins/@margin-right"/>
				</xsl:attribute> 
				<xsl:attribute name="margin-top">
					<xsl:value-of select="document($template)/*/page-setup/margins/@margin-top"/>
				</xsl:attribute> 
			</xsl:when>
			<xsl:otherwise>[pagemargins not found]</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- ============================================================== -->
	<xsl:template name="get.papersize">
		<xsl:variable name="orientation">
			<xsl:choose>
				<xsl:when test="document($template)/*/page-setup/orientation">
					<xsl:choose>
						<xsl:when test="document($template)/*/page-setup/orientation/@portrait = 'yes'">
							<xsl:value-of select="'portrait'"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="'landscape'"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="'portrait'"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="document($template)/*/page-setup/papersize">
				<xsl:choose>
					<xsl:when test="$orientation = 'portrait'">
						<xsl:attribute name="page-width">
							<xsl:value-of select="document($template)/*/page-setup/papersize/@page-width"/>
						</xsl:attribute> 
						<xsl:attribute name="page-height">
							<xsl:value-of select="document($template)/*/page-setup/papersize/@page-height"/>
						</xsl:attribute> 
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="page-width">
							<xsl:value-of select="document($template)/*/page-setup/papersize/@page-height"/>
						</xsl:attribute> 
						<xsl:attribute name="page-height">
							<xsl:value-of select="document($template)/*/page-setup/papersize/@page-width"/>
						</xsl:attribute> 
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>[papersize not found]</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- ============================================================== -->
	<xsl:template name="get.template">
        <xsl:text>infoshare.template.manual.xml</xsl:text>
	</xsl:template>
	<!-- ============================================================== -->
</xsl:stylesheet>
