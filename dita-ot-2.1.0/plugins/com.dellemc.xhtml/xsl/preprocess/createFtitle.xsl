<?xml version='1.0'?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:param name="ARGS.INPUT.DIR"/>
    <xsl:param name="INPUTDIR"/>
    <xsl:param name="OUTPUTDIR"/>

    <xsl:variable name="ARGS.INPUT.DIR-path" select="concat('file:///', translate($ARGS.INPUT.DIR, '\', '/'), '/')"/>
    <xsl:variable name="INPUTDIR-path" select="concat('file:///', translate($INPUTDIR, '\', '/'), '/')"/>
    <xsl:variable name="OUTPUTDIR-path" select="concat('file:///', translate($OUTPUTDIR, '\', '/'), '/')"/>

    <xsl:variable name="base-name" select="tokenize(base-uri(),'/')[last()]"/>

    <xsl:template match="/">
    <!-- EMC    17-Nov-2014   Fix for Xerces validation error -->
    <xsl:choose>
      <xsl:when test="name((//*)[1]) = 'topic'">
        <xsl:text disable-output-escaping="yes">
				&lt;!DOCTYPE topic PUBLIC "-//OASIS//DTD DITA Topic//EN" "topic.dtd"&gt;
				</xsl:text>
      </xsl:when>
      <xsl:when test="name((//*)[1]) = 'concept'">
        <xsl:text disable-output-escaping="yes">
				&lt;!DOCTYPE concept PUBLIC "-//OASIS//DTD DITA Concept//EN" "concept.dtd"&gt;
				</xsl:text>
      </xsl:when>
      <xsl:when test="name((//*)[1]) = 'task'">
        <xsl:text disable-output-escaping="yes">
				&lt;!DOCTYPE task PUBLIC "-//OASIS//DTD DITA Task//EN" "task.dtd"&gt;
				</xsl:text>
      </xsl:when>
      <xsl:when test="name((//*)[1]) = 'reference'">
        <xsl:text disable-output-escaping="yes">
				&lt;!DOCTYPE reference PUBLIC "-//OASIS//DTD DITA Reference//EN" "reference.dtd"&gt;
				</xsl:text>
      </xsl:when>
      <xsl:when test="name((//*)[1]) = 'map'">
        <xsl:text disable-output-escaping="yes">
				&lt;!DOCTYPE map PUBLIC "-//OASIS//DTD DITA Map//EN" "map.dtd"&gt;
				</xsl:text>
      </xsl:when>
      <xsl:when test="name((//*)[1]) = 'bookmap'">
        <xsl:text disable-output-escaping="yes">
				&lt;!DOCTYPE bookmap PUBLIC "-//OASIS//DTD DITA BookMap//EN" "bookmap.dtd"&gt;
				</xsl:text>
      </xsl:when>
      <xsl:when test="name((//*)[1]) = 'glossentry'">
        <xsl:text disable-output-escaping="yes">
				&lt;!DOCTYPE glossentry PUBLIC "-//EMC//DTD DITA Glossary//EN" "emcglossary.dtd"&gt;
				</xsl:text>
      </xsl:when>
      <xsl:when test="name((//*)[1]) = 'cli_reference'">
        <xsl:text disable-output-escaping="yes">
				&lt;!DOCTYPE cli_reference PUBLIC "-//EMC//DTD DITA CliReference//EN" "cli.dtd"&gt;
				</xsl:text>
      </xsl:when>
      <xsl:when test="name((//*)[1]) = 'glossentry'">
        <xsl:text disable-output-escaping="yes">
                &lt;!DOCTYPE glossentry PUBLIC "-//EMC//DTD DITA Glossary//EN" "emcglossary.dtd"&gt;
				</xsl:text>
      </xsl:when>
    </xsl:choose>

    <xsl:copy-of select="."/>

    <xsl:variable name="topicId">
        <xsl:value-of select="/child::*/@id"/>
<!--
      <xsl:choose>
        <xsl:when test="/concept">
          <xsl:value-of select="/concept/@id"/>
        </xsl:when>
        <xsl:when test="/task">
          <xsl:value-of select="/task/@id"/>
        </xsl:when>
        <xsl:when test="/reference">
          <xsl:value-of select="/reference/@id"/>
        </xsl:when>
        <xsl:when test="/topic">
          <xsl:value-of select="/topic/@id"/>
        </xsl:when>
        <xsl:when test="/cli_reference">
          <xsl:value-of select="/cli_reference/@id"/>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
-->
    </xsl:variable>

    <xsl:variable name="metfile-name">
        <xsl:value-of select="concat(substring-before($base-name,'.xml'), '.met')"/>
    </xsl:variable>

    <xsl:variable name="metfile3">
          <xsl:value-of select="concat($ARGS.INPUT.DIR-path, $metfile-name)"/>
    </xsl:variable>
    <xsl:variable name="ftitle">
      <xsl:choose>
            <xsl:when test="doc-available($metfile3) and (normalize-space(document($metfile3)/descendant::*[@name='FTITLE'][1]))">
              <xsl:value-of select="document($metfile3)/descendant::*[@name='FTITLE'][1]"/>
        </xsl:when>
          <xsl:when test="normalize-space($topicId)">
              <xsl:value-of select="$topicId"/>
          </xsl:when>
          <xsl:otherwise>
              <xsl:value-of select="substring-before($base-name, '.')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

      <xsl:variable name="new-filename" select="concat(translate($ftitle, '&amp;?@#$%*() ', ''), '.xml')"/>
      <xsl:variable name="new-filepath" select="concat($OUTPUTDIR-path, $new-filename)"/>

<!--
    <xsl:message>______________________________________________________</xsl:message>
    <xsl:message>$ARGS.INPUT.DIR-path = '<xsl:value-of select="$ARGS.INPUT.DIR-path"/>'</xsl:message>
    <xsl:message>$metfile3 = '<xsl:value-of select="$metfile3"/>'</xsl:message>
    <xsl:message>$metfile-name = '<xsl:value-of select="$metfile-name"/>'</xsl:message>
    <xsl:message>doc-available($metfile3) = '<xsl:value-of select="doc-available($metfile3)"/>'</xsl:message>
    <xsl:message>______________________________________________________</xsl:message>
    <xsl:message>Stripped Ftitle <xsl:value-of select="$new-filename"/></xsl:message>
    <xsl:message>New file Path <xsl:value-of select="$new-filepath"/></xsl:message>
-->

    <!-- Rename file in folder -->
    <xsl:variable name="metfileOrigGrab">
      <xsl:value-of select="concat($INPUTDIR-path, $base-name)"/>
    </xsl:variable>

    <xsl:message>Start Choose</xsl:message>
    <xsl:message>$metfileOrigGrab =====<xsl:value-of select="$metfileOrigGrab"/></xsl:message>

    <!-- Test if file exists -->
    <xsl:choose>
      <xsl:when test="doc-available($new-filepath)">
        <xsl:message>Topic already exists - <xsl:value-of select="$new-filepath"/></xsl:message>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="document($metfileOrigGrab)/task">
            <xsl:message>Task - <xsl:value-of select="$new-filepath"/></xsl:message>
            <xsl:result-document
              href="{$new-filepath}"
              method="xml" doctype-public="-//OASIS//DTD DITA General Task//EN"
              doctype-system="generalTask.dtd">
              <xsl:copy-of select="document($metfileOrigGrab)"/>
            </xsl:result-document>
            <xsl:message>Task Created </xsl:message>
          </xsl:when>

          <xsl:when test="document($metfileOrigGrab)/concept">
            <xsl:message>Concept - <xsl:value-of select="$new-filepath"/></xsl:message>
            <xsl:result-document
              href="{$new-filepath}"
              method="xml" doctype-public="-//OASIS//DTD DITA Concept//EN"
              doctype-system="concept.dtd">
              <xsl:copy-of select="document($metfileOrigGrab)"/>
            </xsl:result-document>
            <xsl:message>Concept Created </xsl:message>
          </xsl:when>

          <xsl:when test="document($metfileOrigGrab)/reference">
            <xsl:message>Reference - <xsl:value-of select="$new-filepath"/></xsl:message>
            <xsl:result-document
              href="{$new-filepath}"
              method="xml" doctype-public="-//OASIS//DTD DITA Reference//EN"
              doctype-system="reference.dtd">
              <xsl:copy-of select="document($metfileOrigGrab)"/>
            </xsl:result-document>
            <xsl:message>Reference Created </xsl:message>
          </xsl:when>

          <xsl:when test="document($metfileOrigGrab)/cli_reference">
            <xsl:message>cli_reference - <xsl:value-of select="$new-filepath"/></xsl:message>
            <xsl:result-document
              href="{$new-filepath}"
              method="xml" doctype-public="-//EMC//DTD DITA CliReference//EN"
              doctype-system="cli.dtd">
              <xsl:copy-of select="document($metfileOrigGrab)"/>
            </xsl:result-document>
            <xsl:message>CLI Reference Created </xsl:message>
          </xsl:when>

          <xsl:when test="document($metfileOrigGrab)/topic">
            <xsl:message>Topic - <xsl:value-of select="$new-filepath"/></xsl:message>
            <xsl:result-document
              href="{$new-filepath}"
              method="xml" doctype-public="-//OASIS//DTD DITA Topic//EN" doctype-system="topic.dtd">
              <xsl:copy-of select="document($metfileOrigGrab)"/>
            </xsl:result-document>
            <xsl:message>Topic Created </xsl:message>
          </xsl:when>

            <xsl:when test="document($metfileOrigGrab)/glossentry">
            <xsl:message>Glossentry - <xsl:value-of select="$new-filepath"/></xsl:message>
            <xsl:result-document
              href="{$new-filepath}"
              method="xml" doctype-public="-//EMC//DTD DITA Glossary//EN" doctype-system="emcglossary.dtd">
              <xsl:copy-of select="document($metfileOrigGrab)"/>
            </xsl:result-document>
            <xsl:message>Topic Created </xsl:message>
          </xsl:when>
          <xsl:otherwise/>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

    <xsl:template match="@*[name() = 'ishlabelxpath']"/>
    <xsl:template match="@*[name() = 'ishlinkxpath']"/>
    <xsl:template match="@*[name() = 'domains']"/>
    <xsl:template match="@*[name() = 'class']"/>
    <xsl:template match="@*[name() = 'ishtype']"/>

</xsl:stylesheet>
