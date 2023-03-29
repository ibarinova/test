<?xml version="1.0" encoding="UTF-8"?><!--
This file is part of the DITA Open Toolkit project.

Copyright 2016 Jarno Elovirta

See the accompanying LICENSE file for applicable license.
--><xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

 <xsl:import href="plugin:org.dita.base:xsl/common/output-message.xsl"/>
 <xsl:import href="plugin:org.dita.base:xsl/common/dita-utilities.xsl"/>
 <xsl:import href="plugin:org.dita.base:xsl/common/related-links.xsl"/>
 <xsl:import href="plugin:org.dita.base:xsl/common/dita-textonly.xsl"/>
 <xsl:import href="topic.xsl"/>
 <xsl:import href="plugin:org.dita.post:xsl/concept.xsl"/>
 <xsl:import href="plugin:org.dita.post:xsl/task.xsl"/>
 <xsl:import href="plugin:org.dita.post:xsl/reference.xsl"/>  
 <xsl:import href="ut-d.xsl"/>
 <xsl:import href="sw-d.xsl"/>
 <xsl:import href="pr-d.xsl"/>
 <xsl:import href="ui-d.xsl"/>
 <xsl:import href="plugin:org.dita.post:xsl/hi-d.xsl"/>
 <xsl:import href="plugin:org.dita.post:xsl/abbrev-d.xsl"/>
 <xsl:import href="plugin:org.dita.post:xsl/markup-d.xsl"/>
 <xsl:import href="plugin:org.dita.post:xsl/xml-d.xsl"/>
 <xsl:import href="plugin:org.dita.post:xsl/nav.xsl"/>
 <xsl:import href="plugin:org.dita.post:xsl/htmlflag.xsl"/>
 <xsl:include href="rel-links.xsl"/>
 <xsl:include href="functions.xsl"/>

  <!-- root rule -->
  <xsl:template xmlns:dita="http://dita-ot.sourceforge.net" match="/">
    <xsl:apply-templates/>
  </xsl:template>
  
</xsl:stylesheet>