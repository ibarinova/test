<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" version="2.0">
	<!-- ============================================================== -->
	<!-- work directory-->
	<xsl:param name="WORKDIR" select="$input.dir.url"/>
	<xsl:param name="jobTicket" select="concat($WORKDIR, '\', 'ishjobticket.xml')"/>
  <!-- ============================================================== -->
  <xsl:template name="getJobTicketParam">
  	<xsl:param name="varname" />
  	<xsl:param name="default" />
  	<xsl:choose>
			<xsl:when test="document($jobTicket,/)/job-specification/parameter[@name=$varname]">
				<xsl:value-of select="document($jobTicket,/)/job-specification/parameter[@name=$varname]"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$default"/>
			</xsl:otherwise>
		</xsl:choose>
  </xsl:template>  
  <!-- ============================================================== -->
  <xsl:template name="getJobTicketAttrib">
  	<xsl:param name="varname" />
  	<xsl:param name="default" />
  	<!--fo:block>JobTicket: <xsl:value-of select="$jobTicket"/></fo:block-->
  	<xsl:choose>
			<xsl:when test="document($jobTicket,/)/job-specification/@*[name()=$varname]">
				<xsl:value-of select="document($jobTicket,/)/job-specification/@*[name()=$varname]"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$default"/>
			</xsl:otherwise>
		</xsl:choose>
  </xsl:template>  
  <!-- ============================================================== -->
    <xsl:param name="multilingual">
        <xsl:call-template name="getJobTicketAttrib">
            <xsl:with-param name="varname">combinelanguages</xsl:with-param>
            <xsl:with-param name="default">no</xsl:with-param>
        </xsl:call-template>
    </xsl:param>
    <xsl:param name="compare-available">
        <xsl:call-template name="getJobTicketAttrib">
            <xsl:with-param name="varname">comparewitholderversion</xsl:with-param>
            <xsl:with-param name="default">no</xsl:with-param>
        </xsl:call-template>
    </xsl:param>
    </xsl:stylesheet>
