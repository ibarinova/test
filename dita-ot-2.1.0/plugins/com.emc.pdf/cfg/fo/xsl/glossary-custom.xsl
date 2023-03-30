<?xml version='1.0'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  xmlns:ot-placeholder="http://suite-sol.com/namespaces/ot-placeholder"
  xmlns:opentopic-index="http://www.idiominc.com/opentopic/index"
  xmlns:isoi18n="java:com.isogen.saxoni18n.Saxoni18nService"
  exclude-result-prefixes="isoi18n opentopic-index" extension-element-prefixes="ot-placeholder"
  version="2.0">

  <!-- 
    Revision History
    ================
    Suite/EMC   Nochap        08-Aug-2012   Remove glossory from nochap
    EMC         Glossary      18-Apr-2013   Glossary sorting and grouping per label
    EMC         PDFGlossary    9-Jul-2013   Added customization for the PDF Glossary
    EMC         PDFGlossary   12-Aug-2013   Bug fix for Glossary with empty tags
	EMC         PDFGlossary   09-Sep-2013   Bug fix for localized Glossary
	EMC         IB4           15-Apr-2014   #358 - glossary acronym included twice in glossary output
  -->

  <xsl:variable name="lang">
    <xsl:call-template name="getGlossLanguage">
      <xsl:with-param name="param-lang" select="lower-case((//*[@xml:lang])[1]/@xml:lang)"/>
    </xsl:call-template>
  </xsl:variable>

  <!-- Language Specific variables for sorting and grouping -->
  <xsl:variable name="alphabets">ABCDEFGHIJKLMNOPQRSTUVWXYZ0!# </xsl:variable>
  <xsl:variable name="ko-alphabets">ABCDEFGHIJKLMNOPQRSTUVWXYZ# </xsl:variable>
  <xsl:variable name="cs-alphabets">ABCDEFGHIJKLMNOPQRSTUVWXYZ0!#ÁCDÉEÍNÓRŠTÚUÝŽ </xsl:variable>
  <xsl:variable name="es-mx-alphabets">ABCDEFGHIJKLMNOPQRSTUVWXYZ0!#Ñ </xsl:variable>
  <xsl:variable name="zh-cn-alphabets">ABCDEFGHIJKLMNOPQRSTUVWXYZ0!#</xsl:variable>

  <!-- Language Specific Collation URL -->
  <xsl:variable name="collationUrl">
    <xsl:choose>
      <xsl:when test="$lang = 'ko'"
        >http://saxon.sf.net/collation?lang=ko;strength=tertiary;</xsl:when>
      <xsl:when test="$lang = 'de'"
        >http://saxon.sf.net/collation?lang=de;strength=tertiary;</xsl:when>
      <xsl:when test="$lang = 'fr'"
        >http://saxon.sf.net/collation?lang=fr;strength=tertiary;</xsl:when>
      <xsl:when test="$lang = 'it'"
        >http://saxon.sf.net/collation?lang=it;strength=tertiary;</xsl:when>
      <xsl:when test="$lang = 'cs'"
        >http://saxon.sf.net/collation?lang=cs;strength=tertiary;</xsl:when>
      <xsl:when test="$lang = 'ja'"
        >http://saxon.sf.net/collation?lang=ja;strength=tertiary;</xsl:when>
      <xsl:when test="$lang = 'ru'"
        >http://saxon.sf.net/collation?lang=ru;strength=tertiary;</xsl:when>
      <xsl:when test="$lang = 'es-mx'"
        >http://saxon.sf.net/collation?lang=es-mx;strength=tertiary;</xsl:when>
      <xsl:when test="$lang = 'pt-br'"
        >http://saxon.sf.net/collation?lang=pt-br;strength=tertiary;</xsl:when>
      <xsl:when test="$lang = 'zh-cn'"
        >http://saxon.sf.net/collation?class=com.emc.SimplifiedChineseComparator</xsl:when>
      <xsl:when test="$lang = 'zh-tw'"
        >http://saxon.sf.net/collation?lang=zh-tw;strength=tertiary;</xsl:when>
      <xsl:otherwise>http://saxon.sf.net/collation?lang=en-us;strength=tertiary;</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>


  <!-- EMC   14-Jun-2013 IndexGroupKey is retrieved from i18n-support.jar. 
                         The sorting will be done on either one of the gloss-sort-as or glossBody/glossSurfaceForm or *[contains(@class,' glossentry/glossterm ')], 
                         depending on which term is present -->
  <xsl:key name="key-gloss" match="*[contains(@class, 'glossentry/glossentry')]"
    use="
      isoi18n:getIndexGroupKey($lang,
      isoi18n:glossarySortString(normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]),
      normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]),
      normalize-space(*[contains(@class, ' glossentry/glossterm ')])))"/>

  <xsl:template match="ot-placeholder:glossarylist" name="createGlossary">
    <xsl:if test="$NOCHAP = 'no'">
      <fo:page-sequence master-reference="glossary-sequence" xsl:use-attribute-sets="__force__page__count">
        <xsl:call-template name="insertGlossaryStaticContents"/>
        <fo:flow flow-name="xsl-region-body">
          <fo:marker marker-class-name="current-header">
            <xsl:call-template name="getVariable">
              <xsl:with-param name="id" select="'Glossary'"/>
            </xsl:call-template>
          </fo:marker>
          <fo:block xsl:use-attribute-sets="__glossary__label" id="{$id.glossary}">
            <xsl:call-template name="getVariable">
              <xsl:with-param name="id" select="'Glossary'"/>
            </xsl:call-template>
			</fo:block>
          <xsl:if test="*[1][not(contains(@class, 'glossentry/glossentry'))]">
            <xsl:apply-templates
              select="*[1][not(contains(@class, 'glossentry/glossentry'))]/*[contains(@class, 'topic/body')]"
            />
          </xsl:if>
		  
          <fo:table>
            <fo:table-column>
              <xsl:attribute name="column-width">
                <!-- EMC    PDFGlossary    13-Aug-2013  Align the content of the first paragraph   -->
                <xsl:value-of select="'1.7in'"/>
              </xsl:attribute>
            </fo:table-column>
            <fo:table-column>
              <xsl:attribute name="column-width">
                <xsl:value-of select="$side-col-2"/>
              </xsl:attribute>
            </fo:table-column>
            <fo:table-column>
              <xsl:attribute name="column-width">
                <xsl:value-of select="$main-col"/>
                <xsl:text>in</xsl:text>
              </xsl:attribute>
            </fo:table-column>
            
            <fo:table-body>
			  <!-- For Korean lang(unlike Other lang), localized should be sorted first -->
              <xsl:choose>
                <xsl:when test="$lang = 'ko'">
                  <xsl:call-template name="l10n-sort">
                    <xsl:with-param name="param-alpha">
                      <xsl:value-of select="$ko-alphabets"/>
                    </xsl:with-param>
                  </xsl:call-template>
                  <xsl:call-template name="en-sort">
                    <xsl:with-param name="param-alpha">
                      <xsl:value-of select="$ko-alphabets"/>
                    </xsl:with-param>
                  </xsl:call-template>
                </xsl:when>
                <!-- For ALL OTHER languages -->
                <xsl:otherwise>
                  <!-- Special sorting of special characters and numbers for Simplified Chinese ONLY  -->
                  <xsl:choose>
                    <xsl:when test="$lang = 'zh-cn'">
                      <xsl:call-template name="l10n_special_number_sort">
                        <xsl:with-param name="param-alpha">
                          <xsl:value-of select="$zh-cn-alphabets"/>
                        </xsl:with-param>
                      </xsl:call-template>
                    </xsl:when>
                  </xsl:choose>
                  <!-- Special Sorting ends here-->
                  
                  <xsl:call-template name="en-sort">
                    <xsl:with-param name="param-alpha">
                      <xsl:choose>
                        <xsl:when test="$lang = 'cs'">
                          <xsl:value-of select="$cs-alphabets"/>
                        </xsl:when>
                        <xsl:when test="$lang = 'es-mx'">
                          <xsl:value-of select="$es-mx-alphabets"/>
                        </xsl:when>
                        <xsl:when test="$lang = 'zh-cn'">
                          <xsl:value-of select="$zh-cn-alphabets"/>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:value-of select="$alphabets"/>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:with-param>
                  </xsl:call-template>
                  <xsl:choose>
                    <xsl:when test="$lang = 'zh-tw'">
                      <xsl:call-template name="l10n-zh_tw-sort">
                        <xsl:with-param name="param-alpha">
                          <xsl:value-of select="$alphabets"/>
                        </xsl:with-param>
                      </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:call-template name="l10n-sort">
                        <xsl:with-param name="param-alpha">
                          <xsl:choose>
                            <xsl:when test="$lang = 'cs'">
                              <xsl:value-of select="$cs-alphabets"/>
                            </xsl:when>
                            <xsl:when test="$lang = 'es-mx'">
                              <xsl:value-of select="$es-mx-alphabets"/>
                            </xsl:when>
                            <xsl:otherwise>
                              <xsl:value-of select="$alphabets"/>
                            </xsl:otherwise>
                          </xsl:choose>
                        </xsl:with-param>
                      </xsl:call-template>
                    </xsl:otherwise>
                  </xsl:choose> 
                </xsl:otherwise>
              </xsl:choose>
            </fo:table-body>
          </fo:table>
        </fo:flow>
      </fo:page-sequence>
    </xsl:if>
  </xsl:template>

  <!--  EMC  PDFGlossary  14-Jun-2013  Avoid displaying the nested glossentry -->
  <xsl:template
    match="*[contains(@class, ' glossentry/glossentry ')][ancestor::*[contains(@class, ' glossentry/glossentry ')]]"
    priority="10">
    <xsl:message>ERROR: nested gloss "<xsl:value-of
        select="normalize-space(*[contains(@class, ' glossentry/glossterm ')])"/>" entry will not be
      processed</xsl:message>
  </xsl:template>

  <xsl:template match="ot-placeholder:glossarylist//*[contains(@class, ' glossentry/glossentry ')]">
    <fo:table-row>
      <fo:table-cell>
        <fo:block id="{@id}">
          <fo:block xsl:use-attribute-sets="__glossary__entry">
            <xsl:attribute name="id">
              <xsl:value-of select="concat('_OPENTOPIC_TOC_PROCESSING_', generate-id())"/>
            </xsl:attribute>
            <fo:block xsl:use-attribute-sets="__glossary__term">
			 <xsl:apply-templates select="*[contains(@class, ' glossentry/glossterm ')]/node()"/>
              <xsl:variable name="glossAbbr"
                select="descendant::*[contains(@class, ' glossentry/glossAbbreviation ')]/node()"/>
              <xsl:if test="normalize-space($glossAbbr) != ''">
                <xsl:text> (</xsl:text>
                <xsl:value-of select="$glossAbbr"/>
                <xsl:text>)</xsl:text>
              </xsl:if>
            </fo:block>
          </fo:block>
        </fo:block>
      </fo:table-cell>
      <fo:table-cell>
        <fo:block/>
      </fo:table-cell>
      <fo:table-cell>
        <fo:block xsl:use-attribute-sets="__glossary__def">
          <xsl:apply-templates select="*[contains(@class, ' glossentry/glossdef ')]/node()"/>
        </fo:block>
      </fo:table-cell>
    </fo:table-row>
  </xsl:template>

  <xsl:template name="glossary-label-group">
    <xsl:param name="param-position"/>
    <xsl:param name="param-glossterm"/>
    <!-- Display the Glossary Label only for the first entry of the key group -->
    <xsl:if test="$param-position = 1">
      <fo:table-row>
        <fo:table-cell>
          <fo:block>&#160;</fo:block>
        </fo:table-cell>
      </fo:table-row>
      <fo:table-row xsl:use-attribute-sets="__glossary__letter-block">
        <fo:table-cell/>
        <fo:table-cell xsl:use-attribute-sets="__glossary__letter-group">
          <fo:block xsl:use-attribute-sets="__index__letter-group">
            <xsl:variable name="groupLabel"
              select="isoi18n:getIndexGroupLabel($lang, isoi18n:getIndexGroupKey($lang, $param-glossterm))[1]"/>
            <xsl:choose>
              <xsl:when
                test="translate($groupLabel, '#ABCDEFGHIJKLMNOPQRSTUVWXYZ', '#abcdefghijklmnopqrstuvwxyz') = '#numeric'">
                <xsl:value-of select="'Special Terms'"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$groupLabel"/>
              </xsl:otherwise>
            </xsl:choose>
          </fo:block>
        </fo:table-cell>
      </fo:table-row>
    </xsl:if>

    <fo:table-row id="{@id}">
      <xsl:apply-templates/>
    </fo:table-row>
  </xsl:template>

  <!-- Sorting based on the group sort key for english language -->
  <xsl:template name="en-sort">
    <xsl:param name="param-alpha"/>

    <xsl:for-each
      select="//*[contains(@class, ' glossentry/glossentry ') and generate-id(.) = generate-id(key('key-gloss', isoi18n:getIndexGroupKey($lang, isoi18n:glossarySortString(normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]), normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]), normalize-space(*[contains(@class, ' glossentry/glossterm ')]))))[1])]">
      <xsl:sort
        select="
          isoi18n:getIndexGroupKey(
          $lang,
          isoi18n:glossarySortString(normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]),
          normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]),
          normalize-space(*[contains(@class, ' glossentry/glossterm ')])))"
        collation="{$collationUrl}"/>
      <xsl:for-each
        select="key('key-gloss', isoi18n:getIndexGroupKey($lang, isoi18n:glossarySortString(normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]), normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]), normalize-space(*[contains(@class, ' glossentry/glossterm ')]))))">

        <xsl:sort
          select="
            isoi18n:glossarySortString(
            normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]),
            normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]),
            normalize-space(*[contains(@class, ' glossentry/glossterm ')]))"
          collation="{$collationUrl}"/>

        <xsl:variable name="eng-letter-label">
          <xsl:value-of
            select="translate(isoi18n:getIndexGroupKey($lang, isoi18n:glossarySortString(normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]), normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]), normalize-space(*[contains(@class, ' glossentry/glossterm ')]))), $param-alpha, '')"
          />
        </xsl:variable>
        <xsl:if test="$eng-letter-label = ''">
          <xsl:call-template name="glossary-label-group">
            <xsl:with-param name="param-position" select="position()"/>
            <xsl:with-param name="param-glossterm"
              select="isoi18n:glossarySortString(normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]), normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]), normalize-space(*[contains(@class, ' glossentry/glossterm ')]))"
            />
          </xsl:call-template>
        </xsl:if>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <!-- Sorting based on the group Label for localized language -->
  <xsl:template name="l10n-sort">
    <xsl:param name="param-alpha"/>

    <xsl:for-each
      select="//*[contains(@class, ' glossentry/glossentry ') and generate-id(.) = generate-id(key('key-gloss', isoi18n:getIndexGroupKey($lang, isoi18n:glossarySortString(normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]), normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]), normalize-space(*[contains(@class, ' glossentry/glossterm ')]))))[1])]">
      <xsl:sort
        select="
          isoi18n:getIndexGroupLabel($lang,
          isoi18n:getIndexGroupKey($lang,
          isoi18n:glossarySortString(normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]),
          normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]),
          normalize-space(*[contains(@class, ' glossentry/glossterm ')]))))"
        collation="{$collationUrl}"/>

      <xsl:for-each
        select="key('key-gloss', isoi18n:getIndexGroupKey($lang, isoi18n:glossarySortString(normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]), normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]), normalize-space(*[contains(@class, ' glossentry/glossterm ')]))))">

        <xsl:sort
          select="
            isoi18n:glossarySortString(
            normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]),
            normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]),
            normalize-space(*[contains(@class, ' glossentry/glossterm ')]))"
          collation="{$collationUrl}"/>

        <xsl:variable name="eng-letter-label">
          <xsl:value-of
            select="translate(isoi18n:getIndexGroupKey($lang, isoi18n:glossarySortString(normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]), normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]), normalize-space(*[contains(@class, ' glossentry/glossterm ')]))), $param-alpha, '')"
          />
        </xsl:variable>
        <xsl:if test="$eng-letter-label != ''">
          <xsl:call-template name="glossary-label-group">
            <xsl:with-param name="param-position" select="position()"/>
            <xsl:with-param name="param-glossterm"
              select="isoi18n:glossarySortString(normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]), normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]), normalize-space(*[contains(@class, ' glossentry/glossterm ')]))"
            />
          </xsl:call-template>
        </xsl:if>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <!-- Sorting based on the group Sort Key for Traditional Chinese language -->
  <xsl:template name="l10n-zh_tw-sort">
    <xsl:param name="param-alpha"/>

    <xsl:for-each
      select="//*[contains(@class, ' glossentry/glossentry ') and generate-id(.) = generate-id(key('key-gloss', isoi18n:getIndexGroupKey($lang, isoi18n:glossarySortString(normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]), normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]), normalize-space(*[contains(@class, ' glossentry/glossterm ')]))))[1])]">
      <xsl:sort
        select="
          isoi18n:getIndexGroupKey($lang,
          isoi18n:glossarySortString(normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]),
          normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]),
          normalize-space(*[contains(@class, ' glossentry/glossterm ')])))"
        collation="{$collationUrl}"/>

      <xsl:for-each
        select="key('key-gloss', isoi18n:getIndexGroupKey($lang, isoi18n:glossarySortString(normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]), normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]), normalize-space(*[contains(@class, ' glossentry/glossterm ')]))))">

        <xsl:sort
          select="
            isoi18n:glossarySortString(
            normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]),
            normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]),
            normalize-space(*[contains(@class, ' glossentry/glossterm ')]))"
          collation="{$collationUrl}"/>
        <xsl:variable name="eng-letter-label">
          <xsl:value-of
            select="translate(isoi18n:getIndexGroupKey($lang, isoi18n:glossarySortString(normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]), normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]), normalize-space(*[contains(@class, ' glossentry/glossterm ')]))), $param-alpha, '')"
          />
        </xsl:variable>
        <xsl:if test="$eng-letter-label != ''">
          <xsl:call-template name="glossary-label-group">
            <xsl:with-param name="param-position" select="position()"/>
            <xsl:with-param name="param-glossterm"
              select="isoi18n:glossarySortString(normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]), normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]), normalize-space(*[contains(@class, ' glossentry/glossterm ')]))"
            />
          </xsl:call-template>
        </xsl:if>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <!-- For Simplified Chinese, the numbers should be sorted first and then the special characters. Hence, adding space infront of numbers -->
  <xsl:template name="l10n_special_number_sort">
    <xsl:param name="param-alpha"/>

    <xsl:for-each
      select="//*[contains(@class, ' glossentry/glossentry ') and generate-id(.) = generate-id(key('key-gloss', isoi18n:getIndexGroupKey($lang, isoi18n:glossarySortString(normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]), normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]), normalize-space(*[contains(@class, ' glossentry/glossterm ')]))))[1])]">
      <xsl:sort
        select="
          isoi18n:getIndexGroupKey($lang,
          isoi18n:glossarySortString(
          normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]),
          normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]),
          normalize-space(*[contains(@class, ' glossentry/glossterm ')])))"
        collation="{$collationUrl}"/>

      <xsl:if
        test="' ' = isoi18n:getIndexGroupKey($lang, isoi18n:glossarySortString(normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]), normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]), normalize-space(*[contains(@class, ' glossentry/glossterm ')])))">
        <xsl:for-each
          select="key('key-gloss', isoi18n:getIndexGroupKey($lang, isoi18n:glossarySortString(normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]), normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]), normalize-space(*[contains(@class, ' glossentry/glossterm ')]))))">
          <xsl:sort
            select="
              isoi18n:formatGlossaryString(
              isoi18n:glossarySortString(
              normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]),
              normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]),
              normalize-space(*[contains(@class, ' glossentry/glossterm ')])))"/>

          <xsl:call-template name="glossary-label-group">
            <xsl:with-param name="param-position" select="position()"/>
            <xsl:with-param name="param-glossterm"
              select="isoi18n:glossarySortString(normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]), normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]), normalize-space(*[contains(@class, ' glossentry/glossterm ')]))"
            />
          </xsl:call-template>

        </xsl:for-each>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- Template for getting the language for Glossary config file -->
  <xsl:template name="getGlossLanguage">
    <xsl:param name="param-lang"/>
    <xsl:variable name="glossLang">
      <xsl:value-of select="translate($param-lang, '_', '-')"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when
        test="starts-with($glossLang, 'zh') or starts-with($glossLang, 'en') or starts-with($glossLang, 'es') or starts-with($glossLang, 'pt')">
        <xsl:value-of select="$glossLang"/>
      </xsl:when>
      <xsl:when test="contains($glossLang, '-')">
        <xsl:value-of select="substring-before($glossLang, '-')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$glossLang"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- EMC      PDFGlossary    9-Jul-2013   Moved the glossary specific templates from common-customs.xsl  -->
  <xsl:template match="*[contains(@class, ' glossentry/glossterm ')]">
    <xsl:variable name="glossAbbr"
      select="following-sibling::*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossAlt ')]/*[contains(@class, ' glossentry/glossAcronym ')]"/>
	

    <fo:table-cell xsl:use-attribute-sets="__glossary__glossterm">
      <fo:block xsl:use-attribute-sets="__glossary__bold">
	  
        <!-- EMC  PDFGlossary    13-Aug-2013  Display the page number for the indexterm within prolog -->
        <xsl:apply-templates
          select="../*[contains(@class, ' topic/prolog ')]//opentopic-index:index.entry[not(parent::opentopic-index:index.entry)]"/>
        <xsl:choose>
          <xsl:when
            test="normalize-space(following-sibling::*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]) != ''">
            <xsl:value-of
              select="following-sibling::*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]"
            />
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates/>
          </xsl:otherwise>
        </xsl:choose>
        <!-- EMC  IB4  15-Apr-2014  #358 - glossary acronym included twice in glossary output -->
        <!--
        <xsl:if test="normalize-space($glossAbbr) != ''"><xsl:text> (</xsl:text>
          <xsl:value-of select="$glossAbbr"/>
          <xsl:text>)</xsl:text>
        </xsl:if>
        -->
      </fo:block>
    </fo:table-cell>
  </xsl:template>
  <xsl:template match="*[contains(@class, ' glossentry/glossdef ')]">
    <fo:table-cell xsl:use-attribute-sets="__glossary__letter-group">
<!-- IDPL-2700 added by Roopesh. Add topic metadata to PDF -->
	<fo:block>
	  <xsl:if test="lower-case($INCLUDEMETADATA) = 'yes'">
				<fo:block font-size="10pt">
				<xsl:call-template name="pubmeta"/>
				</fo:block>
	</xsl:if>
        <xsl:apply-templates/>
        <xsl:for-each
          select="following-sibling::*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossAlt ')]/*[contains(@class, ' glossentry/glossSynonym ')]">
          <xsl:if test="normalize-space(.) != ''">
            <fo:block>&#160;</fo:block>
            <fo:block>
              <fo:inline xsl:use-attribute-sets="__glossary__bold">
                <xsl:call-template name="getVariable">
                  <xsl:with-param name="id" select="'Glossary See Also String'"/>
                </xsl:call-template>
              </fo:inline>
              <xsl:value-of select="."/>
            </fo:block>
          </xsl:if>
        </xsl:for-each>
      </fo:block>
    </fo:table-cell>
  </xsl:template>

  <xsl:template
    match="*[contains(@class, ' topic/xref ')][@type = 'glossentry'][ancestor::*[contains(@class, ' glossentry/glossdef ')]]">
    <xsl:variable name="refid">
      <xsl:choose>
        <xsl:when test="contains(@href, '#')">
          <xsl:value-of select="substring-after(@href, '#')"/>
        </xsl:when>
        <xsl:when test="contains(@href, '/')">
          <xsl:value-of select="substring-after(@href, '/')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@href"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- EMC    14-Aug-2013   Removed the quotes from the xref link. Change the 'See' to bold, non link -->
    <xsl:choose>
      <xsl:when test="$lang = 'ko' or $lang = 'ja'"><!-- Do nothing --></xsl:when>
      <xsl:otherwise>
        <fo:inline xsl:use-attribute-sets="__glossary__bold">
          <xsl:call-template name="getVariable">
            <xsl:with-param name="id" select="'Glossary See String'"/>
          </xsl:call-template>
        </fo:inline>
      </xsl:otherwise>
    </xsl:choose>

    <fo:basic-link xsl:use-attribute-sets="__glossary__link">
      <xsl:attribute name="internal-destination" select="$refid"/>
      <fo:inline>
        <xsl:choose>
          <xsl:when
            test="normalize-space(//*[@id = $refid]/*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]) != ''">
            <xsl:value-of
              select="//*[@id = $refid]/*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]"
            />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="//*[@id = $refid]/*[contains(@class, ' glossentry/glossterm ')]"/>
          </xsl:otherwise>
        </xsl:choose>
      </fo:inline>
    </fo:basic-link>

    <xsl:choose>
      <xsl:when test="$lang = 'ko' or $lang = 'ja'">
        <fo:inline xsl:use-attribute-sets="__glossary__bold">
          <xsl:call-template name="getVariable">
            <xsl:with-param name="id" select="'Glossary See String'"/>
          </xsl:call-template>
        </fo:inline>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- For Simplified Chinese, check if the first char is number. If yes, append space -->
  <xsl:function name="isoi18n:formatGlossaryString">
    <xsl:param name="glossaryText"/>

    <xsl:variable name="firstchar">
      <xsl:value-of select="substring($glossaryText, 1, 1)"/>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="contains('0123456789', $firstchar)">
        <xsl:value-of select="concat(' ', $glossaryText)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$glossaryText"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- The precedence for sort string is gloss-sort-as, glossSurfaceForm, glossTerm (in that order, whichever comes first)-->
  <xsl:function name="isoi18n:glossarySortString">
    <xsl:param name="glossSortAs"/>
    <xsl:param name="glossSrfFrm"/>
    <xsl:param name="glossTerm"/>

    <xsl:choose>
      <xsl:when test="$glossSortAs != ''">
        <xsl:value-of select="$glossSortAs"/>
      </xsl:when>
      <xsl:when test="$glossSrfFrm != ''">
        <xsl:value-of select="$glossSrfFrm"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$glossTerm"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:stylesheet>
