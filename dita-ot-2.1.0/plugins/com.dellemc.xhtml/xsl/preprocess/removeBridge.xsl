<?xml version='1.0'?>
<xsl:stylesheet version="2.0"
                xmlns:ditaarch="http://dita.oasis-open.org/architecture/2005/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all">
  
  <xsl:param name="ditaroot"/>
  <xsl:param name="OUTPUTDIR"/>
  <xsl:param name="INPUTDIR"/>

  <xsl:variable name="INPUTDIR-path" select="concat('file:///', translate($INPUTDIR, '\', '/'), '/')"/>
  <xsl:variable name="OUTPUTDIR-path" select="concat('file:///', translate($OUTPUTDIR, '\', '/'), '/')"/>
  <xsl:variable name="base-name" select="tokenize(base-uri(),'/')[last()]"/>
  <xsl:variable name="new-filepath" select="concat($OUTPUTDIR-path, 'hold/', $base-name)"/>

  <xsl:variable name="conrefs">
    <xsl:apply-templates select="/descendant::*[@conref]/@conref" mode="conrefs"/>
    <xsl:apply-templates select="/descendant::*[contains(@class, ' map/topicref ')][not(ancestor::*[contains(@class, ' map/reltable ')])]" mode="conrefs"/>
  </xsl:variable>

  <xsl:template match="@*|node()">
      <xsl:copy>
        <xsl:apply-templates select="@*|node()"/>
      </xsl:copy>
  </xsl:template>
  
  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="/descendant::*[contains(@class, 'bookmap')]">
        <xsl:message>In bookmap <xsl:value-of select="base-uri()"/></xsl:message>
        <xsl:text disable-output-escaping="yes">
				&lt;!DOCTYPE bookmap PUBLIC "-//OASIS//DTD DITA BookMap//EN" "bookmap.dtd"&gt;
				</xsl:text> </xsl:when>
      <xsl:otherwise>
        <xsl:message>In directory <xsl:value-of select="base-uri()"/></xsl:message>
        <xsl:message>result doc filepath <xsl:value-of select="$new-filepath"/></xsl:message>
        <xsl:text disable-output-escaping="yes">
				&lt;!DOCTYPE map PUBLIC "-//OASIS//DTD DITA Map//EN" "map.dtd"&gt;
				</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:copy>
      <xsl:apply-templates/>
    </xsl:copy>
    <xsl:if test="/descendant::*[contains(@class, 'bookmap')]">
      <xsl:result-document href="{$INPUTDIR-path}dummy.txt" method="text">
        Add dummy file in order do not copy all files if conref list is empty
      </xsl:result-document>
      <xsl:result-document href="{$INPUTDIR-path}conreffiles.txt" method="text">
        <xsl:text>dummy.txt</xsl:text>
        <xsl:value-of select="'&#10;'"/>
        <xsl:for-each select="$conrefs/conref">
          <xsl:variable name="current_value" select="normalize-space(@name)"/>
          <xsl:if test="not(preceding-sibling::conref[normalize-space(@name) = $current_value])">
            <xsl:value-of select="@name"/>
            <xsl:value-of select="'&#10;'"/>
          </xsl:if>
        </xsl:for-each>
      </xsl:result-document>
    </xsl:if>
  </xsl:template>

  <xsl:template match="@*[name() = 'href']">
    <xsl:variable name="current-href" select="normalize-space(.)"/>
    <xsl:choose>
      <xsl:when test="contains($current-href,'.ditamap')">
          <xsl:message>Processing Content <xsl:value-of select="."/></xsl:message>
          <xsl:attribute name="href">
              <xsl:value-of select="."/>
          </xsl:attribute>
      </xsl:when>
      <xsl:when test="normalize-space(substring-before($current-href,'.xml'))">
        <xsl:variable name="metfile-name">
          <xsl:value-of select="concat(substring-before($current-href,'.xml'), '.met')"/>
        </xsl:variable>
        <xsl:variable name="metfileOrig">
          <xsl:value-of select="concat(substring-before($current-href,'.xml'), '.xml')"/>
        </xsl:variable>
        <xsl:variable name="metfile3">
          <xsl:value-of select="concat($INPUTDIR-path, $metfile-name)"/>
        </xsl:variable>
        <!-- EMC	15-Oct-2014		if ftitle is not available, then use GUID	-->
        <xsl:variable name="ftitle">
          <xsl:choose>
            <xsl:when test="doc-available($metfile3) and (normalize-space(document($metfile3)/descendant::*[@name='FTITLE']))">
              <xsl:value-of select="document($metfile3)/descendant::*[@name='FTITLE'][1]"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="substring-before($metfileOrig, '.xml')"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:variable name="new-filename" select="translate($ftitle, '&amp;Δ@#$%*() ', '')"/>

        <xsl:message>Stripped Ftitle <xsl:value-of select="$new-filename"/></xsl:message>

        <xsl:attribute name="href">
          <xsl:value-of select="concat($new-filename, '.xml')"/>
        </xsl:attribute>

      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*[@conref]/@conref" mode="conrefs">
    <xsl:variable name="href" select="."/>
    <xsl:variable name="href-value">
      <xsl:choose>
        <xsl:when test="contains($href, '#')">
          <xsl:value-of select="substring-before($href, '#')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$href"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="href-filename">
      <xsl:choose>
        <xsl:when test="contains($href-value, '.xml') or contains($href-value, '.dita')">
          <xsl:value-of select="$href-value"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat($href-value, '.xml')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <conref name="{$href-filename}"/>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' map/topicref ')][not(ancestor::*[contains(@class, ' map/reltable ')])][@href]" mode="conrefs">
    <xsl:variable name="href" select="@href"/>
    <xsl:variable name="href-value">
      <xsl:choose>
        <xsl:when test="contains($href, '#')">
          <xsl:value-of select="substring-before($href, '#')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$href"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="href-filename">
      <xsl:choose>
        <xsl:when test="contains($href-value, '.xml') or contains($href-value, '.dita') or contains($href-value, '.ditamap')">
          <xsl:value-of select="$href-value"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat($href-value, '.xml')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="ref-doc-uri" select="concat($INPUTDIR-path, $href-filename)"/>
    <xsl:variable name="ref-doc" select="document($ref-doc-uri)"/>

    <xsl:if test="doc-available($ref-doc-uri) and $ref-doc/descendant::*[@conref]">
      <xsl:apply-templates select="$ref-doc/descendant::*[@conref]/@conref" mode="conrefs"/>
    </xsl:if>
    <xsl:if test="doc-available($ref-doc-uri) and $ref-doc/descendant::*[contains(@class, ' map/topicref ')][@href][not(ancestor::*[contains(@class, ' map/reltable ')])]">
      <xsl:apply-templates select="$ref-doc/descendant::*[contains(@class, ' map/topicref ')][@href][not(ancestor::*[contains(@class, ' map/reltable ')])]" mode="conrefs"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' map/reltable ')]" mode="conrefs"/>

  <xsl:template match="@*[name() = 'ishlabelxpath']"/>
  <xsl:template match="@*[name() = 'ishlinkxpath']"/>
  <xsl:template match="@*[name() = 'domains']"/>
  <xsl:template match="@*[name() = 'class']"/>
  <xsl:template match="@*[name() = 'ishtype']"/>
</xsl:stylesheet>