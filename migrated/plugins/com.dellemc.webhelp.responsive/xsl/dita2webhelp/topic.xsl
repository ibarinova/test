<?xml version="1.0" encoding="UTF-8"?>
<!--
This file is part of the DITA Open Toolkit project.
See the accompanying LICENSE file for applicable license.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:xs="http://www.w3.org/2001/XMLSchema"
				xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
				xmlns:dita2html="http://dita-ot.sourceforge.net/ns/200801/dita2html"
				xmlns:ditamsg="http://dita-ot.sourceforge.net/ns/200704/ditamsg"
				version="2.0"
				exclude-result-prefixes="xs dita-ot dita2html ditamsg">

	<xsl:template name="getDellString">
		<xsl:param name="dell-id"/>

		<xsl:variable name="dell-string">
			<xsl:call-template name="getVariable">
				<xsl:with-param name="id" select="$dell-id"/>
			</xsl:call-template>
		</xsl:variable>

		<xsl:variable name="default-id" select="substring-before($dell-id, '-dell')"/>

		<xsl:choose>
			<xsl:when test="normalize-space($dell-string) and not(normalize-space($dell-string) = normalize-space($dell-id))">
				<xsl:value-of select="$dell-string"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="getVariable">
					<xsl:with-param name="id" select="$default-id"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="chapterHead">
		<head>
			<!-- initial meta information -->
			<xsl:call-template name="generateCharset"/>   <!-- Set the character set to UTF-8 -->
			<xsl:call-template name="generateDefaultCopyright"/> <!-- Generate a default copyright, if needed -->
			<xsl:call-template name="generateDefaultMeta"/> <!-- Standard meta for security, robots, etc -->
			<xsl:call-template name="getMeta"/>           <!-- Process metadata from topic prolog -->
			<xsl:call-template name="copyright"/>         <!-- Generate copyright, if specified manually -->
			<xsl:call-template name="generateCssLinks"/>  <!-- Generate links to CSS files -->
			<xsl:call-template name="generateChapterTitle"/>
			<meta name="meta-topic-title" content="{$mapTitle}"></meta>
			<xsl:call-template name="gen-user-head" />    <!-- include user's XSL HEAD processing here -->
			<xsl:call-template name="gen-user-scripts" /> <!-- include user's XSL javascripts here -->
			<xsl:call-template name="gen-user-styles" />  <!-- include user's XSL style element and content here -->
			<xsl:call-template name="processHDF"/>        <!-- Add user HDF file, if specified -->

			<script>
				var metaelement = $("[name=meta-topic-title]");
				document.title = $(metaelement).attr("content");
			</script>
		</head>
	</xsl:template>

	<xsl:template match="*[contains(@class, ' topic/section ')][contains(@outputclass, 'show_hide')][*[contains(@class, ' topic/title ')]]">
		<section class="section">
			<xsl:call-template name="commonattributes"/>
			<xsl:call-template name="gen-toc-id"/>
			<xsl:call-template name="setidaname"/>
			<xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
			<xsl:apply-templates select="." mode="dita2html:section-heading"/>
			<div>
				<xsl:apply-templates select="*[not(contains(@class, ' topic/title '))] | text() | comment() | processing-instruction()"/>
			</div>
			<xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
		</section>
	</xsl:template>

	<xsl:template match="*[contains(@class, ' topic/section ')][@outputclass eq 'show_hide'][not(*[contains(@class, ' topic/title ')])]">
		<div class="show_hide">
			<div class="no_title_expander"></div>
			<xsl:next-match/>
		</div>
	</xsl:template>

	<xsl:template match="*[contains(@class, ' topic/section ')][@outputclass eq 'show_hide_expanded'][not(*[contains(@class, ' topic/title ')])]">
		<div class="show_hide_expanded">
			<div class="no_title_expander"></div>
			<xsl:next-match/>
		</div>
	</xsl:template>

	<xsl:template match="*[contains(@class, ' topic/example ')][@outputclass eq 'show_hide'][not(*[contains(@class, ' topic/title ')])]">
		<div class="show_hide">
			<div class="no_title_expander"></div>
			<xsl:next-match/>
		</div>
	</xsl:template>

	<xsl:template match="*[contains(@class, ' topic/example ')][@outputclass eq 'show_hide_expanded'][not(*[contains(@class, ' topic/title ')])]">
		<div class="show_hide_expanded">
			<div class="no_title_expander"></div>
			<xsl:next-match/>
		</div>
	</xsl:template>

	<xsl:template match="*[contains(@class, ' topic/p ')][@outputclass eq 'show_hide']">
		<div class="show_hide">
			<div class="no_title_expander"></div>
			<xsl:next-match/>
		</div>
	</xsl:template>

	<xsl:template match="*[contains(@class, ' topic/p ')][@outputclass eq 'show_hide_expanded']">
		<div class="show_hide_expanded">
			<div class="no_title_expander"></div>
			<xsl:next-match/>
		</div>
	</xsl:template>

	<xsl:template match="*[contains(@class, ' topic/ol ')][@outputclass eq 'show_hide']" priority="10">
		<div class="show_hide">
			<div class="no_title_expander"></div>
			<xsl:next-match/>
		</div>
	</xsl:template>

	<xsl:template match="*[contains(@class, ' topic/ol ')][@outputclass eq 'show_hide_expanded']" priority="10">
		<div class="show_hide_expanded">
			<div class="no_title_expander"></div>
			<xsl:next-match/>
		</div>
	</xsl:template>

	<xsl:template match="*[contains(@class, ' topic/ul ')][@outputclass eq 'show_hide']" priority="10">
		<div class="show_hide">
			<div class="no_title_expander"></div>
			<xsl:next-match/>
		</div>
	</xsl:template>

	<xsl:template match="*[contains(@class, ' topic/ul ')][@outputclass eq 'show_hide_expanded']" priority="10">
		<div class="show_hide_expanded">
			<div class="no_title_expander"></div>
			<xsl:next-match/>
		</div>
	</xsl:template>

<!--
	<xsl:template match="*[contains(@class, ' topic/fig ')]" name="topic.fig">
		<xsl:variable name="className">
			<xsl:choose>
				<xsl:when test="*[contains(@class, ' topic/image ')][@placement='break'][@align='center']">figcapcenter</xsl:when>
				<xsl:when test="*[contains(@class, ' topic/image ')][@placement='break'][@align='right']">figcapright</xsl:when>
				<xsl:when test="*[contains(@class, ' topic/image ')][@placement='break'][@align='justify']">figcapjustify</xsl:when>
				<xsl:otherwise>figcap</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="default-fig-class">
			<xsl:apply-templates select="." mode="dita2html:get-default-fig-class"/>
		</xsl:variable>
		<xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>

		<div>
			<xsl:call-template name="commonattributes">
				<xsl:with-param name="default-output-class" select="$default-fig-class"/>
			</xsl:call-template>
			<p class="{$className}">
				<xsl:call-template name="place-fig-lbl"/>
				<xsl:text> </xsl:text>
			</p>
			<figure>
				<xsl:if test="$default-fig-class != ''">
					<xsl:attribute name="class" select="$default-fig-class"/>
				</xsl:if>
				<xsl:call-template name="commonattributes">
					<xsl:with-param name="default-output-class" select="$default-fig-class"/>
				</xsl:call-template>
				<xsl:call-template name="setscale"/>
				<xsl:apply-templates select="*[not(contains(@class,' topic/title '))][not(contains(@class,' topic/desc '))] |text()|comment()|processing-instruction()"/>
			</figure>
		</div>

		<xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
	</xsl:template>
-->

	<xsl:template name="place-fig-lbl">
		<xsl:param name="stringName"/>
		<!-- Number of fig/title's including this one -->
		<xsl:variable name="fig-count-actual" select="count(preceding::*[contains(@class, ' topic/fig ')]/*[contains(@class, ' topic/title ')])+1"/>
		<xsl:variable name="ancestorlang">
			<xsl:call-template name="getLowerCaseLang"/>
		</xsl:variable>

		<xsl:if test="*[contains(@class, ' topic/title ')]">
			<figcaption>
				<xsl:attribute name="data-caption-side" select="$figure.title.placement"/>
				<xsl:choose>
					<xsl:when
							test="*[contains(@class, ' topic/image ')][@placement = 'break'][@align = 'center']">
						<xsl:attribute name="class">- topic/title title figcapcenter</xsl:attribute>
					</xsl:when>
					<xsl:when
							test="*[contains(@class, ' topic/image ')][@placement = 'break'][@align = 'right']">
						<xsl:attribute name="class">- topic/title title figcapright</xsl:attribute>
					</xsl:when>
					<xsl:when
							test="*[contains(@class, ' topic/image ')][@placement = 'break'][@align = 'justify']">
						<xsl:attribute name="class">- topic/title title figcapjustify</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="class">- topic/title title figcap</xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
				<span class="figure-label">
					<xsl:choose>      <!-- Hungarian: "1. Figure " -->
						<xsl:when test="$ancestorlang = ('hu', 'hu-hu')">
							<xsl:value-of select="$fig-count-actual"/>
							<xsl:text>. </xsl:text>
							<xsl:call-template name="getVariable">
								<xsl:with-param name="id" select="'Figure'"/>
							</xsl:call-template>
							<xsl:text> </xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="getVariable">
								<xsl:with-param name="id" select="'Figure'"/>
							</xsl:call-template>
							<xsl:text> </xsl:text>
							<xsl:value-of select="$fig-count-actual"/>
							<xsl:text>. </xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</span>
				<xsl:apply-templates select="*[contains(@class, ' topic/title ')]" mode="figtitle"/>
			</figcaption>
		</xsl:if>
	</xsl:template>

	<xsl:template name="topic-image">
		<xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
		<img>
			<xsl:call-template name="commonattributes">
				<xsl:with-param name="default-output-class">
					<xsl:if test="@placement = 'break'"><!--Align only works for break-->
						<xsl:choose>
							<xsl:when test="@align = 'left'">imageleft</xsl:when>
							<xsl:when test="@align = 'right'">imageright</xsl:when>
							<xsl:when test="@align = 'center'">imagecenter</xsl:when>
						</xsl:choose>
					</xsl:if>
					<xsl:if test="parent::*[contains(@class, ' topic/xref ') or contains(@class, ' topic/link ')]"> image-link</xsl:if>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="setid"/>
			<xsl:choose>
				<xsl:when test="*[contains(@class, ' topic/longdescref ')]">
					<xsl:apply-templates select="*[contains(@class, ' topic/longdescref ')]"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="@longdescref"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates select="@href|@height|@width"/>
			<xsl:apply-templates select="@scale"/>
			<xsl:choose>
				<xsl:when test="*[contains(@class, ' topic/alt ')]">
					<xsl:variable name="alt-content"><xsl:apply-templates select="*[contains(@class, ' topic/alt ')]" mode="text-only"/></xsl:variable>
					<xsl:attribute name="alt" select="normalize-space($alt-content)"/>
				</xsl:when>
				<xsl:when test="@alt">
					<xsl:attribute name="alt" select="@alt"/>
				</xsl:when>
			</xsl:choose>
		</img>
		<xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
	</xsl:template>
	<!-- Added anchor link for micro video Roopesh Nov 2019 -->
	<xsl:template match="*[contains(@class,' topic/object ')]" name="topic.object">
		<xsl:choose>
			<xsl:when test="contains(@outputclass, 'microvideo')">
				<p>
					<a>
					   <xsl:attribute name="href">
						<xsl:value-of select="@data"/>
					   </xsl:attribute>
					   <xsl:attribute name="target">_blank</xsl:attribute>
						<span><xsl:value-of select="@name"/></span>
					</a>
				</p>
			</xsl:when>
			<xsl:otherwise>
				<div class="iframeWrapper">
					<iframe>
						<xsl:copy-of
								select="@id | @declare | @codebase | @type | @archive | @height | @usemap | @tabindex | @classid | @data | @codetype | @standby | @width | @name"/>
						<xsl:apply-templates select="*"/>
						<xsl:attribute name="frameborder" select="'0'"/>
						<xsl:text> </xsl:text>
					</iframe>
				</div>
		</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*[contains(@class,' topic/param ')]" name="topic.param">
		<xsl:choose>
			<xsl:when test="@name='movie'">
				<xsl:attribute name="class" select="'video'"/>
				<xsl:choose>
					<xsl:when test="contains(@value,'watch?')">
						<xsl:variable name="firstPart">
							<xsl:value-of select="substring-after(@value,'watch?v=')"/>
						</xsl:variable>
						<xsl:attribute name="src">
							<xsl:copy-of select="concat('http://www.youtube.com/embed/',substring-before($firstPart,'&amp;'))"/>
						</xsl:attribute>
					</xsl:when>
					<xsl:when test="contains(@value,'?')">
						<xsl:variable name="firstPart">
							<xsl:value-of select="substring-after(substring-before(@value,'?'),'/v/')"/>
						</xsl:variable>
						<xsl:attribute name="src">
							<xsl:copy-of select="concat('http://www.youtube.com/embed/',$firstPart)"/>
						</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="src">
							<xsl:copy-of select="@value"/>
						</xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="{@name}">
					<xsl:copy-of select="@value"/>
				</xsl:attribute>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*[contains(@class, ' topic/ol ')]" name="topic.ol">
		<xsl:variable name="olcount" select="count(ancestor-or-self::*[contains(@class, ' topic/ol ')])"/>
		<xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
		<xsl:call-template name="setaname"/>
		<ol>
			<xsl:call-template name="commonattributes"/>
			<xsl:apply-templates select="@compact"/>
			<xsl:attribute name="class" select="if($olcount > 2) then ('level3') else concat('level', $olcount)"/>
			<xsl:choose>
				<xsl:when test="$olcount mod 3 = 1"/>
				<xsl:when test="$olcount mod 3 = 2"><xsl:attribute name="type">a</xsl:attribute></xsl:when>
				<xsl:otherwise><xsl:attribute name="type">i</xsl:attribute></xsl:otherwise>
			</xsl:choose>
			<xsl:call-template name="setid"/>
			<xsl:apply-templates/>
		</ol>
		<xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
	</xsl:template>

	<xsl:template match="*[contains(@class, ' topic/ul ')]" name="topic.ul">
		<xsl:variable name="ulcount" select="count(ancestor-or-self::*[contains(@class, ' topic/ul ')])"/>
		<xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
		<xsl:call-template name="setaname"/>
		<ul>
			<xsl:call-template name="commonattributes"/>
			<xsl:apply-templates select="@compact"/>
			<xsl:attribute name="class" select="if($ulcount > 2) then ('level3') else concat('level', $ulcount)"/>
			<xsl:call-template name="setid"/>
			<xsl:apply-templates/>
		</ul>
		<xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
	</xsl:template>

	<xsl:template match="*[contains(@class, ' topic/example ')][preceding-sibling::*[1][contains(@class, ' topic/example ')]]"
				  name="topic.example">
		<div class="example-folowing">
			<xsl:call-template name="commonattributes"/>
			<xsl:call-template name="gen-toc-id"/>
			<xsl:call-template name="setidaname"/>
			<xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
			<xsl:apply-templates select="." mode="dita2html:section-heading"/>
			<xsl:apply-templates select="*[not(contains(@class, ' topic/title '))] | text() | comment() | processing-instruction()"/>
			<xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
		</div>
	</xsl:template>

	<xsl:template match="*[contains(@class, ' topic/example ')]/*[contains(@class, ' topic/title ')]" priority="10">
		<xsl:param name="headLevel">
			<xsl:variable name="headCount" select="count(ancestor::*[contains(@class, ' topic/topic ')])+1"/>
			<xsl:choose>
				<xsl:when test="$headCount > 6">h6</xsl:when>
				<xsl:otherwise>h<xsl:value-of select="$headCount"/></xsl:otherwise>
			</xsl:choose>
		</xsl:param>

		<xsl:variable name="example-count-actual" select="count(../preceding::*[contains(@class,' topic/example ')]) + 1"/>

		<xsl:if test="not(ancestor::*[contains(@class, ' task/task ')])
                                or (ancestor::*[contains(@class, ' task/task ')] and $insert-task-labels)">
			<!-- IA   Tridion upgrade    Nov-2018   Add support for DELL 'task-label' othermeta parameter.
                        Do not add task labels ONLY if 'task-labels' <othermeta> value equal 'no'.  - IB-->
			<xsl:element name="{$headLevel}">
				<xsl:attribute name="class">tasklabel</xsl:attribute>
				<xsl:call-template name="commonattributes">
					<xsl:with-param name="default-output-class" select="'sectiontitle tasklabel'"/>
				</xsl:call-template>

				<span class="tasklabel">
					<xsl:call-template name="getDellString">
						<xsl:with-param name="dell-id" select="'task_example-dell'"/>
					</xsl:call-template>
					<xsl:text> </xsl:text>
					<xsl:value-of select="$example-count-actual"/>
					<xsl:text>. </xsl:text>
					<xsl:apply-templates/>
				</span>
			</xsl:element>
		</xsl:if>

	</xsl:template>
	
	<xsl:template match="*[contains(@class, ' topic/note ')]" name="topic.note">
		<xsl:choose>
			<xsl:when test="@type = 'notice'">
				<xsl:apply-templates select="." mode="process.note.notice"/>
			</xsl:when>
			<xsl:when test="@type = 'caution'">
				<xsl:apply-templates select="." mode="process.note.caution"/>
			</xsl:when>
			<xsl:when test="@type = 'danger'">
				<xsl:apply-templates select="." mode="process.note.danger"/>
			</xsl:when>
			<xsl:when test="@type = 'warning'">
				<xsl:apply-templates select="." mode="process.note.warning"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="." mode="process.note"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="process.note">
		<xsl:apply-templates select="." mode="process.note.common-processing.dell">
			<xsl:with-param name="type" select="'note'"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="*" mode="process.note.notice">
		<xsl:apply-templates select="." mode="process.note.common-processing.dell">
			<xsl:with-param name="type" select="'notice'"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="*" mode="process.note.caution">
		<xsl:apply-templates select="." mode="process.note.common-processing.dell">
			<xsl:with-param name="type" select="'caution'"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="*" mode="process.note.danger">
		<xsl:apply-templates select="." mode="process.note.common-processing.dell">
			<xsl:with-param name="type" select="'danger'"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="*" mode="process.note.warning">
		<xsl:apply-templates select="." mode="process.note.common-processing.dell">
			<xsl:with-param name="type" select="'warning'"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="*" mode="process.note.common-processing.dell">
		<xsl:param name="type" select="@type"/>

		<xsl:variable name="lang" select="ancestor-or-self::*[@xml:lang][1]/@xml:lang"/>

		<div class="{$type} admonition">
			<!-- IA   Tridion upgrade    Nov-2018   Add new admonitions view STARTS HERE. - IB-->
			<table>
				<tbody>
					<tr>
						<td>
							<div class="admonition-image-container">
								<xsl:call-template name="insertAdmonitionImage">
									<xsl:with-param name="type" select="$type"/>
								</xsl:call-template>
							</div>
						</td>
						<td>
							<div class="admonition-body">
								<xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-startprop ')]/revprop"
													 mode="ditaval-outputflag"/>
								<xsl:variable name="note-prefix">
									<xsl:call-template name="getVariable">
										<xsl:with-param name="id" select="concat($type, '-dell')"/>
									</xsl:call-template>
								</xsl:variable>
								<span class="{$type} admonition-label">
									<xsl:value-of select="upper-case($note-prefix)"/>
									<xsl:if test="not(contains($note-prefix, ':')) and not($lang = 'he')">
										<xsl:text>:</xsl:text>
									</xsl:if>
								</span>
								<span>&#xA0;</span>
								<xsl:apply-templates/>
								<xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
							</div>
						</td>
					</tr>
				</tbody>
			</table>
			<!-- IA   Tridion upgrade    Nov-2018   Add new admonitions view ENDS HERE. - IB-->
		</div>
	</xsl:template>

	<xsl:template name="insertAdmonitionImage">
		<xsl:param name="type"/>

		<xsl:variable name="image_name">
			<xsl:choose>
				<xsl:when test="$dell-brand = ('Alienware', 'Non-brand')">
					<xsl:choose>
						<xsl:when test="$type = ('caution', 'warning')">
							<xsl:value-of select="concat($type, '-black.svg')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="'note-black.svg'"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="$type = ('caution', 'warning')">
							<xsl:value-of select="concat($type, '.svg')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="'note.svg'"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="image_path" select="concat('oxygen-webhelp/template/resources/images/', $image_name)"/>

		<img class="admonition-image" src="{$image_path}" alt=""/>
	</xsl:template>

	<xsl:template match="*[contains(@class, ' topic/fn ') or (contains(@class, ' topic/xref ') and @type = 'fn')]" name="topic.fn">
		<xsl:param name="xref"/>
		<xsl:choose>
			<xsl:when test="ancestor::*[contains(@class, ' topic/table ') or contains(@class,' topic/simpletable ')]">
				<xsl:variable name="table">
					<xsl:copy-of select="ancestor::*[contains(@class, ' topic/table ') or contains(@class,' topic/simpletable ')][last()]"/>
				</xsl:variable>
				<xsl:call-template name="gen-table-footnote">
					<xsl:with-param name="table" select="$table"/>
					<xsl:with-param name="element" select="self::*"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="." mode="topic.fn"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*[contains(@class, ' topic/fn ') or (contains(@class, ' topic/xref ')and @type = 'fn')]
                            [not(ancestor::*[contains(@class, ' topic/table ')])]
                            [not(ancestor::*[contains(@class, ' topic/simpletable ')])]"
				  mode="topic.fn">
		<xsl:variable name="ref-id" select="substring-after(@href, '/')"/>
		<xsl:variable name="fn-number">
			<xsl:choose>
				<xsl:when test="contains(@class, ' topic/xref ')">
					<xsl:value-of select="count(/descendant::*[@id = $ref-id][1]/
                                            preceding::*[contains(@class, ' topic/fn ')]
                                                        [not(ancestor::*[contains(@class, ' topic/table ')])]
                                                        [not(ancestor::*[contains(@class,' topic/simpletable ')])]) + 1"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="count(preceding::*[contains(@class, ' topic/fn ')]
                                                        [not(ancestor::*[contains(@class, ' topic/table ')])]
                                                        [not(ancestor::*[contains(@class,' topic/simpletable ')])]) + 1"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="fnid">
			<xsl:number format="1" value="$fn-number"/>
		</xsl:variable>
		<xsl:variable name="ancestorId" select="ancestor::*[@id][not(@id = '')][1]/@id"/>
		<xsl:variable name="callout" select="@callout"/>
		<xsl:variable name="convergedcallout" select="if (string-length($callout)> 0) then $callout else $fnid"/>
		<a name="fnsrc_{$fnid}_{$ancestorId}" href="#fntarg_{$fnid}_{$ancestorId}">
			<sup>
				<xsl:value-of select="$convergedcallout"/>
			</sup>
		</a>
	</xsl:template>

	<xsl:template match="*[contains(@class, ' topic/xref ')][not(@type = 'fn')]" name="topic.xref">
		<xsl:variable name="preceding-text" select="preceding-sibling::text()[1]"/>
		<xsl:for-each select="preceding-sibling::*[1][contains(@class, ' topic/xref ')
                                    or contains(@class, ' topic/keyword ')
                                    or contains(@class, ' topic/ph ')]">
			<xsl:if test="(preceding-sibling::text()[1] = $preceding-text) or (not(matches($preceding-text, '^.*\s$')))">
				<xsl:text> </xsl:text>
			</xsl:if>
		</xsl:for-each>
		<xsl:choose>
			<xsl:when test="@href and normalize-space(@href)">
				<xsl:apply-templates select="." mode="add-xref-highlight-at-start"/>
				<a>
					<xsl:call-template name="commonattributes"/>
					<xsl:apply-templates select="." mode="add-linking-attributes"/>
					<xsl:apply-templates select="." mode="add-desc-as-hoverhelp"/>
					<!-- if there is text or sub element other than desc, apply templates to them
					otherwise, use the href as the value of link text. -->
					<xsl:choose>
						<xsl:when test="*[not(contains(@class, ' topic/desc '))] | text()">
							<xsl:apply-templates select="*[not(contains(@class, ' topic/desc '))] | text()"/>
							<!--use xref content-->
						</xsl:when>
						<xsl:when test="@keyref">
							<xsl:apply-templates select="$ditamap-doc/descendant::*[contains(@class, ' mapgroup-d/keydef ')][@keys = current()/@keyref][1]" mode="resolve-keyref"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="href"/><!--use href text-->
						</xsl:otherwise>
					</xsl:choose>
				</a>
				<xsl:apply-templates select="." mode="add-xref-highlight-at-end"/>
			</xsl:when>
			<xsl:otherwise>
				<span>
					<xsl:call-template name="commonattributes"/>
					<xsl:apply-templates select="." mode="add-desc-as-hoverhelp"/>
					<xsl:apply-templates select="*[not(contains(@class, ' topic/desc '))] | text() | comment() | processing-instruction()"/>
				</span>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*[not(contains(@class, ' topic/xref '))][not(contains(@class, ' topic/image '))][@keyref][not(normalize-space())][not(*)]" priority="10">
		<xsl:apply-templates select="$ditamap-doc/descendant::*[contains(@class, ' mapgroup-d/keydef ')][@keys = current()/@keyref][1]" mode="resolve-keyref"/>
	</xsl:template>

	<xsl:template match="*[contains(@class, ' mapgroup-d/keydef ')]" mode="resolve-keyref">
		<xsl:choose>
			<xsl:when test="normalize-space(@href)">
				<xsl:variable name="filename">
					<xsl:choose>
						<xsl:when test="contains(@href, '#')">
							<xsl:value-of select="substring-before(@href, '#')"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="@href"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="IDs" select="substring-after(@href, '#')"/>
				<xsl:variable name="elemId" select="if(contains($IDs, '/')) then(substring-after($IDs, '/')) else($IDs)"/>

				<xsl:variable name="sourceFileURI" select="concat('file:///',translate($TEMPDIR, '\', '/'), '/', $filename)"/>

				<xsl:if test="doc-available($sourceFileURI) and normalize-space($elemId)">
					<xsl:apply-templates select="document($sourceFileURI)/descendant::*[@id = $elemId][1]" mode="resolve-keyref"/>
				</xsl:if>
			</xsl:when>
			<xsl:when test="descendant::*[contains(@class, ' topic/keyword ')][normalize-space(.)]">
				<xsl:apply-templates select="descendant::*[contains(@class, ' topic/keyword ')][normalize-space(.)][1]/node()"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*" mode="resolve-keyref" priority="-1">
		<xsl:apply-templates select="."/>
	</xsl:template>

	<xsl:template match="*[*[contains(@class, ' topic/title ')]]" mode="resolve-keyref">
		<xsl:apply-templates select="*[contains(@class, ' topic/title ')]/node()"/>
	</xsl:template>

	<xsl:template name="gen-endnotes">
		<xsl:if test="/descendant::*[contains(@class, ' topic/fn ')] or /descendant::*[contains(@class, ' topic/xref ')][@type = 'fn']">
			<div class="endnotes">
				<!-- Skip any footnotes that are in draft elements when draft = no -->
				<xsl:apply-templates
						select="//*[contains(@class, ' topic/fn ')][not(ancestor::*[contains(@class, ' topic/table ')])]
                                    [not(ancestor::*[contains(@class,' topic/simpletable ')])]
                                    [not((ancestor-or-self::*[contains(@class, ' topic/draft-comment ')]
                                            or ancestor::*[contains(@class, ' topic/required-cleanup ')]) and $DRAFT = 'no')]"
						mode="genEndnote"/>
			</div>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*[contains(@class, ' topic/fn ')]
                        [not(ancestor::*[contains(@class, ' topic/table ')])]
                        [not(ancestor::*[contains(@class,' topic/simpletable ')])]"
				  mode="genEndnote">
		<div class="fn">
			<xsl:variable name="fnid">
				<xsl:number format="1"
							value="count(preceding::*[contains(@class, ' topic/fn ')]
                                    [not(ancestor::*[contains(@class,' topic/simpletable ')])]
                                    [not(ancestor::*[contains(@class, ' topic/table ')])]) + 1"/>
			</xsl:variable>
			<xsl:variable name="ancestorId" select="ancestor::*[@id][not(@id = '')][1]/@id"/>
			<xsl:variable name="callout" select="@callout"/>
			<xsl:variable name="convergedcallout" select="if (string-length($callout) > 0) then $callout else $fnid"/>

			<span id="fntarg_{$fnid}_{$ancestorId}">
				<xsl:value-of select="concat($convergedcallout, '. ')"/>
			</span>

			<xsl:apply-templates/>
		</div>
	</xsl:template>

	<xsl:template match="*[contains(@class, ' topic/cite ')]" name="topic.cite">
		<xsl:variable name="language" select="lower-case($LANGUAGE)"/>

		<xsl:variable name="className">
			<xsl:choose>
				<xsl:when test="matches($language, 'ja(-\w+)?') or
                                matches($language, 'zh-(tw|hant)') or
                                matches($language, 'zh(-\w+)?')">
					<xsl:value-of select="'no-italic'"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="'italic'"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="@keyref and @href">
				<xsl:apply-templates select="." mode="turning-to-link">
					<xsl:with-param name="type" select="'cite'"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<cite>
					<xsl:call-template name="commonattributes"/>
					<xsl:call-template name="setidaname"/>
					<xsl:attribute name="class" select="$className"/>
					<xsl:call-template name="getVariable">
						<xsl:with-param name="id" select="'start_cite'"/>
					</xsl:call-template>
					<xsl:apply-templates/>
					<xsl:call-template name="getVariable">
						<xsl:with-param name="id" select="'end_cite'"/>
					</xsl:call-template>
				</cite>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*[contains(@class, ' topic/q ')]" name="topic.q">
		<span class="q">
			<xsl:call-template name="getVariable">
				<xsl:with-param name="id" select="'start_q_responsive'"/>
			</xsl:call-template>
			<xsl:apply-templates/>
			<xsl:call-template name="getVariable">
				<xsl:with-param name="id" select="'end_q_responsive'"/>
			</xsl:call-template>
		</span>
	</xsl:template>

	<xsl:template match="*[contains(@class,' pr-d/option ')]" name="topic.pr-d.option" priority="10">
		<xsl:variable name="preceding-text" select="preceding-sibling::text()[1]"/>
		<xsl:for-each select="preceding-sibling::*[1][contains(@class, ' topic/xref ')
                                    or contains(@class, ' topic/keyword ')
                                    or contains(@class, ' topic/ph ')]">
			<xsl:if test="(preceding-sibling::text()[1] = $preceding-text) or (not(matches($preceding-text, '^.*\s$')))">
				<xsl:text> </xsl:text>
			</xsl:if>
		</xsl:for-each>
		<span>
			<xsl:call-template name="commonattributes">
				<xsl:with-param name="default-output-class" select="'option'"/>
			</xsl:call-template>
			<xsl:call-template name="setidaname"/>
			<xsl:call-template name="getVariable">
				<xsl:with-param name="id" select="'start_option_responsive'"/>
			</xsl:call-template>
			<xsl:apply-templates/>
			<xsl:call-template name="getVariable">
				<xsl:with-param name="id" select="'end_option_responsive'"/>
			</xsl:call-template>
		</span>
	</xsl:template>

	<xsl:template match="*[contains(@class, ' topic/li ')][*[1][contains(@class, ' ui-d/uicontrol ')]]/text()[1][normalize-space() = ''][following-sibling::*[1][contains(@class, ' ui-d/uicontrol ')]]" priority="10"/>

	<xsl:template match="*[contains(@class, ' topic/ph ')]" name="topic.ph">
		<xsl:variable name="language" select="lower-case($LANGUAGE)"/>

		<xsl:variable name="preceding-text" select="preceding-sibling::text()[1]"/>
		<xsl:variable name="uicontrolcount">
			<xsl:value-of select="count(parent::*/*[contains(@class,' ui-d/uicontrol ')])"/>
		</xsl:variable>

		<xsl:if test="$uicontrolcount &gt; 1">
			<xsl:choose>
				<xsl:when test="contains(@class, ' ui-d/uicontrol ') and parent::*[contains(@class,' ui-d/menucascade ')] and preceding-sibling::*[contains(@class, ' ui-d/uicontrol ')]">
					<xsl:variable name="className">
						<xsl:choose>
							<xsl:when test="matches($language, 'ja(-\w+)?')">
								<xsl:value-of select="'span'"/>
							</xsl:when>
							<xsl:when test="matches($language, 'zh(-\w+)?')">
								<xsl:value-of select="'span'"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="'span bold'"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<span class="{$className}">
						<xsl:text> > </xsl:text>
					</span>
				</xsl:when>
				<xsl:when test="preceding-sibling::*[1][contains(@class, ' topic/xref ')
                                    or contains(@class, ' topic/keyword ')
                                    or contains(@class, ' topic/ph ')]">
					<xsl:for-each select="preceding-sibling::*[1][contains(@class, ' topic/xref ')
                                    or contains(@class, ' topic/keyword ')
                                    or contains(@class, ' topic/ph ')]">
						<xsl:if test="(preceding-sibling::text()[1] = $preceding-text) or (not(matches($preceding-text, '^.*\s$')))">
							<xsl:text> </xsl:text>
						</xsl:if>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise/>
			</xsl:choose>
		</xsl:if>

		<xsl:choose>
			<xsl:when test="@keyref and @href">
				<xsl:apply-templates select="." mode="turning-to-link">
					<xsl:with-param name="type" select="'ph'"/>
				</xsl:apply-templates>
			</xsl:when>
			<xsl:when test="contains(@class,' hi-d/sup ')">
				<sup>
					<xsl:call-template name="commonattributes"/>
					<xsl:call-template name="setidaname"/>
					<xsl:apply-templates/>
				</sup>
			</xsl:when>
			<xsl:when test="contains(@class,' hi-d/sub ')">
				<sub>
					<xsl:call-template name="commonattributes"/>
					<xsl:call-template name="setidaname"/>
					<xsl:apply-templates/>
				</sub>
			</xsl:when>
			<xsl:when test="contains(@class, ' ui-d/uicontrol ')">
				<xsl:variable name="className">
					<xsl:choose>
						<xsl:when test="matches($language, 'ja(-\w+)?')">
							<xsl:value-of select="'ph uicontrol'"/>
						</xsl:when>
						<xsl:when test="matches($language, 'zh(-\w+)?')">
							<xsl:value-of select="'ph uicontrol'"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="'ph uicontrol bold'"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<span class="{$className}">
					<!--<xsl:call-template name="commonattributes"/>-->
					<xsl:call-template name="setidaname"/>
					<xsl:call-template name="getVariable">
						<xsl:with-param name="id" select="'start_uicontrol_responsive'"/>
					</xsl:call-template>
					<xsl:apply-templates/>
					<xsl:call-template name="getVariable">
						<xsl:with-param name="id" select="'end_uicontrol_responsive'"/>
					</xsl:call-template>
				</span>
			</xsl:when>
			<xsl:otherwise>
				<span>
					<xsl:call-template name="commonattributes"/>
					<xsl:call-template name="setidaname"/>
					<xsl:apply-templates/>
				</span>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*[contains(@class,' pr-d/var ')]" name="topic.pr-d.var" priority="10">
		<xsl:call-template name="process-varnames">
			<xsl:with-param name="type" select="'var'"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="*[contains(@class,' sw-d/varname ')]" name="topic.sw-d.varname" priority="10">
		<xsl:call-template name="process-varnames">
			<xsl:with-param name="type" select="'varname'"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="process-varnames">
		<xsl:param name="type"/>

		<xsl:variable name="language" select="lower-case($LANGUAGE)"/>

		<xsl:variable name="className">
			<xsl:choose>
				<xsl:when test="matches($language, 'ja(-\w+)?')">
					<xsl:value-of select="concat($type, ' no-italic')"/>
				</xsl:when>
				<xsl:when test="matches($language, 'zh(-\w+)?')">
					<xsl:value-of select="concat($type, ' no-italic')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat($type, ' italic')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<var class="{$className}">
			<xsl:call-template name="getVariable">
				<xsl:with-param name="id" select="'start_var_responsive'"/>
			</xsl:call-template>
			<xsl:apply-templates/>
			<xsl:call-template name="getVariable">
				<xsl:with-param name="id" select="'end_var_responsive'"/>
			</xsl:call-template>
		</var>
	</xsl:template>

	<xsl:template match="*[contains(@class,' ui-d/wintitle ')]" name="topic.ui-d.wintitle" priority="10">
		<xsl:variable name="language" select="lower-case($LANGUAGE)"/>

		<xsl:variable name="preceding-text" select="preceding-sibling::text()[1]"/>
		<xsl:for-each select="preceding-sibling::*[1][contains(@class, ' topic/xref ')
                                    or contains(@class, ' topic/keyword ')
                                    or contains(@class, ' topic/ph ')]">
			<xsl:if test="(preceding-sibling::text()[1] = $preceding-text) or (not(matches($preceding-text, '^.*\s$')))">
				<xsl:text> </xsl:text>
			</xsl:if>
		</xsl:for-each>

		<xsl:variable name="className">
			<xsl:choose>
				<xsl:when test="matches($language, 'zh(-\w+)?')">
					<xsl:value-of select="'wintitle'"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="'wintitle bold'"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<span class="{$className}">
			<xsl:call-template name="getVariable">
				<xsl:with-param name="id" select="'start_wintitle_responsive'"/>
			</xsl:call-template>
			<xsl:apply-templates/>
			<xsl:call-template name="getVariable">
				<xsl:with-param name="id" select="'end_wintitle_responsive'"/>
			</xsl:call-template>
		</span>
	</xsl:template>

	<xsl:include href="plugin:org.dita.html5:xsl/css-class.xsl"/>

	<xsl:template match="*[contains(@class, ' topic/draft-comment ')]" mode="default-draft-comment-style">
		<xsl:call-template name="style">
			<xsl:with-param name="contents">background-color: #99FF99; border: 1pt #63d663 solid; padding: 4px;</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="*[contains(@class, ' topic/draft-comment ')]" name="topic.draft-comment">
		<xsl:if test="($DRAFT = 'yes') or ($include-draft-comments = 'yes')">
			<xsl:apply-templates select="." mode="ditamsg:draft-comment-in-content"/>
			<div>
				<xsl:call-template name="commonattributes"/>
				<xsl:apply-templates select="." mode="default-draft-comment-style"/>
				<xsl:call-template name="setidaname"/>
				<strong><xsl:call-template name="getVariable">
					<xsl:with-param name="id" select="'Draft comment'"/>
				</xsl:call-template>
					<xsl:call-template name="getVariable">
						<xsl:with-param name="id" select="'ColonSymbol'"/>
					</xsl:call-template><xsl:text> </xsl:text></strong>
				<xsl:if test="@author"><xsl:value-of select="@author"/><xsl:text> </xsl:text></xsl:if>
				<xsl:if test="@disposition"><xsl:value-of select="@disposition"/><xsl:text> </xsl:text></xsl:if>
				<xsl:if test="@time"><xsl:value-of select="@time"/></xsl:if>
				<br/>
				<xsl:apply-templates/>
			</div>
		</xsl:if>
	</xsl:template>

<!--
	<xsl:template match="*[contains(@class, ' topic/desc ')]">
		<xsl:apply-templates/>
	</xsl:template>
-->
<!--
	<xsl:template match="*" name="topic.undefined_element">
		<xsl:call-template name="output-message">
			<xsl:with-param name="id" select="'DOTX074W'"/>
			<xsl:with-param name="msgparams">%1=<xsl:value-of select="@class"/></xsl:with-param>
		</xsl:call-template>
		<xsl:if test="contains(@class, ' topic/desc ')">
			<xsl:message>
				<xsl:copy-of select="."/>
			</xsl:message>
		</xsl:if>
		<span class="undefined_element">
			<xsl:apply-templates/>
		</span>
	</xsl:template>
-->

</xsl:stylesheet>