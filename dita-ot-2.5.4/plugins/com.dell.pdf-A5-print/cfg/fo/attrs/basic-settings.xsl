<?xml version="1.0" encoding="UTF-8"?>
<!-- ============================================================= -->
<!--                    Release  Information                       -->
<!-- ============================================================= -->
<!-- Changed brand mapping  from brand tag to output class  -->
<!-- DATE:      Feb 25 2020                                 -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                version="2.0">

    <xsl:variable name="chapterLayout" select="'BASIC'"/>
	<xsl:variable name="table.frame-default">all</xsl:variable>
	<xsl:variable name="table.rowsep-default" select="'1'"/>
    <xsl:variable name="table.colsep-default" select="'1'"/>
    <xsl:variable name="page-width">148mm</xsl:variable>
    <xsl:variable name="page-height">210mm</xsl:variable>

    <xsl:variable name="page-margin-inside" select="'15mm'"/>
    <xsl:variable name="page-margin-outside" select="'12mm'"/>
    <xsl:variable name="page-margin-top" select="'0.51in'"/>
    <xsl:variable name="page-margin-top_toc" select="'1.05in'"/>
    <xsl:variable name="page-margin-bottom" select="'0.72in'"/>

    <xsl:variable name="side-col-width">0pt</xsl:variable>

    <xsl:variable name="default-font-size" select="if($multilingual and not($isManual)) then('7pt') else('9pt')"/>
    <xsl:variable name="default-line-height" select="if($multilingual and not($isManual)) then('8pt') else('10pt')"/>

    <xsl:variable name="mirror-page-margins" select="true()" as="xs:boolean"/>
    <xsl:variable name="generate-back-cover" select="true()" as="xs:boolean"/>
    <xsl:variable name="generate-toc" select="if($multilingual and not($isManual)) then(false()) else(true())" as="xs:boolean"/>

    <xsl:variable name="temp-dir-location" select="concat('file:///', translate($TEMP-DIR, '\', '/'),'/')"/>

    <xsl:variable name="merged-multilingual-map-doc" select="document($merged-multilingual-map)"/>

    <xsl:variable name="artwork-dir" select="concat($customizationDir.url, 'common/artwork/')"/>
    <xsl:variable name="artwork-logo-dir" select="concat($artwork-dir, 'logo/')"/>

    <xsl:variable name="multilingual" select="if(lower-case($combine-languages) = 'yes') then(true()) else(false())" as="xs:boolean"/>

    <xsl:variable name="all-merged-ditamaps" select="$merged-multilingual-map-doc/descendant::*[contains(@class, ' map/topicref ')][normalize-space(@href)][@format = 'ditamap']" />

    <xsl:variable name="firstPublicationDitamap">
        <xsl:choose>
            <xsl:when test="$multilingual">
                <xsl:for-each select="$all-merged-ditamaps[1]">
                    <xsl:sequence select="document(concat($temp-dir-location, @href))"/>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="/"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="firstPublicationDitamap-map" select="$firstPublicationDitamap/descendant-or-self::*[contains(@class, ' map/map ')][1]"/>

    <xsl:variable name="task-labels-required" select="if($firstPublicationDitamap/descendant::*[contains(@class, ' topic/othermeta ')][@name = 'task-labels']/@content = 'yes') then true() else false()"/>

    <xsl:variable name="book.partnumber" select="$firstPublicationDitamap/descendant::*[contains(@class, ' topic/othermeta ')][@name = 'PDF-partnumber'][1]/@content"/>

    <xsl:variable name="model.number">
        <xsl:value-of select="$firstPublicationDitamap/descendant::*[contains(@class, ' bookmap/bookid ')][1]/*[contains(@class, ' bookmap/bookpartno ')][1]"   />
    </xsl:variable>

    <xsl:variable name="type.number">
        <xsl:value-of select="$firstPublicationDitamap/descendant::*[contains(@class, ' bookmap/bookid ')][1]/*[contains(@class, ' bookmap/booknumber ')][1]"/>
    </xsl:variable>

    <xsl:variable name="computer.model">
        <xsl:apply-templates select="$firstPublicationDitamap/descendant::*[contains(@class, ' topic/prodinfo ')][1]/*[contains(@class, ' topic/platform ')][1]"/>
    </xsl:variable>

    <xsl:variable name="completed.month">
        <xsl:apply-templates select="$firstPublicationDitamap/descendant::*[contains(@class, ' bookmap/published ')][1]/*[contains(@class, ' bookmap/completed ')]/*[contains(@class, ' bookmap/month ')]"/>
    </xsl:variable>

    <xsl:variable name="release.date">
        <xsl:if test="normalize-space($completed.month)">
            <xsl:value-of select="$completed.month"/>
            <xsl:text> </xsl:text>
        </xsl:if>
		<xsl:apply-templates select="$firstPublicationDitamap/descendant::*[contains(@class, ' bookmap/published ')][1]/*[contains(@class, ' bookmap/completed ')]/*[contains(@class, ' bookmap/year ')]"/>
    </xsl:variable>

    <xsl:variable name="book.revision">
        <xsl:value-of select="normalize-space($firstPublicationDitamap/descendant::*[contains(@class, ' bookmap/bookid ')]/*[contains(@class, ' bookmap/volume ')])"/>
    </xsl:variable>

    <xsl:variable name="product.name">
        <xsl:value-of select="normalize-space($firstPublicationDitamap/descendant::*[contains(@class, ' bookmap/bookmeta ')]/descendant::*[contains(@class, ' topic/prodname ')][1])"/>
    </xsl:variable>

    <xsl:variable name="url">
        <xsl:value-of select="normalize-space($firstPublicationDitamap/descendant::*[contains(@class, ' bookmap/bookmeta ')]/descendant::*[contains(@class, ' xnal-d/authorinformation ')][1]/*[contains(@class, ' xnal-d/organizationinfo ')]/*[contains(@class, ' xnal-d/urls ')]/*[contains(@class, ' xnal-d/url ')])"/>
    </xsl:variable>

	<xsl:variable name="brand">
        <xsl:value-of select="$firstPublicationDitamap/descendant::*[contains(@class, ' bookmap/bookmap ')]/@outputclass"/>
    </xsl:variable>
    <xsl:variable name="isManual" as="xs:boolean" select="if(lower-case($brand) = 'manual') then(true()) else(false())"/>

    <xsl:variable name="barcode.folder">
        <xsl:text>E:\InfoShare\Data\PublishingService\Resources\barcode\</xsl:text>
    </xsl:variable>

    <xsl:variable name="barcode">
        <xsl:variable name="lang">
            <xsl:choose>
                <xsl:when test="$multilingual">
                    <xsl:variable name="thisMLTB" select="$firstPublicationDitamap/descendant::*[contains(@class, ' topic/othermeta ')][@content = $language-combination][contains(@name, 'DELLMLTB')][1]"/>
                    <xsl:value-of select="substring-after($thisMLTB/@name, 'DELLMLTB_')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="/descendant::*[contains(@class, ' map/map ')][normalize-space(@xml:lang)][1]/@xml:lang"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="nospace.product.name">
            <xsl:value-of select="translate($product.name,' ','')"/>
        </xsl:variable>

        <xsl:variable name="nospace.brand">
            <xsl:value-of select="translate($brand,' ','')"/>
        </xsl:variable>

        <xsl:value-of select="concat($barcode.folder, $nospace.product.name,'-', $nospace.brand, '-', $book.revision, '-', $lang, '.jpg')"/>
    </xsl:variable>

    <xsl:variable name="image_default_alignment_othermeta"
                  select="if($multilingual)
                        then($firstPublicationDitamap/descendant::*[contains(@class, ' topic/othermeta ')][@name = 'image_default_alignment'][1]/@content)
                        else(lower-case(/descendant::*[contains(@class, ' topic/othermeta ')][@name = 'image_default_alignment'][1]/@content))"/>
    <xsl:variable name="imageDefaultAlignment"
                  select="if($image_default_alignment_othermeta = ('left', 'center', 'right'))
                            then($image_default_alignment_othermeta)
                            else('center')"/>

</xsl:stylesheet>