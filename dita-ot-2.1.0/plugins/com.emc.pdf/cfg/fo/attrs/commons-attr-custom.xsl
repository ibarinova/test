<?xml version='1.0'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:rx="http://www.renderx.com/XSL/Extensions"
  version="2.0">

  <!--
    Revision History
    ================
    Suite/EMC   SOW5    10-Feb-2012   Added pagewide functionality for images
    Suite/EMC   SOW5    15-Feb-2012   notes' font and spacing changes
    Suite/EMC   SOW5    15-Feb-2012   font changes
    Suite/EMC   SOW5    19-Feb-2012   Increase space after shortdesc
    Suite/EMC   SOW6    14-Mar-2012   Italic alternatives for jp
    Suite/EMC   SOW5    18-Mar-2012   font changes
    Suite/EMC   RSA     19-Jul-2012   Customizable copyright page
    Suite/EMC   SOW7    18-Dec-2012   heading indentation and font changes
    Suite/EMC   SOW7    10-Mar-2013   format pagewide figures within examples
    Suite/EMC   SOW7    20-03-2913    add xml:lang to identify language in i18n post-processing
    Natasha     IB2     25-06-2013    Note font-size in Table changed
    EMC			    IB3		  25-Oct-2013	  #333: Formatting keyword, #355: <lines> renders in a smaller font within table, #322:<image> spacing in task substeps
	Chaya		IB3		28-10-2013    Increased space above, below and line height for first-level headings (topic.topic.title)
	Chaya		IB3		31-10-2013    Increased space above, below and line height for section headings (section.title)
	EMC 		IB3		14-Nov-2013	  Issue 350: Topic title and content should appear on the same page
	EMC			IB3		16-Nov-2013	  Chapters should start on odd pages only. Changed force-page-count from 'even' to 'end-on-even'.
	EMC			IB4		14-Apr-2014	  Formatting for cite element
    EMC     	IB4   	15-Apr-2014   #403 - Text bleeds margin in <example> with <fig>
    EMC     	IB4   	15-Apr-2014   #405 - Too little space before example in task topics
    EMC     	IB4   	14-May-2014   #406 - Too little space between block-level elements in task examples
	EMC	  Hotfix_3.2    23-Jun-2015	  TKT 298: Right align footnote and table fn label
	EMC		HotFix3.2	17-Jul-2015	  #298 Shifted the baseline shift to 5%
	EMC			IB8		11-Nov-2015	  TKT-165: For Chinese and Japanese "term" font style should be normal
  -->
  <xsl:attribute-set name="base-font">
    <xsl:attribute name="font-size">
      <xsl:value-of select="$default-font-size"/>
    </xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="sideCol1">
    <xsl:attribute name="width">
      <xsl:value-of select="$side-col-1"/>
    </xsl:attribute>
  </xsl:attribute-set>

  <!-- common attribute sets -->
  <xsl:attribute-set name="common.border"
    use-attribute-sets="common.border__top common.border__right common.border__bottom common.border__left"/>

  <xsl:attribute-set name="common.border__top">
    <xsl:attribute name="border-before-style">none</xsl:attribute>
    <xsl:attribute name="border-before-width">0pt</xsl:attribute>
    <xsl:attribute name="border-before-color">black</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="common.border__bottom">
    <xsl:attribute name="border-after-style">none</xsl:attribute>
    <xsl:attribute name="border-after-width">0pt</xsl:attribute>
    <xsl:attribute name="border-after-color">black</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="common.border__left">
    <xsl:attribute name="border-start-style">none</xsl:attribute>
    <xsl:attribute name="border-start-width">0pt</xsl:attribute>
    <xsl:attribute name="border-start-color">black</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="common.border__right">
    <xsl:attribute name="border-end-style">none</xsl:attribute>
    <xsl:attribute name="border-end-width">0pt</xsl:attribute>
    <xsl:attribute name="border-end-color">black</xsl:attribute>
  </xsl:attribute-set>

  <!-- paragraph-like blocks -->
  <xsl:attribute-set name="common.block">
    <xsl:attribute name="space-before">0.4em</xsl:attribute>
    <xsl:attribute name="space-after">0.8em</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="common.link">
    <xsl:attribute name="color">blue</xsl:attribute>
    <xsl:attribute name="font-style">normal</xsl:attribute>
  </xsl:attribute-set>

  <!-- titles -->
  <xsl:attribute-set name="common.title">
    <xsl:attribute name="font-family">SansLFRoman</xsl:attribute>
  </xsl:attribute-set>

  <!-- Balaji Mani IB2 11-July-2013: Reduce the space between footnote number and text -->
  <!-- EMC	  Hotfix_3.2    23-Jun-2015	  TKT 298: increase the spacing due to right align -->
  <xsl:attribute-set name="fn__body">
    <xsl:attribute name="provisional-distance-between-starts">10mm</xsl:attribute>
    <xsl:attribute name="provisional-label-separation">3mm</xsl:attribute>
    <xsl:attribute name="line-height">1.2</xsl:attribute>
    <xsl:attribute name="font-size">8pt</xsl:attribute>
    <xsl:attribute name="start-indent">0pt</xsl:attribute>
  </xsl:attribute-set>

  <!-- Balaji Mani IB2 18-July-2013: Reduce the space between footnote number and text for text flow -->
  <!-- EMC	 Hotfix_3.2		25-Jun-2015		TKT 298: Adding end-label() and body-start() -->
  <xsl:attribute-set name="fn__label_start">
    <xsl:attribute name="start-indent">0pt</xsl:attribute>
    <xsl:attribute name="end-indent">label-end()</xsl:attribute>
  </xsl:attribute-set>

  <!-- EMC	 	Hotfix_3.2		25-Jun-2015		TKT 298: Adding end-label() and body-start() -->
  <xsl:attribute-set name="fn__body_start">
    <xsl:attribute name="start-indent">body-start()</xsl:attribute>
  </xsl:attribute-set>

  <!-- Balaji Mani IB2 11-July-2013: callout always set 8.5 size -->
  <xsl:attribute-set name="fn__callout_ref">
    <xsl:attribute name="keep-with-previous.within-line">always</xsl:attribute>
    <xsl:attribute name="baseline-shift">super</xsl:attribute>
    <xsl:attribute name="font-size">8.5pt</xsl:attribute>
  </xsl:attribute-set>


  <!-- Balaji Mani IB2 11-July-2013: callout for table size -->
  <!-- Jason Holmberg 28-April-2015: testing baseline-shift removing this invalid value, hoping it falls back to superscript in commons-attr.xsl -->
  <!-- EMC	HotFix7.1    20-May-2015	Changing baseline shift to super, as the font size of the footnote marker should be of 8.5pt -->
  <!-- EMC	HotFix3.2	 17-Jul-2015	#298 Shifted the baseline shift to 5% -->
  <xsl:attribute-set name="fn__callout">
    <xsl:attribute name="keep-with-previous.within-line">always</xsl:attribute>
    <!--xsl:attribute name="baseline-shift">normal</xsl:attribute-->
    <xsl:attribute name="baseline-shift">5%</xsl:attribute>
    <xsl:attribute name="font-size">8.5pt</xsl:attribute>
  </xsl:attribute-set>

  <!-- Balaji Mani 29-July-2013: adjust the cross reference text -->
  <xsl:attribute-set name="fn_container">
    <xsl:attribute name="font-size">inherit</xsl:attribute>

    <!--Suite/EMC   SOW5  15-Feb-2012   font family - ck-->
    <xsl:attribute name="font-family">SansLFRoman</xsl:attribute>
  </xsl:attribute-set>

  <!--The following attr-sets were added for special table footnote processing - rs-->
  <xsl:attribute-set name="table-footnote.table">
    <xsl:attribute name="space-before">4pt</xsl:attribute>
    <xsl:attribute name="keep-together.within-page">always</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="table-footnote.tbody">

    <!--Suite/EMC   SOW5  15-Feb-2012   font family - ck-->
    <xsl:attribute name="font-family">SansLFRoman</xsl:attribute>

    <xsl:attribute name="start-indent">0pt</xsl:attribute>
    <xsl:attribute name="font-size">8pt</xsl:attribute>
    <xsl:attribute name="line-height">9pt</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="table-footnote.number">
    <xsl:attribute name="text-indent">0.2in</xsl:attribute>
    <xsl:attribute name="padding-bottom">4pt</xsl:attribute>
  </xsl:attribute-set>

  <!-- Natasha IB2 Note font-size in Table changed -->
  <xsl:attribute-set name="note" use-attribute-sets="common.block">
    <xsl:attribute name="space-before">0em</xsl:attribute>
    <xsl:attribute name="space-after">6pt</xsl:attribute>
    <xsl:attribute name="font-family">SansLFRoman</xsl:attribute>
    <xsl:attribute name="font-size">
      <xsl:choose>
        <xsl:when test="ancestor::table">9pt</xsl:when>
        <xsl:otherwise>10pt</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="line-height">
      <xsl:choose>
        <xsl:when test="ancestor::table">12pt</xsl:when>
        <xsl:otherwise>13pt</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="border-top">
      <xsl:choose>
        <xsl:when test="@type = 'note' or @type = 'tip' or @type = 'important' or not(@type)">1px
          solid black</xsl:when>
        <xsl:otherwise>none</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="border-bottom">1px solid black</xsl:attribute>
    <xsl:attribute name="padding-top">2pt</xsl:attribute>
    <xsl:attribute name="padding-bottom">2pt</xsl:attribute>
    <xsl:attribute name="keep-together.within-page">always</xsl:attribute>
    <xsl:attribute name="text-align">left</xsl:attribute>
    <xsl:attribute name="end-indent">0</xsl:attribute>
    <xsl:attribute name="width">100%</xsl:attribute>
  </xsl:attribute-set>

  <!-- IA   Tridion upgrade    Oct-2018   Add new admonitions view STARTS HERE. - IB-->
  <xsl:attribute-set name="note_table" use-attribute-sets="common.block">
    <xsl:attribute name="space-before">0em</xsl:attribute>
    <xsl:attribute name="space-after">6pt</xsl:attribute>
    <xsl:attribute name="font-family">SansLFRoman</xsl:attribute>
    <xsl:attribute name="font-size">
      <xsl:choose>
        <xsl:when test="ancestor::table"><xsl:value-of select="$default-table-font-size"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="$default-font-size"/></xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="line-height">
      <xsl:choose>
        <xsl:when test="ancestor::table">12pt</xsl:when>
        <xsl:otherwise>13pt</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="text-align">left</xsl:attribute>
    <xsl:attribute name="end-indent">0</xsl:attribute>
    <xsl:attribute name="table-layout">fixed</xsl:attribute>
    <xsl:attribute name="inline-progression-dimension">100%</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="note_image_cell">
    <xsl:attribute name="border-end-color">
      <xsl:choose>
        <xsl:when test="@type = 'warning'">rgb(206,32,40)</xsl:when>
        <xsl:when test="@type = 'caution'">rgb(240,174,29)</xsl:when>
        <xsl:when test="@type = 'danger'">rgb(255,102,0)</xsl:when>
        <xsl:otherwise>rgb(5,125,183)</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="border-end-width">1pt</xsl:attribute>
    <xsl:attribute name="border-end-style">solid</xsl:attribute>
    <xsl:attribute name="start-indent">0</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="note_body_cell_content">
    <xsl:attribute name="margin-left">2pt</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="note_body_cell">
    <xsl:attribute name="start-indent">0</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="note_colored_text">
    <xsl:attribute name="color">
      <xsl:choose>
        <xsl:when test="@type = 'warning'">rgb(206,32,40)</xsl:when>
        <xsl:when test="@type = 'caution'">rgb(240,174,29)</xsl:when>
        <xsl:when test="@type = 'danger'">rgb(255,102,0)</xsl:when>
        <xsl:otherwise>rgb(5,125,183)</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="font-weight">bold</xsl:attribute>
  </xsl:attribute-set>
  <!-- IA   Tridion upgrade    Oct-2018   Add new admonitions view ENDSnote__image HERE. - IB-->

  <xsl:attribute-set name="example.title" use-attribute-sets="common.title">
    <xsl:attribute name="font-size">9pt</xsl:attribute>
    <xsl:attribute name="font-weight">normal</xsl:attribute>
    <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
    <xsl:attribute name="space-before">5pt</xsl:attribute>
    <xsl:attribute name="padding-bottom">5pt</xsl:attribute>
    <xsl:attribute name="text-align-last">left</xsl:attribute>
    <xsl:attribute name="padding-top">5pt</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="fig.title" use-attribute-sets="base-font common.title">
    <xsl:attribute name="font-size">9pt</xsl:attribute>
    <xsl:attribute name="font-weight">normal</xsl:attribute>
    <xsl:attribute name="space-before.optimum">5pt</xsl:attribute>
    <xsl:attribute name="padding-bottom">5pt</xsl:attribute>
    <xsl:attribute name="keep-with-previous.within-page">always</xsl:attribute>
    <xsl:attribute name="text-align-last">left</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="topic.title" use-attribute-sets="common.title common.border__bottom">
    <xsl:attribute name="font-size">24pt</xsl:attribute>
    <xsl:attribute name="line-height">25pt</xsl:attribute>
    <xsl:attribute name="font-weight">normal</xsl:attribute>
    <xsl:attribute name="font-family">SansLFRoman</xsl:attribute>
    <xsl:attribute name="color">black</xsl:attribute>
    <xsl:attribute name="margin-top">0pc</xsl:attribute>
    <xsl:attribute name="margin-bottom">
      <!-- IA   Tridion upgrade    Mar-2019 IDPL-5477: Adapt 3 PDF output formats to support CPSD documenation.
                                Reduce space below Chapter Title if bookmap has @outputclass = 'omit_chapter_numbers'.  - IB-->
      <xsl:choose>
        <xsl:when test="$omit-chapter-numbers">6pt</xsl:when>
        <xsl:otherwise>37pt</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="padding-top">0pc</xsl:attribute>
    <xsl:attribute name="padding-bottom">
      <!-- IA   Tridion upgrade    Mar-2019 IDPL-5477: Adapt 3 PDF output formats to support CPSD documenation.
                                Reduce space below Chapter Title if bookmap has @outputclass = 'omit_chapter_numbers'.  - IB-->
      <xsl:choose>
        <xsl:when test="$omit-chapter-numbers">6pt</xsl:when>
        <xsl:otherwise>37pt</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="topic.title__rsa" use-attribute-sets="topic.title"/>

  <xsl:attribute-set name="topic.topic.title"
    use-attribute-sets="common.title common.border__bottom">
    <xsl:attribute name="font-family">
      <xsl:choose>
        <xsl:when test="$addBoldWeight = 'no'">SansMediumLFRoman</xsl:when>
        <xsl:otherwise>SansLFRoman</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="font-weight">
      <xsl:choose>
        <xsl:when test="$addBoldWeight = 'yes'">bold</xsl:when>
        <xsl:otherwise>normal</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="line-height">22pt</xsl:attribute>
    <xsl:attribute name="margin-top">18pt</xsl:attribute>
    <xsl:attribute name="margin-bottom">6pt</xsl:attribute>
    <xsl:attribute name="break-before">
      <!-- IA   Tridion upgrade    Mar-2019 IDPL-5477: Adapt 3 PDF output formats to support CPSD documenation.
                          Remove page break after Chapter topic. Process 2-nd level topic on the same page
                          as Chapter topic if bookmap has @outputclass = 'omit_chapter_numbers'.  - IB-->
      <xsl:if test="($NOCHAP = 'no') and(not($omit-chapter-numbers))">
        <xsl:variable name="type">
          <xsl:for-each select="ancestor::*[contains(@class, ' topic/topic ')][last()]">
            <xsl:call-template name="determineTopicType"/>
          </xsl:for-each>
        </xsl:variable>
        <xsl:if test="not(parent::*/preceding-sibling::*[contains(@class, ' topic/topic ')]) and not($type = 'topicPreface')">page</xsl:if>
      </xsl:if>
    </xsl:attribute>
    <xsl:attribute name="font-size">18pt</xsl:attribute>
    <xsl:attribute name="font-weight">
      <xsl:choose>
        <xsl:when test="$addBoldWeight = 'yes'">bold</xsl:when>
        <xsl:otherwise>normal</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="padding-top">0pc</xsl:attribute>
    <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
    <xsl:attribute name="keep-with-next.within-page">always</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="topic.topic.topic.title" use-attribute-sets="common.title">
    <xsl:attribute name="font-family">
      <xsl:choose>
        <xsl:when test="$addBoldWeight = 'no'">SansMediumLFRoman</xsl:when>
        <xsl:otherwise>SansLFRoman</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="color">black</xsl:attribute>
    <xsl:attribute name="margin-top">14pt</xsl:attribute>
    <xsl:attribute name="margin-bottom">7pt</xsl:attribute>
    <xsl:attribute name="font-size">14pt</xsl:attribute>
    <xsl:attribute name="font-weight">normal</xsl:attribute>
    <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
    <xsl:attribute name="line-height">15pt</xsl:attribute>
    <xsl:attribute name="margin-left">0in</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="topic.topic.topic.title__rsa"
    use-attribute-sets="topic.topic.topic.title"/>

  <xsl:attribute-set name="topic.topic.topic.topic.title"
    use-attribute-sets="base-font common.title">
    <xsl:attribute name="start-indent">0in</xsl:attribute>
    <xsl:attribute name="font-family">SansLFRoman</xsl:attribute>
    <xsl:attribute name="color">black</xsl:attribute>
    <xsl:attribute name="margin-top">12pt</xsl:attribute>
    <xsl:attribute name="margin-bottom">4pt</xsl:attribute>
    <xsl:attribute name="font-size">12pt</xsl:attribute>
    <xsl:attribute name="font-weight">normal</xsl:attribute>
    <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="topic.topic.topic.topic.title__rsa"
    use-attribute-sets="topic.topic.topic.topic.title"/>

  <xsl:attribute-set name="topic.topic.topic.topic.topic.title"
    use-attribute-sets="base-font common.title">
    <xsl:attribute name="start-indent">
      <xsl:value-of select="$side-col-width"/>
    </xsl:attribute>
    <xsl:attribute name="font-family">
      <xsl:choose>
        <xsl:when test="$addBoldWeight = 'no'">SansMediumLFRoman</xsl:when>
        <xsl:otherwise>SansLFRoman</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="color">black</xsl:attribute>
    <xsl:attribute name="margin-top">9pt</xsl:attribute>
    <xsl:attribute name="margin-bottom">5pt</xsl:attribute>
    <xsl:attribute name="font-size">12pt</xsl:attribute>
    <xsl:attribute name="font-weight">
      <xsl:choose>
        <xsl:when test="$addBoldWeight = 'yes'">bold</xsl:when>
        <xsl:otherwise>normal</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="topic.topic.topic.topic.topic.topic.title"
    use-attribute-sets="base-font common.title">
    <xsl:attribute name="start-indent">
      <xsl:value-of select="$side-col-width"/>
    </xsl:attribute>
    <xsl:attribute name="font-family">
      <xsl:choose>
        <xsl:when test="$addBoldWeight = 'no'">SansMediumLFRoman</xsl:when>
        <xsl:otherwise>SansLFRoman</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="color">black</xsl:attribute>
    <xsl:attribute name="margin-top">0pt</xsl:attribute>
    <xsl:attribute name="margin-bottom">0pt</xsl:attribute>
    <xsl:attribute name="font-size">10pt</xsl:attribute>
    <xsl:attribute name="font-weight">
      <xsl:choose>
        <xsl:when test="$addBoldWeight = 'yes'">bold</xsl:when>
        <xsl:otherwise>normal</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="font-style">normal </xsl:attribute>
    <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="section.title"
    use-attribute-sets="topic.topic.topic.topic.topic.topic.title">
    <xsl:attribute name="margin-left">0in</xsl:attribute>
    <xsl:attribute name="line-height">14pt</xsl:attribute>
    <xsl:attribute name="space-before">9pt</xsl:attribute>
    <xsl:attribute name="margin-bottom">5pt</xsl:attribute>
    <xsl:attribute name="color"><xsl:value-of select="$dell_blue"/></xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="fig">
    <xsl:attribute name="padding-bottom">
      <xsl:choose>
        <xsl:when test="ancestor::*[contains(@class, ' topic/li ')]">0</xsl:when>
        <xsl:otherwise>5pt</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="float">left</xsl:attribute>
    <xsl:attribute name="start-indent">0in</xsl:attribute>
    <xsl:attribute name="space-before">
      <xsl:choose>
        <xsl:when test="not(parent::*[contains(@class, ' task/info ')]) and not(preceding-sibling::*) and ancestor::*[contains(@class, ' topic/li ')]">8pt</xsl:when>
        <xsl:when test="parent::*[contains(@class, ' task/info ')][preceding-sibling::*] and not(preceding-sibling::*) and ancestor::*[contains(@class, ' topic/li ')]">2pt</xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="space-before.optimum">
      <xsl:choose>
        <xsl:when test="not(parent::*[contains(@class, ' task/info ')]) and not(preceding-sibling::*) and ancestor::*[contains(@class, ' topic/li ')]">8pt</xsl:when>
        <xsl:when test="parent::*[contains(@class, ' task/info ')][preceding-sibling::*] and not(preceding-sibling::*) and ancestor::*[contains(@class, ' topic/li ')]">2pt</xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="example" use-attribute-sets="base-font common.border">
    <xsl:attribute name="line-height">12pt</xsl:attribute>
    <xsl:attribute name="space-before">0em</xsl:attribute>
    <xsl:attribute name="margin-left">0in</xsl:attribute>
    <xsl:attribute name="margin-right">0in</xsl:attribute>
    <xsl:attribute name="padding">0pt</xsl:attribute>
    <xsl:attribute name="padding-bottom">5pt</xsl:attribute>
    <xsl:attribute name="padding-top">
      <xsl:choose>
        <xsl:when test="*[contains(@class, ' topic/title ')]">0pt</xsl:when>
        <xsl:otherwise>5pt</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:attribute-set>

  <!-- EMC  14-May-2014  IB4  #406 - Too little space between block-level elements in task examples -->
  <xsl:attribute-set name="example.sub.element">
    <xsl:attribute name="padding-bottom">3pt</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="example.sub.element.text">
    <xsl:attribute name="padding-top">1pt</xsl:attribute>
    <xsl:attribute name="padding-bottom">1pt</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="p" use-attribute-sets="common.block">
    <xsl:attribute name="text-indent">0em</xsl:attribute>
    <xsl:attribute name="space-before">0pt</xsl:attribute>
    <!-- Suite/EMC   RSA   19-Jul-2012   Customize text formatting of copyright page - REW -->
    <xsl:attribute name="space-after">
      <xsl:choose>
        <xsl:when
          test="$map//*[contains(@class, ' bookmap/notices ')]/@id = current()/ancestor-or-self::*[contains(@class, ' topic/topic ')][1]/@id"
          >9pt</xsl:when>
        <xsl:otherwise>5pt</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="space-after.optimum">
      <xsl:choose>
        <xsl:when
          test="$map//*[contains(@class, ' bookmap/notices ')]/@id = current()/ancestor-or-self::*[contains(@class, ' topic/topic ')][1]/@id"
          >9pt</xsl:when>
        <xsl:otherwise>5pt</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="line-height">
      <xsl:choose>
        <xsl:when
          test="$map//*[contains(@class, ' bookmap/notices ')]/@id = current()/ancestor-or-self::*[contains(@class, ' topic/topic ')][1]/@id"
          >11pt</xsl:when>
        <xsl:otherwise>12pt</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="text-align-last">left</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="p.note">
    <xsl:attribute name="text-indent">0em</xsl:attribute>
    <xsl:attribute name="space-before">0pt</xsl:attribute>
    <xsl:attribute name="space-after">0pt</xsl:attribute>
    <xsl:attribute name="space-after.optimum">0pt</xsl:attribute>
    <xsl:attribute name="line-height">12pt</xsl:attribute>
    <xsl:attribute name="text-align-last">left</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="topic" use-attribute-sets="base-font">
  </xsl:attribute-set>

  <xsl:attribute-set name="__fo__root">
    <xsl:attribute name="font-family">SansLFRoman</xsl:attribute>
    <!-- Suite/EMC  SOW7  20-03-2913    add xml:lang to identify language in i18n post-processing - rs -->
    <xsl:attribute name="xml:lang">
      <xsl:value-of select="descendant-or-self::*[@xml:lang][1]/@xml:lang"/>
    </xsl:attribute>
    <xsl:attribute name="font-size">
      <xsl:value-of select="$default-font-size"/>
    </xsl:attribute>
    <xsl:attribute name="rx:link-back">true</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="section__child">
    <xsl:attribute name="line-height">12pt</xsl:attribute>
    <xsl:attribute name="font-size">
      <xsl:value-of select="$default-font-size"/>
    </xsl:attribute>
  </xsl:attribute-set>

  <!-- Suite Jan-2012: updated formatting -->
  <!-- EMC 	25-Oct-2013		IB3		Issue 333: Formatting on <keyword> reduces usability  -->
  <xsl:attribute-set name="keyword">
    <xsl:attribute name="border-left-width">0pt</xsl:attribute>
    <xsl:attribute name="border-right-width">0pt</xsl:attribute>
    <xsl:attribute name="hyphenate">false</xsl:attribute>
  </xsl:attribute-set>

  <!-- Suite Jan-2012: updated formatting -->
  <xsl:attribute-set name="pre" use-attribute-sets="base-font common.block">
    <xsl:attribute name="space-before">1.2em</xsl:attribute>
    <xsl:attribute name="space-after">0.8em</xsl:attribute>
    <xsl:attribute name="white-space-treatment">preserve</xsl:attribute>
    <xsl:attribute name="white-space-collapse">false</xsl:attribute>
    <xsl:attribute name="linefeed-treatment">preserve</xsl:attribute>
    <xsl:attribute name="wrap-option">wrap</xsl:attribute>
    <xsl:attribute name="background-color">#f0f0f0</xsl:attribute>
    <xsl:attribute name="font-family">Monospaced</xsl:attribute>
    <xsl:attribute name="line-height">106%</xsl:attribute>
    <xsl:attribute name="font-size">
      <xsl:choose>
        <xsl:when
          test="
            ancestor::*[contains(@class, ' topic/note ')
            or contains(@class, ' topic/entry ')
            or contains(@class, ' task/taskbody ')]"
          >8pt</xsl:when>
        <xsl:otherwise>9pt</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:attribute-set>

  <!-- Suite Jan-2012: add attribute sets for admonition graphics - rs -->
  <xsl:attribute-set name="note__image">
    <xsl:attribute name="space-after">0</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="caution__text">
    <xsl:attribute name="font-family">
      <xsl:choose>
        <xsl:when test="$addBoldWeight = 'no'">SansMediumLFRoman</xsl:when>
        <xsl:otherwise>SansLFRoman</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="font-weight">
      <xsl:choose>
        <xsl:when test="$addBoldWeight = 'yes'">bold</xsl:when>
        <xsl:otherwise>normal</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="danger__text">
    <xsl:attribute name="font-family">
      <xsl:choose>
        <xsl:when test="$addBoldWeight = 'no'">SansMediumLFRoman</xsl:when>
        <xsl:otherwise>SansLFRoman</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="font-weight">
      <xsl:choose>
        <xsl:when test="$addBoldWeight = 'yes'">bold</xsl:when>
        <xsl:otherwise>normal</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="warning__text">
    <xsl:attribute name="font-family">
      <xsl:choose>
        <xsl:when test="$addBoldWeight = 'no'">SansMediumLFRoman</xsl:when>
        <xsl:otherwise>SansLFRoman</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="font-weight">
      <xsl:choose>
        <xsl:when test="$addBoldWeight = 'yes'">bold</xsl:when>
        <xsl:otherwise>normal</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="note.label">
    <xsl:attribute name="font-family">
      <xsl:choose>
        <xsl:when test="$addBoldWeight = 'no'">SansMediumLFRoman</xsl:when>
        <xsl:otherwise>SansLFRoman</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="font-weight">
      <xsl:choose>
        <xsl:when test="$addBoldWeight = 'yes'">bold</xsl:when>
        <xsl:otherwise>normal</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:attribute-set>


  <xsl:attribute-set name="image__block">
    <!--Suite/EMC   SOW5  10-Feb-2012   updated margin for pagewide images - ck-->
    <xsl:attribute name="margin-left">
      <xsl:choose>
        <!-- EMC	28-Oct-2013		IB3 	Issue 322: Horizontal spacing of <image> is incorrect in task substeps -->
        <xsl:when test="contains(@outputclass, 'pagewide') and (ancestor::*[contains(@class, ' task/substep ')])">-2.15in</xsl:when>
        <xsl:when test="contains(@outputclass, 'pagewide')"> -<xsl:value-of select="$side-col-width"/></xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:attribute>
  </xsl:attribute-set>

  <!--Suite/EMC   SOW7  10-Mar-2013   negative margin for pagewide figures within examples - rs-->
  <xsl:attribute-set name="fig__block">
    <xsl:attribute name="margin-left">
      <xsl:choose>
        <xsl:when
          test="contains(@outputclass, 'pagewide') and parent::*[contains(@class, ' topic/example ')]"
          >-0.88in</xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="topic__shortdesc" use-attribute-sets="body">
    <!--Suite/EMC   SOW5  19-Feb-2012   space after shortdesc - ck-->
    <xsl:attribute name="space-after">5pt</xsl:attribute>
    <xsl:attribute name="space-after.optimum">5pt</xsl:attribute>
  </xsl:attribute-set>


  <xsl:attribute-set name="lq_link">
    <xsl:attribute name="font-size">
      <xsl:value-of select="$default-font-size"/>
    </xsl:attribute>
    <xsl:attribute name="space-after">10pt</xsl:attribute>
    <xsl:attribute name="end-indent">92pt</xsl:attribute>
    <xsl:attribute name="text-align">right</xsl:attribute>
    <xsl:attribute name="font-weight">bold</xsl:attribute>
    <xsl:attribute name="color">blue</xsl:attribute>
    <!--Suite/EMC   SOW6  14-Mar-2012   Italic alternative for jp - ck-->
    <xsl:attribute name="font-style">
      <xsl:choose>
        <xsl:when test="$locale = 'ja'">normal</xsl:when>
        <xsl:otherwise>italic</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="lq_title">
    <xsl:attribute name="font-size">
      <xsl:value-of select="$default-font-size"/>
    </xsl:attribute>
    <xsl:attribute name="space-after">10pt</xsl:attribute>
    <xsl:attribute name="end-indent">92pt</xsl:attribute>
    <xsl:attribute name="text-align">right</xsl:attribute>
    <xsl:attribute name="font-weight">bold</xsl:attribute>
    <!--Suite/EMC   SOW6  14-Mar-2012   Italic alternative for jp - ck-->
    <xsl:attribute name="font-style">
      <xsl:choose>
        <xsl:when test="$locale = 'ja'">normal</xsl:when>
        <xsl:otherwise>italic</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:attribute-set>

  <!-- EMC		IB8		11-Nov-2015		TKT-165: For Chinese and Japanese "term" font style should be normal -->
  <xsl:attribute-set name="term">
    <xsl:attribute name="border-left-width">0pt</xsl:attribute>
    <xsl:attribute name="border-right-width">0pt</xsl:attribute>
    <!--Suite/EMC   SOW6  14-Mar-2012   Italic alternative for jp - ck-->
    <xsl:attribute name="font-style">
      <xsl:choose>
        <xsl:when test="$locale = 'ja' or $locale = 'zh_TW' or $locale = 'zh_CN'">normal</xsl:when>
        <xsl:otherwise>italic</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:attribute-set>

  <!-- EMC	14-Apr-2014		IB4		Issue 352: formatting changes for <cite>  -->
  <xsl:attribute-set name="cite">
    <xsl:attribute name="font-style">
      <xsl:choose>
        <xsl:when test="$locale = 'ja' or $locale = 'zh_TW' or $locale = 'zh_CN'">normal</xsl:when>
        <xsl:otherwise>italic</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="font-size">inherited-property-value(&apos;font-size&apos;) -
      .5pt</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="indextermref">
    <!--Suite/EMC   SOW6  14-Mar-2012   Italic alternative for jp - ck-->
    <xsl:attribute name="font-style">normal</xsl:attribute>
  </xsl:attribute-set>
  <!-- Suite/EMC   RSA   19-Jul-2012   Customize text formatting of copyright page - REW -->
  <xsl:attribute-set name="body">
    <xsl:attribute name="margin-left">
      <xsl:choose>
        <xsl:when
          test="$map//*[contains(@class, ' bookmap/notices ')]/@id = current()/ancestor-or-self::*[contains(@class, ' topic/topic ')][1]/@id"
          >0pt</xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$side-col-width"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="font-size">
      <xsl:choose>
        <xsl:when
          test="$map//*[contains(@class, ' bookmap/notices ')]/@id = current()/ancestor-or-self::*[contains(@class, ' topic/topic ')][1]/@id"
          >9pt</xsl:when>
        <xsl:otherwise>inherit</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="line-height">
      <xsl:choose>
        <xsl:when
          test="$map//*[contains(@class, ' bookmap/notices ')]/@id = current()/ancestor-or-self::*[contains(@class, ' topic/topic ')][1]/@id"
          >11pt</xsl:when>
        <xsl:otherwise>inherit</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="lines">
    <xsl:attribute name="font-size">
      <xsl:choose>
        <xsl:when
          test="$map//*[contains(@class, ' bookmap/notices ')]/@id = current()/ancestor-or-self::*[contains(@class, ' topic/topic ')][1]/@id"
          >9pt</xsl:when>
        <!-- EMC 	25-Oct-2013		IB3		Issue 355: <lines> renders in a smaller font within table -->
        <xsl:when
          test="ancestor::*[contains(@class, ' topic/table ') or contains(@class, ' topic/simpletable ')]"
          >9pt</xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$default-font-size"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="space-before">0.8em</xsl:attribute>
    <xsl:attribute name="space-after">0.8em</xsl:attribute>
    <xsl:attribute name="white-space-collapse">true</xsl:attribute>
    <xsl:attribute name="linefeed-treatment">preserve</xsl:attribute>
    <xsl:attribute name="wrap-option">wrap</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="copyright.title">
    <xsl:attribute name="font-size">14pt</xsl:attribute>
    <xsl:attribute name="line-height">16pt</xsl:attribute>
    <xsl:attribute name="font-weight">
      <xsl:choose>
        <xsl:when test="$addBoldWeight = 'yes'">bold</xsl:when>
        <xsl:otherwise>normal</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="font-family">
      <xsl:choose>
        <xsl:when test="$addBoldWeight = 'no'">SansMediumLFRoman</xsl:when>
        <xsl:otherwise>SansLFRoman</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="color">black</xsl:attribute>
    <xsl:attribute name="margin-top">0pc</xsl:attribute>
    <xsl:attribute name="margin-bottom">14pt</xsl:attribute>
    <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="tm__content">
    <xsl:attribute name="font-size">6.25pt</xsl:attribute>
    <xsl:attribute name="baseline-shift">20%</xsl:attribute>
  </xsl:attribute-set>

  <!-- Balaji Mani   PDF Bundle   9-Feb-2013   Update the lq -->
  <xsl:attribute-set name="lq" use-attribute-sets="base-font common.border">
    <xsl:attribute name="space-before">10pt</xsl:attribute>
    <xsl:attribute name="space-after">10pt</xsl:attribute>
    <xsl:attribute name="padding-left"/>
    <xsl:attribute name="start-indent"/>
    <xsl:attribute name="end-indent"/>
    <xsl:attribute name="text-align">left</xsl:attribute>
    <xsl:attribute name="margin-left">25pt</xsl:attribute>
    <xsl:attribute name="margin-right">25pt</xsl:attribute>
    <xsl:attribute name="border-style"/>
    <xsl:attribute name="border-color"/>
    <xsl:attribute name="border-width"/>
  </xsl:attribute-set>

  <xsl:attribute-set name="lq_simple" use-attribute-sets="base-font common.border">
    <xsl:attribute name="space-before">10pt</xsl:attribute>
    <xsl:attribute name="space-after">10pt</xsl:attribute>
    <xsl:attribute name="padding-left"/>
    <xsl:attribute name="start-indent"/>
    <xsl:attribute name="end-indent"/>
    <xsl:attribute name="text-align">left</xsl:attribute>
    <xsl:attribute name="margin-left">25pt</xsl:attribute>
    <xsl:attribute name="margin-right">25pt</xsl:attribute>
    <xsl:attribute name="border-style"/>
    <xsl:attribute name="border-color"/>
    <xsl:attribute name="border-width"/>
  </xsl:attribute-set>

  <!-- EMC	IB3		16-Nov-2013		Issue 326: Chapters should start on odd pages only. Changed force-page-count from 'even' to 'end-on-even'. -->
  <xsl:attribute-set name="__force__page__count">
    <xsl:attribute name="force-page-count">
      <xsl:choose>
        <xsl:when test="name(/*) = 'bookmap'">
          <xsl:value-of select="'end-on-even'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'auto'"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:attribute-set>

  <!-- IA   Tridion upgrade    Mar-2019 IDPL-5477: Adapt 3 PDF output formats to support CPSD documenation.
                     Add specific '__force__page__count__force__page__count_chapter' attr-set for Chapter in order to dynamically
                     decide if it is required to start every chapter on even page.
                     Do this only for Chapters and ignore Glosaary, Index and Appendix.  - IB-->
  <xsl:attribute-set name="__force__page__count_chapter">
    <xsl:attribute name="force-page-count">
      <xsl:choose>
        <xsl:when test="$omit-chapter-numbers">
          <xsl:value-of select="'auto'"/>
        </xsl:when>
        <xsl:when test="name(/*) = 'bookmap'">
          <xsl:value-of select="'end-on-even'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'auto'"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:attribute-set>

  <!-- EMC  IB4    15-Apr-2014   #403 - Text bleeds margin in <example> with <fig> -->
  <xsl:attribute-set name="__from__fig__or__example__width">
    <xsl:attribute name="width">5.268in</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="tm__content">
    <xsl:attribute name="font-size">
      <xsl:choose>
        <xsl:when test="ancestor::*[contains(@class, ' map/topicmeta ')]">100%</xsl:when>
        <xsl:otherwise>75%</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="baseline-shift">
      <xsl:choose>
        <xsl:when test="ancestor::*[contains(@class, ' map/topicmeta ')]">0%</xsl:when>
        <xsl:otherwise>20%</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="topic_guid">
    <!-- IA   Tridion upgrade    Oct-2018   Add topic GUID below title if required property set. - IB-->
    <xsl:attribute name="color"><xsl:value-of select="$dell_blue"/></xsl:attribute>
    <xsl:attribute name="space-after">10pt</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="draft-comment">
    <xsl:attribute name="background-color">#99FF99</xsl:attribute>
    <xsl:attribute name="color">black</xsl:attribute>
    <xsl:attribute name="padding">4pt</xsl:attribute>
    <xsl:attribute name="border-before-style">solid</xsl:attribute>
    <xsl:attribute name="border-before-width">1pt</xsl:attribute>
    <xsl:attribute name="border-before-color">#63d663</xsl:attribute>
    <xsl:attribute name="border-after-style">solid</xsl:attribute>
    <xsl:attribute name="border-after-width">1pt</xsl:attribute>
    <xsl:attribute name="border-after-color">#63d663</xsl:attribute>
    <xsl:attribute name="border-start-style">solid</xsl:attribute>
    <xsl:attribute name="border-start-width">1pt</xsl:attribute>
    <xsl:attribute name="border-start-color">#63d663</xsl:attribute>
    <xsl:attribute name="border-end-style">solid</xsl:attribute>
    <xsl:attribute name="border-end-width">1pt</xsl:attribute>
    <xsl:attribute name="border-end-color">#63d663</xsl:attribute>
  </xsl:attribute-set>

</xsl:stylesheet>
