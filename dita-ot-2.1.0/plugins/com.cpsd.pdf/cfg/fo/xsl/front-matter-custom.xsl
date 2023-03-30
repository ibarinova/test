<?xml version='1.0'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:opentopic="http://www.idiominc.com/opentopic"
                exclude-result-prefixes="opentopic"
                version="2.0">

    <xsl:template name="createFrontMatter">
        <xsl:choose>
            <xsl:when test="$NOCHAP = 'yes'">
                <fo:page-sequence master-reference="front-matter-nochap">
                    <xsl:call-template name="insertFrontMatterStaticContents"/>
                    <fo:flow flow-name="xsl-region-body">
                        <xsl:call-template name="frontmatter_image"/>
                        <fo:block-container xsl:use-attribute-sets="__frontmatter">
                            <xsl:call-template name="createFrontCoverContents"/>
                        </fo:block-container>
                    </fo:flow>
                </fo:page-sequence>
            </xsl:when>
            <xsl:when test="$SOLUTIONS = 'yes'">
                <!-- Intelliarts Consulting   SolutionsPDF    10-Mar-2017   Add page sequence for Solutions PDF  - IB-->
                <fo:page-sequence master-reference="front-matter-solutions"
                                  xsl:use-attribute-sets="__force__page__count">
                    <xsl:call-template name="insertFrontMatterStaticContents"/>
                    <fo:flow flow-name="xsl-region-body">
                        <fo:block/>
                        <xsl:call-template name="frontmatter_image"/>
                        <xsl:call-template name="insert-solutions-main-frontmatter-block"/>
                        <xsl:call-template name="insert-solutions-category-frontmatter-block"/>
                        <xsl:call-template name="insert-solutions-abstract-frontmatter-block"/>
                        <xsl:call-template name="insert-solutions-author-frontmatter-block"/>
                        <xsl:call-template name="inside_cover"/>
                    </fo:flow>
                </fo:page-sequence>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="$generate-front-cover">
                    <fo:page-sequence master-reference="front-matter" xsl:use-attribute-sets="__force__page__count">
                        <xsl:call-template name="insertFrontMatterStaticContents"/>
                        <fo:flow flow-name="xsl-region-body">
                            <xsl:call-template name="frontmatter_image"/>
                            <fo:block-container xsl:use-attribute-sets="__frontmatter">
                                <xsl:call-template name="createFrontCoverContents"/>
                            </fo:block-container>
                            <xsl:call-template name="inside_cover"/>
                        </fo:flow>
                    </fo:page-sequence>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="createFrontCoverContents">
        <xsl:variable name="mainbooktitle">
            <xsl:apply-templates select="$map/descendant::*[contains(@class, ' bookmap/mainbooktitle ')]"/>
        </xsl:variable>
        <xsl:variable name="booktitlealt">
            <xsl:apply-templates select="$map/descendant::*[contains(@class, ' bookmap/booktitlealt ')]"/>
        </xsl:variable>
        <xsl:variable name="version" select="$map/descendant::*[contains(@class, ' topic/vrm')][last()]/@version"/>
        <xsl:variable name="year" select="$map/descendant::*[contains(@class,' bookmap/bookmeta ')]/descendant::*[contains(@class,' bookmap/completed ')]/*[contains(@class,' bookmap/year ')]"/>
        <xsl:variable name="month" select="$map/descendant::*[contains(@class,' bookmap/bookmeta ')]/descendant::*[contains(@class,' bookmap/completed ')]/*[contains(@class,' bookmap/month ')]"/>
        <xsl:variable name="bookpartno" select="$map/descendant::*[contains(@class,' bookmap/bookmeta ')]/descendant::*[contains(@class,' bookmap/bookpartno ')]"/>
        <xsl:variable name="volume" select="$map/descendant::*[contains(@class,' bookmap/bookmeta ')]/descendant::*[contains(@class,' bookmap/volume ')]"/>

        <xsl:variable name="shortdesc">
            <xsl:apply-templates select="$map/descendant::*[contains(@class,' bookmap/bookmeta ')]/descendant::*[contains(@class,' map/shortdesc ')][contains(@outputclass, 'abstract')][1]"/>
        </xsl:variable>

        <xsl:variable name="release" select="($map/descendant::*[contains(@class,' topic/vrm ')])[last()]/@release"/>
        <xsl:variable name="regulatory-model" select="/descendant::*[contains(@class, 'topic/othermeta')][@name = 'regulatorymodel'][last()]/@content"/>
        <xsl:variable name="regulatory-type" select="/descendant::*[contains(@class, 'topic/othermeta')][@name = 'regulatorytype'][last()]/@content"/>

        <!-- IA   Tridion upgrade    Oct-2018   Common upgrade for RSA and Dell (NO-chap and chapter-based) outputs in current template:
                                                - Use <booktitlealt> instead of <category> value;
                                                - Use <mainbooktitle> instead of <seriae> and <prodname> values;
                                                - Add shortdesc on cover page;
                                                - Add Date value
                                                - Moved duplicated code of <version> processing to named template - IB-->
        <xsl:choose>
            <xsl:when test="$NOCHAP = 'yes'">
                <xsl:choose>
                    <!-- Intelliarts Consulting   DellEMC Rebranding    18-Oct-2016  Add specific arrt-sets for RSA 'nochap' publication.
                                                                      All other code is the same as for Dell/EMC/Mozy 'nochap' publications. Difference is only in font color. - IB-->
                    <xsl:when test="$BRAND-IS-RSA">
                        <xsl:if test="not(normalize-space($booktitlealt) = '')">
                            <fo:block xsl:use-attribute-sets="__frontmatter__booktitlealt__nochap__rsa">
                                <xsl:value-of select="$booktitlealt"/>
                                <xsl:text> </xsl:text>
                            </fo:block>
                        </xsl:if>
						<!-- Dimitri: Render nochap title page flush left. -->
                        <!--fo:block margin-left="170px"-->
						<fo:block margin-left="0px">
                            <fo:block xsl:use-attribute-sets="__frontmatter__series__nochap__rsa">
                                <xsl:value-of select="$mainbooktitle"/>
                            </fo:block>
                            <!-- Intelliarts Consulting   DellEMC Rebranding    18-Oct-2016  Add specific arrt-set for <version> in order to use specific rsa font color  - IB-->
                            <fo:block xsl:use-attribute-sets="__frontmatter__version__nochap__rsa">
                                <xsl:call-template name="insert-front-matter-version">
                                    <xsl:with-param name="version" select="$version"/>
                                    <xsl:with-param name="release" select="$release"/>
                                </xsl:call-template>
                            </fo:block>
                        </fo:block>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="not(normalize-space($booktitlealt) = '')">
                            <fo:block xsl:use-attribute-sets="__frontmatter__booktitlealt__nochap">
                                <xsl:value-of select="$booktitlealt"/>
                                <xsl:text> </xsl:text>
                            </fo:block>
                        </xsl:if>
						<!-- Dimitri: Render nochap title page flush left. -->
                        <!--fo:block margin-left="170px"-->
                        <fo:block margin-left="0px">
                            <fo:block xsl:use-attribute-sets="__frontmatter__series__nochap">
                                <xsl:value-of select="$mainbooktitle"/>
                            </fo:block>
                            <fo:block xsl:use-attribute-sets="__frontmatter__version__nochap">
                                <xsl:call-template name="insert-front-matter-version">
                                    <xsl:with-param name="version" select="$version"/>
                                    <xsl:with-param name="release" select="$release"/>
                                </xsl:call-template>
                            </fo:block>
                        </fo:block>
                    </xsl:otherwise>
                </xsl:choose>
                <!-- Balaji Mani 7-Aug-13: Updated the title process -->
                <!-- EMC    25-Oct-2013   IB3   Issue 329: Title of <notices> topic is incorrectly displayed on the first page of nochap PDF -->
				<!-- Dimitri: Render nochap title page flush left. -->
                <!--fo:block margin-left="170px"-->
				<fo:block margin-left="0px">
                    <xsl:if test="not(normalize-space($shortdesc) = '')">
                        <fo:block xsl:use-attribute-sets="__frontmatter__abstrac_title">
                            <xsl:call-template name="getVariable">
                                <xsl:with-param name="id" select="'Abstract'"/>
                            </xsl:call-template>
                        </fo:block>
                        <fo:block xsl:use-attribute-sets="__frontmatter__shortdesc">
                            <xsl:value-of select="$shortdesc"/>
                        </fo:block>
                    </xsl:if>
                    <fo:block xsl:use-attribute-sets="__frontmatter__title__nochap">
                        <xsl:choose>
							<xsl:when test="$map//*[contains(@class, ' bookmap/notices ')]">
								<xsl:for-each select="//bookmap/*[contains(@class, ' topic/topic' )]">
									<xsl:if test="//*[contains(@class, ' bookmap/chapter ')][1][@id = current()/@id]">
										<xsl:for-each select="*[contains(@class,' topic/title ')]">
											<xsl:apply-templates/>
										</xsl:for-each>
									</xsl:if>
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>
								<xsl:for-each select="(//title)[1]">
									<xsl:apply-templates/>
								</xsl:for-each>
							</xsl:otherwise>
                        </xsl:choose>
                    </fo:block>
					<!-- Dimitri: Disable rendering <bookpartno> in uppercase. -->
                    <!--fo:block xsl:use-attribute-sets="__frontmatter__text__nochap">
                        <xsl:call-template name="upperCase">
                            <xsl:with-param name="upperCaseText"
                                            select="$map//*[contains(@class,' bookmap/bookpartno ')]"/>
                        </xsl:call-template>
                        <xsl:text>  </xsl:text>
                    </fo:block-->
                    <fo:block xsl:use-attribute-sets="__frontmatter__5">
                        <xsl:value-of select="$bookpartno"/>
                    </fo:block>
                    <!-- Intelliarts Consulting   DellEMC Rebranding    18-Oct-2016  Add specific arrt-set for <edition> in order to use specific font color  - IB-->
					<!-- Dimitri: Disable rendering <volume> in uppercase. -->
                    <!--fo:block xsl:use-attribute-sets="__frontmatter__edition__nochap">
                        <xsl:call-template name="upperCase">
                            <xsl:with-param name="upperCaseText"
                                            select="$map//*[contains(@class,' bookmap/volume ')]"/>
                        </xsl:call-template>
                        <xsl:text> </xsl:text>
                    </fo:block-->
					<fo:block xsl:use-attribute-sets="__frontmatter__5">
						<xsl:value-of select="$volume"/>
					</fo:block>
                    <!-- Comtech/EMC AdvTraining 24-Jan-2013 Output barcode when outputclass="barcode" -->
                    <!-- Intelliarts Consulting   DellEMC Rebranding    18-Oct-2016   Move barcode block to separate template in order to avoid code duplication - IB-->
                    <xsl:call-template name="insert-front-matter-barcode"/>
                    <fo:block xsl:use-attribute-sets="__frontmatter__text__nochap">
                        <fo:block xsl:use-attribute-sets="__frontmatter__published__nochap">
                            <xsl:if test="not(normalize-space($year) = '' and normalize-space($month) = '')">
                                <xsl:call-template name="insertVariable">
                                    <xsl:with-param name="theVariableID" select="'Copyright_stat2_nochap'"/>
                                    <xsl:with-param name="theParameters">
                                        <month_published>
                                            <xsl:apply-templates
                                                    select="($map//*[contains(@class,' bookmap/completed ')]/*[contains(@class,' bookmap/month ')])[1]"/>
                                        </month_published>
                                        <year_published>
                                            <xsl:apply-templates
                                                    select="($map//*[contains(@class,' bookmap/completed ')]/*[contains(@class,' bookmap/year ')])[1]"/>
                                        </year_published>
                                    </xsl:with-param>
                                </xsl:call-template>
                            </xsl:if>
                        </fo:block>
                    </fo:block>
                    <xsl:if test="$generate-mini-toc">
                        <!-- IA   Tridion upgrade    Oct-2018   Add support for DELL othermeta parameters - IB-->
                        <!-- IA   Tridion upgrade    Oct-2018   Do not generate mini-toc ONLY if 'mini-toc' <othermeta> value equal 'no'  - IB-->
                        <xsl:for-each select="//bookmap/*[contains(@class, ' topic/topic' )]">
                            <xsl:if test="//*[contains(@class, ' bookmap/chapter ')][1][@id = current()/@id]">
                                <xsl:apply-templates select="*[contains(@class,' topic/body ')]/*"/>
                            </xsl:if>
                        </xsl:for-each>
                        <xsl:for-each select="//bookmap/*[contains(@class, ' topic/topic' )]">
                            <xsl:if test="//*[contains(@class, ' bookmap/chapter ') or contains(@class, ' bookmap/appendix ') or contains(@class, ' bookmap/part ')][@id = current()/@id]">
                                <fo:block xsl:use-attribute-sets="__toc__mini">
                                    <xsl:if test="*[contains(@class, ' topic/topic ')]">
                                        <fo:list-block xsl:use-attribute-sets="__toc__mini__list">
                                            <xsl:apply-templates select="*[contains(@class, ' topic/topic ')]"
                                                                 mode="in-this-chapter-list"/>
                                        </fo:list-block>
                                    </xsl:if>
                                </fo:block>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:if>
                </fo:block>
            </xsl:when>

            <xsl:otherwise>
                <xsl:choose>
                    <!-- Intelliarts Consulting   DellEMC Rebranding    10-Oct-2016   Add using of RSA BRAND values from BRAND list instead of @outputclass with 'rsa' value - IB-->
                    <xsl:when test="$BRAND-IS-RSA">
                        <xsl:if test="not(normalize-space($booktitlealt) = '')">
                            <fo:block xsl:use-attribute-sets="__frontmatter__title__rsa">
                                <xsl:value-of select="$mainbooktitle"/>
                            </fo:block>
                        </xsl:if>
                        <fo:block xsl:use-attribute-sets="__frontmatter__version__rsa">
                            <xsl:call-template name="insert-front-matter-version">
                                <xsl:with-param name="version" select="$version"/>
                                <xsl:with-param name="release" select="$release"/>
                            </xsl:call-template>
                        </fo:block>
                    </xsl:when>
                    <xsl:otherwise>
                        <fo:block xsl:use-attribute-sets="__frontmatter__title">
                            <xsl:value-of select="$mainbooktitle"/>
                        </fo:block>
                        <fo:block xsl:use-attribute-sets="__frontmatter__version">
                            <xsl:call-template name="insert-front-matter-version">
                                <xsl:with-param name="version" select="$version"/>
                                <xsl:with-param name="release" select="$release"/>
                            </xsl:call-template>
                        </fo:block>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="not(normalize-space($booktitlealt) = '')">
                    <fo:block xsl:use-attribute-sets="__frontmatter__booktitlealt">
                        <xsl:value-of select="$booktitlealt"/>
                    </fo:block>
                </xsl:if>
                <xsl:if test="not(normalize-space($shortdesc) = '')">
                    <fo:block-container xsl:use-attribute-sets="__frontmatter__abstract_container">
                        <fo:block xsl:use-attribute-sets="__frontmatter__abstrac_title">
                            <xsl:call-template name="getVariable">
                                <xsl:with-param name="id" select="'Abstract'"/>
                            </xsl:call-template>
                        </fo:block>
                        <fo:block xsl:use-attribute-sets="__frontmatter__shortdesc">
                            <xsl:value-of select="$shortdesc"/>
                        </fo:block>
                    </fo:block-container>
                </xsl:if>
                <xsl:if test="not(normalize-space($bookpartno) = '')">
                    <fo:block xsl:use-attribute-sets="__frontmatter__5">
                        <xsl:value-of select="$bookpartno"/>
                    </fo:block>
                </xsl:if>
                <xsl:if test="not(normalize-space($volume) = '')">
                    <fo:block xsl:use-attribute-sets="__frontmatter__5">
                        <xsl:value-of select="$volume"/>
                    </fo:block>
                </xsl:if>
                <xsl:if test="not(normalize-space($month) = '') or not(normalize-space($year) = '')">
                    <fo:block xsl:use-attribute-sets="__frontmatter__date">
                        <xsl:value-of select="$month"/>
                        <xsl:if test="not(normalize-space($year) = '')">
                            <xsl:text> </xsl:text>
                        </xsl:if>
                        <xsl:value-of select="$year"/>
                    </fo:block>
                </xsl:if>
                <!-- Intelliarts Consulting   DellEMC Rebranding    18-Oct-2016   Move barcode block to separate template in order to avoid code duplication - IB-->
                <xsl:call-template name="insert-front-matter-barcode"/>
            </xsl:otherwise>
        </xsl:choose>

        <!-- IA   Tridion upgrade    Oct-2018   Add support for DELL Regulatory Model / Type values STARTS HERE- IB-->
        <xsl:if test="not($BRAND-IS-RSA)">
            <fo:block-container xsl:use-attribute-sets="__frontmatter__regulatory_container">
                <xsl:if test="normalize-space($regulatory-model)">
                    <fo:block xsl:use-attribute-sets="__frontmatter__regulatory_data">
                        <xsl:call-template name="insertVariable">
                            <xsl:with-param name="theVariableID" select="'Regulatory Model'"/>
                            <xsl:with-param name="theParameters">
                                <value>
                                    <xsl:value-of select="$regulatory-model"/>
                                </value>
                            </xsl:with-param>
                        </xsl:call-template>
                    </fo:block>
                </xsl:if>
                <xsl:if test="normalize-space($regulatory-type)">
                    <fo:block xsl:use-attribute-sets="__frontmatter__regulatory_data">
                        <xsl:call-template name="insertVariable">
                            <xsl:with-param name="theVariableID" select="'Regulatory Type'"/>
                            <xsl:with-param name="theParameters">
                                <value>
                                    <xsl:value-of select="$regulatory-type"/>
                                </value>
                            </xsl:with-param>
                        </xsl:call-template>
                    </fo:block>
                </xsl:if>
                <!-- IA   Tridion upgrade    Oct-2018   Add support for DELL Regulatory Model / Type values ENDS HERE- IB-->
            </fo:block-container>
        </xsl:if>

        <xsl:call-template name="insert-dellrestricted-container"/>
    </xsl:template>

    <xsl:template name="insert-front-matter-version">
        <xsl:param name="version"/>
        <xsl:param name="release"/>
        <!-- Suite/EMC   SOW7    18-Feb-2013   Suppress version and release when version=0 - rs -->
		<!-- Dimitri: Test if version is empty. -->
        <!--xsl:if test="$version != '0' and $version != '0.0'"-->
		<xsl:if test="$version != '0' and $version != '0.0' and $version != ''">
            <xsl:choose>
                <xsl:when test="$compare-available='yes'">
                    <xsl:call-template name="versionProcess">
                        <xsl:with-param name="text" select="$map"/>
                        <xsl:with-param name="variableID" select="'version frontpage'"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
					<!-- Dimitri: Conditional processing of the version prefix string, depending on the value of the /bookmap/@outputclass attribute. -->
                    <!--xsl:call-template name="insertVariable">
                        <xsl:with-param name="theVariableID" select="'version frontpage'"/>
                        <xsl:with-param name="theParameters">
                            <version>
                                <xsl:value-of select="$version"/>
                                <xsl:if test="$release">.<xsl:value-of select="$release"/>
                                </xsl:if>
                            </version>
                        </xsl:with-param>
                    </xsl:call-template-->
					<xsl:variable name="vrm_prefix">
						<xsl:choose>
							<xsl:when test="contains(/bookmap/@outputclass, 'vrm_prefix_ver') or not(contains(/bookmap/@outputclass, 'vrm_prefix_'))">version frontpage</xsl:when>
							<xsl:when test="contains(/bookmap/@outputclass, 'vrm_prefix_rel')">release frontpage</xsl:when>
							<xsl:when test="contains(/bookmap/@outputclass, 'vrm_prefix_rev')">revision frontpage</xsl:when>
							<xsl:when test="contains(/bookmap/@outputclass, 'vrm_prefix_none')">none frontpage</xsl:when>
						</xsl:choose>
					</xsl:variable>
					<xsl:call-template name="insertVariable">
						<xsl:with-param name="theVariableID" select="$vrm_prefix"/>
						<xsl:with-param name="theParameters">
							<version>
								<xsl:value-of select="$version"/>
								<xsl:if test="$release">.<xsl:value-of select="$release"/>
								</xsl:if>
							</version>
						</xsl:with-param>
					</xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        <xsl:if test="($version = '0' or $version = '0.0') and $compare-available='yes'">
            <xsl:call-template name="versionProcess">
                <xsl:with-param name="text" select="$map"/>
                <xsl:with-param name="variableID" select="'version frontpage'"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="insert-front-matter-barcode">
        <!-- Intelliarts Consulting   DellEMC Rebranding    18-Oct-2016   Move barcode block to separate template in order to avoid code duplication - IB-->
        <xsl:if test="$BARCODE='yes'">
            <xsl:choose>
                <xsl:when test="normalize-space($map//*[contains(@class,' bookmap/bookpartno ')]) != ''">
                    <fo:block xsl:use-attribute-sets="barcode39_nochap">
                        *
                        <xsl:call-template name="upperCase">
                            <xsl:with-param name="upperCaseText"
                                            select="$map//*[contains(@class,' bookmap/bookpartno ')]"/>
                        </xsl:call-template>
                        *
                    </fo:block>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message>
                        <xsl:text>Warning: The bookmap/bookpartno element is empty. Add a value to bookmap/bookpartno or remove outputclass="barcode" from the bookmap.</xsl:text>
                    </xsl:message>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

    <xsl:template name="frontmatter_image">
        <fo:block-container xsl:use-attribute-sets="frontpage-image.block">
            <xsl:choose>
                <!-- Intelliarts Consulting   DellEMC Rebranding    10-Oct-2016   Set front-matter images for RSA PDF - IB-->
                <xsl:when test="$BRAND-IS-RSA">
                    <fo:block>
                        <xsl:choose>
                            <xsl:when test="$NOCHAP = 'yes'">
                                <fo:external-graphic xsl:use-attribute-sets="frontpage-image"
                                                     src="url(Customization/OpenTopic/common/artwork/emc_cover_graphics/cover_background_rsa_nochap.eps)"
                                />
                            </xsl:when>
                            <xsl:otherwise>
                                <fo:external-graphic xsl:use-attribute-sets="frontpage-image"
                                                     src="url(Customization/OpenTopic/common/artwork/emc_cover_graphics/cover_background_rsa.eps)"
                                />
                            </xsl:otherwise>
                        </xsl:choose>
                    </fo:block>
                </xsl:when>
                <!-- Intelliarts Consulting   DellEMC Rebranding    10-Oct-2016   Set front-matter images for Legacy EMC PDF - IB-->
                <!-- Intelliarts Consulting   DellEMC Rebranding    17-Oct-2016   change front-matter background image for
                                                      Legacy EMC PDF from cover_background_a.eps to legacy_emc_cover.svg (the same image for Legacy NOCHAP PDF) - IB-->
                <!-- IA   Tridion upgrade    Oct-2018   Remove using of 'EMC' brand. Use instead DellEMC - IB-->
<!--
                <xsl:when test="$BRAND-IS-EMC">
                    <fo:block>
                        <fo:external-graphic xsl:use-attribute-sets="frontpage-image"
                                             src="url(Customization/OpenTopic/common/artwork/emc_cover_graphics/legacy_emc_cover.svg)"/>
                    </fo:block>
                </xsl:when>
-->
                <!-- Intelliarts Consulting   DellEMC Rebranding    10-Oct-2016   Set front-matter image for Dell Mozy PDF - IB-->
                <xsl:when test="$BRAND-IS-MOZY">
                    <fo:block>
                        <fo:external-graphic xsl:use-attribute-sets="frontpage-image"
                                             src="url(Customization/OpenTopic/common/artwork/emc_cover_graphics/dell_emc_mozy_cover.svg)"/>
                    </fo:block>
                </xsl:when>
                <!-- Intelliarts Consulting   DellEMC Rebranding    10-Oct-2016   Set front-matter image for Dell EMC PDF as default.   - IB-->
                <xsl:otherwise>
                    <fo:block>
                        <fo:external-graphic xsl:use-attribute-sets="frontpage-image"
                                             src="url(Customization/OpenTopic/common/artwork/emc_cover_graphics/dell_emc_cover.svg)"/>
                    </fo:block>
                </xsl:otherwise>
            </xsl:choose>
        </fo:block-container>
    </xsl:template>

    <xsl:template name="insert-dellrestricted-container">
        <!-- IA   Tridion upgrade    Oct-2018   Add support for 'DELLRESTRICTED' property.
                                                Add container at the bottom of cover page with white text on blue bar   - IB-->
        <xsl:choose>
            <xsl:when test="$DECR">
                <fo:block-container xsl:use-attribute-sets="frontmatter__dellrestricted_container">
                    <fo:block xsl:use-attribute-sets="frontmatter__dellrestricted">
                        <xsl:choose>
                            <xsl:when test="$BRAND-IS-RSA">
                                <xsl:call-template name="insertVariable">
                                    <xsl:with-param name="theVariableID" select="'Dell RSA Confidential Restricted'"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="insertVariable">
                                    <xsl:with-param name="theVariableID" select="'Dell EMC Confidential Restricted'"/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </fo:block>
                </fo:block-container>
            </xsl:when>
            <xsl:when test="$DEC">
                <fo:block-container xsl:use-attribute-sets="frontmatter__dellrestricted_container">
                    <fo:block xsl:use-attribute-sets="frontmatter__dellrestricted">
                        <xsl:choose>
                            <xsl:when test="$BRAND-IS-RSA">
                                <xsl:call-template name="insertVariable">
                                    <xsl:with-param name="theVariableID" select="'Dell RSA Confidential'"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="insertVariable">
                                    <xsl:with-param name="theVariableID" select="'Dell EMC Confidential'"/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </fo:block>
                </fo:block-container>
            </xsl:when>
            <xsl:when test="$DEI">
                <fo:block-container xsl:use-attribute-sets="frontmatter__dellrestricted_container">
                    <fo:block xsl:use-attribute-sets="frontmatter__dellrestricted">
                        <xsl:choose>
                            <xsl:when test="$BRAND-IS-RSA">
                                <xsl:call-template name="insertVariable">
                                    <xsl:with-param name="theVariableID" select="'Dell RSA Internal'"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="insertVariable">
                                    <xsl:with-param name="theVariableID" select="'Dell EMC Internal'"/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </fo:block>
                </fo:block-container>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <!-- Suite/EMC   RSA   19-Jul-2012   If this is an RSA map and there's a notices section, use that for the inside front cover instead - starts here - REW -->
    <!-- EMC    AlternateBranding     01-Jul-2015  Mark Moulder  Look for Notices section in bookmap to display different copyright statement. -->
    <xsl:template name="inside_cover">
        <!--added by rs to handle copyright info-->
        <fo:block xsl:use-attribute-sets="inside.cover">
            <xsl:choose>
                <!-- Intelliarts Consulting   DellEMC Rebranding    10-Oct-2016   Use <notices> referenced topic as custom Copyrights for ALL brands  - IB-->
                <xsl:when
                        test="//*[contains(@class, ' topic/topic ')][@id = $map//*[contains(@class, ' bookmap/notices ')]/@id]">
                    <xsl:for-each
                            select="//*[contains(@class, ' topic/topic ')][@id = $map//*[contains(@class, ' bookmap/notices ')]/@id]">
                        <xsl:if test="child::*[contains(@class, ' topic/title ')]/text()[string-length(normalize-space()) > 0]">
                            <fo:block xsl:use-attribute-sets="copyright.title">
                                <xsl:call-template name="pullPrologIndexTerms"/>
                                <xsl:for-each select="child::*[contains(@class, ' topic/title ')]">
                                    <xsl:apply-templates select="." mode="getTitle"/>
                                </xsl:for-each>
                            </fo:block>
                        </xsl:if>
                        <fo:block>
                            <xsl:apply-templates
                                    select="
                *[not(contains(@class, ' topic/topic ') or contains(@class, ' topic/title ') or
                contains(@class, ' topic/prolog '))]"
                            />
                        </fo:block>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <fo:block xsl:use-attribute-sets="inside.cover.p">
                        <xsl:variable name="firstYear">
                            <xsl:value-of
                                    select="$map//*[contains(@class, ' bookmap/copyrfirst ')]/*[contains(@class, ' bookmap/year ')]"
                            />
                        </xsl:variable>
                        <xsl:variable name="lastYear">
                            <xsl:value-of
                                    select="$map//*[contains(@class, ' bookmap/copyrlast ')]/*[contains(@class, ' bookmap/year ')]"
                            />
                        </xsl:variable>
                        <xsl:call-template name="insertVariable">
                            <xsl:with-param name="theVariableID" select="'Copyright_stat1'"/>
                            <xsl:with-param name="theParameters">
                                <year>
                                    <xsl:choose>
                                        <!--Suite/EMC   SOW5  15-Feb-2012   display only year when firstyear=lastyear -->
                                        <xsl:when test="$firstYear = $lastYear">
                                            <xsl:apply-templates
                                                    select="$map//*[contains(@class, ' bookmap/copyrfirst ')]/*[contains(@class, ' bookmap/year ')]"
                                            />
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:apply-templates
                                                    select="$map//*[contains(@class, ' bookmap/copyrfirst ')]/*[contains(@class, ' bookmap/year ')]"/>
                                            <xsl:text>-</xsl:text>
                                            <xsl:apply-templates
                                                    select="$map//*[contains(@class, ' bookmap/copyrlast ')]/*[contains(@class, ' bookmap/year ')]"
                                            />
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </year>
                                <owner>
                                    <xsl:call-template name="processWithPI">
                                        <xsl:with-param name="processWithPIText"
                                                        select="($map//*[contains(@class, ' bookmap/bookowner ')]/*[contains(@class, ' bookmap/organization ')])[1]"
                                        />
                                    </xsl:call-template>
                                </owner>
                            </xsl:with-param>
                        </xsl:call-template>
                    </fo:block>
                    <!-- IA   Tridion upgrade    Oct-2018   Remove Date from copyrights. - IB-->

                    <!--                 <xsl:variable name="year">
                                         <xsl:value-of
                                                 select="$map//*[contains(@class, ' bookmap/completed ')]/*[contains(@class, ' bookmap/year ')]"
                                         />
                                     </xsl:variable>
                                     <xsl:variable name="month">
                                         <xsl:value-of
                                                 select="$map//*[contains(@class, ' bookmap/completed ')]/*[contains(@class, ' bookmap/month ')]"
                                         />
                                     </xsl:variable>
                                     &lt;!&ndash;Suite/EMC   SOW5  15-Feb-2012   Removed published text when month and year don't exist - ck.&ndash;&gt;
                                     <xsl:if test="not(normalize-space($year) = '' and normalize-space($month) = '')">
                                         <fo:block xsl:use-attribute-sets="inside.cover.p">
                                             <xsl:call-template name="insertVariable">
                                                 <xsl:with-param name="theVariableID" select="'Copyright_stat2'"/>
                                                 <xsl:with-param name="theParameters">
                                                     <month_published>
                                                         <xsl:apply-templates
                                                                 select="($map//*[contains(@class, ' bookmap/completed ')]/*[contains(@class, ' bookmap/month ')])[1]"
                                                         />
                                                     </month_published>
                                                     <year_published>
                                                         <xsl:apply-templates
                                                                 select="($map//*[contains(@class, ' bookmap/completed ')]/*[contains(@class, ' bookmap/year ')])[1]"
                                                         />
                                                     </year_published>
                                                 </xsl:with-param>
                                             </xsl:call-template>
                                         </fo:block>
                                     </xsl:if>
                 -->                    <fo:block xsl:use-attribute-sets="inside.cover.p">
                        <xsl:call-template name="insertVariable">
                            <xsl:with-param name="theVariableID" select="'Copyright_stat3'"/>
                        </xsl:call-template>
                    </fo:block>
                    <fo:block xsl:use-attribute-sets="inside.cover.p">
                        <xsl:call-template name="insertVariable">
                            <xsl:with-param name="theVariableID" select="'Copyright_stat4'"/>
                        </xsl:call-template>
                    </fo:block>
                    <!-- Balaji Mani PDF Bundle 8-Feb-2013: sup2 parameretr added -->
                    <fo:block xsl:use-attribute-sets="inside.cover.p">
                        <xsl:call-template name="insertVariable">
                            <xsl:with-param name="theVariableID" select="'Copyright_stat5'"/>
                            <xsl:with-param name="theParameters">
                                <sup2>
                                    <fo:inline vertical-align="super" font-size="6pt">2</fo:inline>
                                </sup2>
                            </xsl:with-param>
                        </xsl:call-template>
                    </fo:block>
                    <fo:block xsl:use-attribute-sets="inside.cover.p"></fo:block>
                    <!-- Suite/EMC   Nochap   22-Aug-2012   Remove  copyright statement from nochap  -->
                    <xsl:if test="$NOCHAP = 'no'">
                        <fo:block>
                            <!-- Intelliarts Consulting   DellEMC Rebranding    24-Oct-2016   Separate Copyright Company for different publication brands.
                                                    Use 'Copyright_stat7' for Legacy EMC or RSA and 'Copyright_stat7a' for  DellEMC or Mozy    - IB-->
                            <xsl:choose>
                                <xsl:when test="$BRAND-IS-RSA or $BRAND-IS-EMC">
                                    <xsl:call-template name="insertVariable">
                                        <xsl:with-param name="theVariableID" select="'Copyright_stat7'"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="insertVariable">
                                        <xsl:with-param name="theVariableID" select="'Copyright_stat7a'"/>
                                    </xsl:call-template>
                                </xsl:otherwise>
                            </xsl:choose>
                        </fo:block>
                        <fo:block>
                            <xsl:call-template name="insertVariable">
                                <xsl:with-param name="theVariableID" select="'Copyright_stat8'"/>
                            </xsl:call-template>
                        </fo:block>
                        <!-- Balaji Mani 8-Feb-2013: Updated white space as preserved -->
                        <fo:block>
                            <xsl:if
                                    test="translate($locale, '-ABCDEFGHIJKLMNOPQRSTUVWXYZ', '_abcdefghijklmnopqrstuvwxyz') = 'ja'">
                                <xsl:attribute name="white-space">pre</xsl:attribute>
                            </xsl:if>
                            <xsl:call-template name="insertVariable">
                                <xsl:with-param name="theVariableID" select="'Copyright_stat9'"/>
                            </xsl:call-template>
                        </fo:block>
                        <fo:block>
                            <!-- Intelliarts Consulting   DellEMC Rebranding    24-Oct-2016   Separate Copyright URL for different publication brands.
                                                            Use 'Copyright_stat10' for Legacy EMC or RSA and 'Copyright_stat10a' for  DellEMC or Mozy    - IB-->
                            <xsl:choose>
                                <xsl:when test="$BRAND-IS-RSA or $BRAND-IS-EMC">
                                    <xsl:call-template name="insertVariable">
                                        <xsl:with-param name="theVariableID" select="'Copyright_stat10'"/>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="insertVariable">
                                        <xsl:with-param name="theVariableID" select="'Copyright_stat10a'"/>
                                    </xsl:call-template>
                                </xsl:otherwise>
                            </xsl:choose>
                        </fo:block>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </fo:block>
    </xsl:template>

    <xsl:template name="versionProcess">
        <xsl:param name="text"/>
        <xsl:param name="variableID"/>
        <xsl:for-each select="($text//*[contains(@class,' topic/vrmlist ')])[last()]/node()">
            <xsl:choose>
                <xsl:when test="name()='vrm'">
                    <xsl:call-template name="insertVariable">
                        <xsl:with-param name="theVariableID" select="$variableID"/>
                        <xsl:with-param name="theParameters">
                            <version>
                                <xsl:value-of select="@version"/>
                                <!--Suite/EMC   SOW5  19-Feb-2012   Include period and release version only when release exists START - ck-->
                                <xsl:if test="$text//*[contains(@class,' topic/vrm ')][last()]/@release and $NOCHAP != 'yes'">
                                    .
                                    <xsl:value-of select="$text//*[contains(@class,' topic/vrm ')][last()]/@release"/>
                                </xsl:if>
                            </version>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="self::processing-instruction()">
                    <xsl:apply-templates select="."/>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="upperCase">
        <xsl:param name="upperCaseText"/>
        <xsl:for-each select="$upperCaseText/node()">
            <xsl:choose>
                <xsl:when test="self::text()">
                    <xsl:value-of select="upper-case(.)"/>
                </xsl:when>
                <xsl:when test="self::processing-instruction()">
                    <xsl:apply-templates select="."/>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="processWithPI">
        <xsl:param name="processWithPIText"/>
        <xsl:for-each select="$processWithPIText/node()">
            <xsl:choose>
                <xsl:when test="self::text()">
                    <xsl:value-of select="."/>
                </xsl:when>
                <xsl:when test="self::processing-instruction()">
                    <xsl:apply-templates select="."/>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <!-- Intelliarts Consulting   SolutionsPDF    10-Mar-2017   Add absolute positioned block containers for Solutions PDF cover page STARS HERE  - IB-->
    <xsl:template name="insert-solutions-main-frontmatter-block">
        <xsl:variable name="mainbooktitle">
            <xsl:apply-templates select="$map/descendant::*[contains(@class, ' bookmap/mainbooktitle ')]"/>
        </xsl:variable>
        <xsl:variable name="booktitlealt">
            <xsl:apply-templates select="$map/descendant::*[contains(@class, ' bookmap/booktitlealt ')]"/>
        </xsl:variable>
        <xsl:variable name="version">
            <xsl:call-template name="versionProcess">
                <xsl:with-param name="text" select="$map"/>
                <xsl:with-param name="variableID" select="'version frontpage'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="version-value"
                      select="$map/descendant::*[contains(@class, ' topic/vrm')][last()]/@version"/>
        <xsl:variable name="year"
                      select="$map/descendant::*[contains(@class,' bookmap/bookmeta ')]/descendant::*[contains(@class,' bookmap/completed ')]/*[contains(@class,' bookmap/year ')]"/>
        <xsl:variable name="month"
                      select="$map/descendant::*[contains(@class,' bookmap/bookmeta ')]/descendant::*[contains(@class,' bookmap/completed ')]/*[contains(@class,' bookmap/month ')]"/>
        <xsl:variable name="bookpartno"
                      select="$map/descendant::*[contains(@class,' bookmap/bookmeta ')]/descendant::*[contains(@class,' bookmap/bookpartno ')]"/>
        <xsl:variable name="edition"
                      select="$map/descendant::*[contains(@class,' bookmap/bookmeta ')]/descendant::*[contains(@class,' bookmap/edition ')]"/>

        <fo:block-container xsl:use-attribute-sets="__frontmatter__solutions_main_container">
            <fo:block xsl:use-attribute-sets="__frontmatter__title">
                <xsl:value-of select="$mainbooktitle"/>
            </fo:block>
            <fo:block xsl:use-attribute-sets="__frontmatter__titlealt">
                <xsl:value-of select="$booktitlealt"/>
            </fo:block>
            <xsl:if test="not(normalize-space($version-value) = '')
                            and not(normalize-space($version-value) = '0')
                            and not(normalize-space($version-value) = '0.0')">
                <fo:block xsl:use-attribute-sets="__frontmatter__version__solutions">
                    <xsl:value-of select="$version"/>
                </fo:block>
            </xsl:if>
            <xsl:if test="not(normalize-space($month) = '') or not(normalize-space($year) = '')">
                <fo:block xsl:use-attribute-sets="__frontmatter__date">
                    <xsl:value-of select="$month"/>
                    <xsl:if test="not(normalize-space($year) = '')">
                        <xsl:text> </xsl:text>
                    </xsl:if>
                    <xsl:value-of select="$year"/>
                </fo:block>
            </xsl:if>
            <xsl:if test="not(normalize-space($bookpartno) = '')">
                <fo:block xsl:use-attribute-sets="__frontmatter__bookpartno">
                    <xsl:value-of select="$bookpartno"/>
                </fo:block>
            </xsl:if>
            <xsl:if test="not(normalize-space($edition) = '')">
                <fo:block xsl:use-attribute-sets="__frontmatter__edition">
                    <xsl:value-of select="$edition"/>
                </fo:block>
            </xsl:if>
        </fo:block-container>
    </xsl:template>

    <xsl:template name="insert-solutions-category-frontmatter-block">
        <xsl:variable name="category"
                      select="$map/descendant::*[contains(@class,' bookmap/bookmeta ')]/descendant::*[contains(@class,' topic/category ')]"/>
        <fo:block-container xsl:use-attribute-sets="__frontmatter__solutions_category_container">
            <fo:block xsl:use-attribute-sets="__frontmatter__solutions__category">
                <xsl:value-of select="$category"/>
            </fo:block>
        </fo:block-container>
    </xsl:template>

    <xsl:template name="insert-solutions-abstract-frontmatter-block">
        <xsl:variable name="shortdesc">
            <xsl:apply-templates select="$map/descendant::*[contains(@class,' bookmap/bookmeta ')]/descendant::*[contains(@class,' map/shortdesc ')][contains(@outputclass, 'abstract')][1]"/>
        </xsl:variable>
        <fo:block-container xsl:use-attribute-sets="__frontmatter__solutions_abstract_container">
            <xsl:if test="not(normalize-space($shortdesc) = '')">
                <fo:block xsl:use-attribute-sets="__frontmatter__solutions_abstrac_title">
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'Abstract'"/>
                    </xsl:call-template>
                </fo:block>
                <fo:block xsl:use-attribute-sets="__frontmatter__solutions_shortdesc">
                    <xsl:value-of select="$shortdesc"/>
                </fo:block>
            </xsl:if>
        </fo:block-container>
    </xsl:template>

    <xsl:template name="insert-solutions-author-frontmatter-block">
        <xsl:variable name="author"
                      select="$map/descendant::*[contains(@class,' bookmap/bookmeta ')]/descendant::*[contains(@class,' topic/author ')]"/>
        <fo:block-container xsl:use-attribute-sets="__frontmatter__solutions_author_container">
            <fo:block xsl:use-attribute-sets="__frontmatter__author">
                <xsl:value-of select="$author"/>
            </fo:block>
        </fo:block-container>
    </xsl:template>
    <!-- Intelliarts Consulting   SolutionsPDF    10-Mar-2017   Add absolute positioned block containers for Solutions PDF cover page ENDS HERE  - IB-->

</xsl:stylesheet>