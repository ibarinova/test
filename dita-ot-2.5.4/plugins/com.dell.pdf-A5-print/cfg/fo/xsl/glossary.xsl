<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:ot-placeholder="http://suite-sol.com/namespaces/ot-placeholder"
                exclude-result-prefixes="ot-placeholder"
                version="2.0">

  <xsl:template match="ot-placeholder:glossarylist//*[contains(@class, ' glossentry/glossentry ')]">
    <fo:block xsl:use-attribute-sets="__glossary__block">
      <!--<xsl:call-template name="commonattributes"/>-->
      <fo:block>
        <xsl:attribute name="id">
          <xsl:call-template name="generate-toc-id"/>
        </xsl:attribute>
        <fo:block xsl:use-attribute-sets="__glossary__term">
          <xsl:apply-templates select="*[contains(@class, ' glossentry/glossterm ')]/node()"/>
        </fo:block>
        <fo:block xsl:use-attribute-sets="__glossary__def">
          <xsl:apply-templates select="*[contains(@class, ' glossentry/glossdef ')]/node()"/>
        </fo:block>
      </fo:block>
    </fo:block>
  </xsl:template>

</xsl:stylesheet>
