<?xml version='1.0'?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:param name="OUTPUTDIR"/>
  <xsl:param name="DELIMETER"/>
  <xsl:param name="INPUTDIR"/>

  <xsl:variable name="INPUTDIR-path" select="concat('file:///', translate($INPUTDIR, '\', '/'), '/')"/>
  <xsl:template match="*|@*|comment()|processing-instruction()|node()|text()">
    <xsl:copy>
      <xsl:apply-templates select="*|@*|comment()|processing-instruction()|node()|text()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="xref/@href | link/@href">
    <xsl:message>Processing xref/@href <xsl:value-of select="."/></xsl:message>
    <xsl:variable name="getHref">
      <xsl:value-of select="."/>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="(contains($getHref, '.xml')) and not(starts-with(getHref, 'HTTP'))">
        <xsl:variable name="metfile-name">
          <xsl:choose>
            <xsl:when test="not(substring-before(.,'.xml')='')">
              <xsl:value-of select="concat(substring-before(.,'.xml'), '.met')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="concat(., '.met')"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="metfileOrig">
          <xsl:value-of select="concat(substring-before(.,'.xml'), '.xml')"/>
        </xsl:variable>
        <xsl:variable name="metfile3">
          <xsl:value-of select="concat($INPUTDIR-path, $metfile-name)"/>
        </xsl:variable>
        <xsl:variable name="ftitle">
          <xsl:choose>
            <xsl:when test="doc-available($metfile3) and (not(normalize-space(document($metfile3,.)//ishfields/ishfield[@name='FTITLE'])=''))">
              <xsl:value-of select="document($metfile3,.)//ishfields/ishfield[@name='FTITLE']"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="substring-before($metfileOrig, '.xml')"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:message>Stripped Ftitle <xsl:value-of select="translate($ftitle,'&amp;?@#$%*() ','')"/></xsl:message>

        <xsl:variable name="newhref">
          <xsl:value-of select="concat($ftitle, '.xml')"/>
          <xsl:if test="contains($getHref, '#')">
            <xsl:value-of select="concat('#', substring-after($getHref, '#'))"/>
          </xsl:if>
        </xsl:variable>
        
        <xsl:message>Updating href to new value - <xsl:value-of select="$newhref"/></xsl:message>
        <xsl:attribute name="href">
          <xsl:value-of select="$newhref"/>
        </xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="href">
          <xsl:value-of select="."/>
        </xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="@*[name() = 'ishlabelxpath']"/>
  <xsl:template match="@*[name() = 'ishlinkxpath']"/>
  <xsl:template match="@*[name() = 'domains']"/>
  <xsl:template match="@*[name() = 'class']"/>
  <xsl:template match="@*[name() = 'ishtype']"/>

</xsl:stylesheet>
