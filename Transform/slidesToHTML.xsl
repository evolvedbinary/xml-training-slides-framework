<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:slide="https://schema.expertml.com/training-slides"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:math="http://www.w3.org/2005/xpath-functions/math"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:err="http://www.w3.org/2005/xqt-errors"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns="http://www.w3.org/1999/xhtml"
  xpath-default-namespace="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> Jul 8, 2020</xd:p>
      <xd:p><xd:b>Author:</xd:b> TFJH</xd:p>
      <xd:p>This stylesheet takes eXpertML course and slide definitions and produces a flat presentation file, suitable for use with e.g. Deck.js</xd:p>
      <xd:p>Class names should be extended using CSS/SASS (or similar).</xd:p>
    </xd:desc>
    <xd:param name="css-file-name">User defined CSS file</xd:param>
  </xd:doc>
  
  <xsl:param name="css-file-name" select="(/slide:course/slide:settings/slide:css/@filename, 'expertml.css')[1]"/>
	<xsl:param name="logo" select="(/slide:course/slide:settings/slide:logo/@href, 'images/logo.png')[1]"/>
  <xsl:param name="code-line-numbers" select="false()" as="xs:boolean"/>
  
  <xsl:variable name="quot"><![CDATA["]]></xsl:variable>
  <xsl:variable name="apos"><![CDATA[']]></xsl:variable>
  
  <xsl:output method="xhtml" html-version="5" indent="true" name="html"/>
  
  <xsl:mode name="slide:html" on-no-match="shallow-copy"/>
  <xsl:mode name="slide:flatten" on-no-match="shallow-copy" warning-on-no-match="false"/>
  <xsl:mode name="slide:title" on-no-match="shallow-skip" warning-on-no-match="false"/>
  <xsl:mode name="slide:code" on-no-match="text-only-copy" on-multiple-match="use-last" warning-on-multiple-match="false" warning-on-no-match="false"/>
  <xsl:mode on-no-match="shallow-skip" on-multiple-match="fail"/>
  
  <!-- Accumulators -->
  
  <xd:doc>
    <xd:desc>Topic accumulators collects topic slugs for prequisite checks</xd:desc>
  </xd:doc>
  <xsl:accumulator name="topics" as="xs:string*" initial-value="()">
    <xsl:accumulator-rule match="*[@topic]" select="($value, tokenize(@topic)) => distinct-values()"/>
    <xsl:accumulator-rule match="*[@assumed]" select="($value, tokenize(@assumed)) => distinct-values()"/>
  </xsl:accumulator>
  
  <!-- Default Mode -->
  
  <xd:doc>
    <xd:desc>Default mode is only used to flatten then split the course</xd:desc>
  </xd:doc>
  <xsl:template match="/slide:*">
    <xsl:variable name="flattened">
      <xsl:apply-templates select="." mode="slide:flatten"/>
    </xsl:variable>
    <xsl:apply-templates select="$flattened" mode="slide:html"/>
  </xsl:template>
  
  <!-- Flatten Mode: produces flattened course XML; necessary for prerequisite processing -->
  
  <xd:doc>
    <xd:desc>include slide:ref references</xd:desc>
  </xd:doc>
  <xsl:template match="slide:ref" mode="slide:flatten">
    <xsl:variable name="href" select="resolve-uri(@href, base-uri(.))"/>
    <xsl:try>
      <xsl:apply-templates select="doc($href)" mode="#current"/>
      <xsl:catch>
        <xsl:comment expand-text="true">Missing slides: {$href}</xsl:comment>
        <xsl:message expand-text="true">ERROR: processing {$href}.</xsl:message>
        <xsl:message expand-text="true">{$err:code}: {$err:description}</xsl:message>
      </xsl:catch>
    </xsl:try>
  </xsl:template>
  
  <!-- Title mode -->
  
  <xd:doc>
    <xd:desc>Find candidates to be the page title</xd:desc>
  </xd:doc>
  <xsl:template match="slide:courseName|slide:title[not(h1)]|slide:title/h1" mode="slide:title">
    <!-- Normally we'd frown on the use of xsl:value-of rather than xsl:sequence, but we specifically want the value as a single xs:string -->
    <xsl:value-of select="."/>
  </xsl:template>
  
  <!-- html mode -->
  
  <xd:doc>
    <xd:desc>Default handling of html elements is to copy without namespaces</xd:desc>
  </xd:doc>
  <xsl:template match="html:*" mode="slide:html">
    <xsl:copy copy-namespaces="false">
      <xsl:apply-templates select="@*|node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Default slide:* handling is to simply recurse</xd:desc>
  </xd:doc>
  <xsl:template match="slide:*" mode="slide:html">
    <xsl:apply-templates mode="slide:html"/>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Add topic check for slide sets</xd:desc>
  </xd:doc>
  <xsl:template match="slide:set|slide:course" mode="slide:html">
    <xsl:call-template name="slide:topic-check"/>
    <xsl:next-match/>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Creates slides from slide:slide</xd:desc>
  </xd:doc>
  <xsl:template match="slide:slide" mode="slide:html">
    <article class="slide" id="{(@xml:id, @id, generate-id())[1]}">
      <xsl:apply-templates mode="#current"/>
    </article>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Create course introduction</xd:desc>
  </xd:doc>
  <xsl:template match="slide:courseIntro" mode="slide:html" expand-text="true">
    <!-- Cover slide -->
    <article class="slide" id="front_cover">
      <xsl:apply-templates select="slide:courseName, slide:audience, slide:date" mode="#current"/>
      <p class="footnote" style="vertical-align: bottom; text-align: left">Slides copyright © eXpertML Ltd {year-from-date(current-date())}</p>
    </article>
    <!-- Trainer Info -->
    <xsl:apply-templates select="slide:trainerInfo" mode="#current"/>
    <!-- Other slides -->
    <xsl:apply-templates select="slide:ref|slide:slide|slide:set" mode="#current"/>
    <!-- Build course Overview -->
    <xsl:apply-templates select="slide:overview" mode="#current"/>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Create course title from courseName</xd:desc>
  </xd:doc>
  <xsl:template match="slide:courseName" mode="slide:html">
    <h1><xsl:apply-templates mode="#current"/></h1>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Create course audience</xd:desc>
  </xd:doc>
  <xsl:template match="slide:audience" mode="slide:html">
    <p><xsl:apply-templates mode="#current"/></p>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Create course date</xd:desc>
  </xd:doc>
  <xsl:template match="slide:date[@start]" mode="slide:html" expand-text="true">
    <p>{format-date(@start, '[FNn] [D1o] [MNn] [Y0001]')}</p>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Create course date (from current date)</xd:desc>
  </xd:doc>
  <xsl:template match="slide:date[not(@start)]" mode="slide:html" expand-text="true">
    <p>{format-date(current-date(), '[FNn] [D1o] [MNn] [Y0001]')}</p>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Create title slides</xd:desc>
  </xd:doc>
  <xsl:template match="slide:title[not(h1)]" mode="slide:html">
    <article class="slide">
      <h1><xsl:apply-templates mode="#current"/></h1>
    </article>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Standardise all titles on slides as h2; we can keep the heading levels for the ToC</xd:desc>
  </xd:doc>
  <xsl:template match="(h1|h2|h3|h4|h5|h6)[parent::slide:slide and not(preceding-sibling::*)]" mode="slide:html">
    <h2>
      <xsl:apply-templates select="@*|node()" mode="#current"/>
    </h2>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Create code blocks; escape all markup</xd:desc>
  </xd:doc>
  <xsl:template match="slide:code" mode="slide:html">
    <pre>
      <xsl:if test="matches(@class, '\sdata-start--?\d+')">
        <xsl:attribute name="data-start" select="replace(@class, '.*?\sdata-start-(-?\d+).*', '$1')"/>
      </xsl:if>
      <xsl:call-template name="slide:codeClass"/>
      <code contenteditable="">
        <xsl:apply-templates select="node()" mode="slide:code"/>
      </code>
    </pre>
  </xsl:template>
    
  <xd:doc>
    <xd:desc>Create Course sub-pages</xd:desc>
  </xd:doc>
  <xsl:template match="slide:course[slide:settings/slide:webpage/@filename ne 'index.html']" mode="slide:html">
    <xsl:variable name="href" select="slide:settings/slide:webpage/@filename"/>
    <xsl:call-template name="slide:sub-page">
      <xsl:with-param name="href" select="$href"/>
    </xsl:call-template>
    <xsl:result-document href="{$href}" format="html">
      <xsl:call-template name="slide:makePage"/>
    </xsl:result-document>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Create Session sub-pages</xd:desc>
  </xd:doc>
  <xsl:template match="slide:session" mode="slide:html">
    <xsl:variable name="href" select="@filename"/>
    <xsl:call-template name="slide:sub-page">
      <xsl:with-param name="href" select="$href"/>
    </xsl:call-template>
    <xsl:result-document href="{$href}" format="html">
      <xsl:call-template name="slide:makePage"/>      
    </xsl:result-document>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Create main page</xd:desc>
  </xd:doc>
  <xsl:template match="/*" mode="slide:html">
    <xsl:call-template name="slide:makePage"/>
  </xsl:template>
  
  <!-- code mode -->
  
  <xd:doc>
    <xd:desc>Add syntax highlighting for languages: this will only work if there is a prism language definition for "'language-'{@type}"</xd:desc>
  </xd:doc>
  <xsl:template match="slide:code/@type" mode="slide:code">
    <xsl:text expand-text="true">language-{.}</xsl:text>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Add syntax highlighting for markup languages in code</xd:desc>
  </xd:doc>
  <xsl:template match="slide:code/@type[. = ('xml', 'xhtml', 'xslt', 'xsl')]" mode="slide:code">
    <xsl:text>language-markup</xsl:text>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>No XPath syntax highlighting available, so use xquery instead</xd:desc>
  </xd:doc>
  <xsl:template match="slide:code/@type[. = ('xpath')]" mode="slide:code">
    <xsl:text>language-xquery</xsl:text>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Escape comment characters in code blocks</xd:desc>
  </xd:doc>
  <xsl:template match="comment()" mode="slide:code">
    <xsl:text><![CDATA[<!--]]></xsl:text>
    <xsl:value-of select="."/>
    <xsl:text><![CDATA[-->]]></xsl:text>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Escape attribute values in code blocks</xd:desc>
  </xd:doc>
  <xsl:template match="@*" mode="slide:code">
    <xsl:text> </xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:text>=</xsl:text>
    <xsl:choose expand-text="true">
      <xsl:when test="matches(., '^[^'||$quot||$apos||']'||$quot||'.*'||$quot)">
        <xsl:text>'</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>'</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>"</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>"</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Escape element names in code blocks</xd:desc>
  </xd:doc>
  <xsl:template match="*" mode="slide:code">
    <xsl:text>&lt;</xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:apply-templates select="@*" mode="#current"/>
    <xsl:choose>
      <xsl:when test="child::node()[not(self::text()[normalize-space() eq ''])]">
        <xsl:text>></xsl:text>
        <xsl:apply-templates select="node()" mode="#current"/>
        <xsl:text>&lt;/</xsl:text>
        <xsl:value-of select="name()"/>
        <xsl:text>></xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>/></xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
    
  <!-- Named Templates -->
  
  <xd:doc>
    <xd:desc>Adds a slide to link to another slide webpage</xd:desc>
    <xd:param name="href">The URI of the webpage</xd:param>
  </xd:doc>
  <xsl:template name="slide:sub-page" expand-text="true">
    <xsl:param name="href" as="xs:anyURI"/>
    <xsl:variable name="titles" as="xs:string*">
      <xsl:apply-templates mode="slide:title"/>
    </xsl:variable>
    <article class="slide">
      <h2><xsl:sequence select="$titles[1]"/></h2>
      <p><a href="{$href}">Click here to open {$titles[1]} slides.</a></p>
    </article>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Adds various classes to code blocks e.g. for syntax highlighting and code numbering</xd:desc>
  </xd:doc>
  <xsl:template name="slide:codeClass">
    <xsl:variable name="lineNumbers" as="xs:string?">
      <xsl:if test="$code-line-numbers and not(slide:contains(@class, 'no-line-numbers'))">
        <xsl:text>line-numbers</xsl:text>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="language" as="xs:string?">
      <xsl:apply-templates select="@type" mode="slide:code"/>
    </xsl:variable>
    <xsl:attribute name="class" select="slide:addToken(($lineNumbers, ($language, 'language-none')[1]), @class)"/>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Checks topic prerequisites and outputs warnings as appropriate</xd:desc>
  </xd:doc>
  <xsl:template name="slide:topic-check">
    <xsl:variable name="prereqs" select="tokenize(@prerequisites)" as="xs:string*"/>
    <xsl:variable name="topics" select="accumulator-before('topics')"/>
    <xsl:if test="not(every $prereq in $prereqs satisfies $prereq = $topics)">
      <xsl:message expand-text="true">Topic {@topic} has missing prerequisite(s): {$prereqs[not(. = $topics)] => string-join(', ')}</xsl:message>
    </xsl:if>
  </xsl:template>
      
  <xd:doc>
    <xd:desc>Create HTML outer elements structure; actual processing is done in the html mode.</xd:desc>
  </xd:doc>
  <xsl:template name="slide:makePage">
    <html xmlns="http://www.w3.org/1999/xhtml">
			<head>
				<meta name="viewport" content="width=1024, user-scalable=no"/>

				<title>
					<!-- Find title from first available title: should either be the course title, or a title page on the slide.-->
					<xsl:variable name="titles" as="xs:string*">
						<xsl:apply-templates mode="slide:title"/>
					</xsl:variable>
					<xsl:sequence select="($titles[1], 'eXpertML Training (c) ' || year-from-date(current-date()))[1]"/>
				</title>

				<link href="http://fonts.googleapis.com/css?family=Inconsolata|Open+Sans:400italic,600italic,700italic,700,400;subset=latin,latin-ext" rel="stylesheet" type="text/css"/>

				<!-- Required stylesheet -->
				<link rel="stylesheet" href="core/deck.core.css"/>

				<!-- Extension CSS files go here. Remove or add as needed. -->
				<link rel="stylesheet" href="extensions/menu/deck.menu.css"/>
				<link rel="stylesheet" href="extensions/scale/deck.scale.css"/>

				<!-- Style theme. More available in /themes/style/ or create your own. -->
				<link rel="stylesheet" href="themes/style/{$css-file-name}"/>

				<!-- Transition theme. More available in /themes/transition/ or create your own. -->
				<link rel="stylesheet" href="themes/transition/horizontal-slide.css"/>



				<!-- Required Modernizr file -->
				<script src="modernizr.custom.js">&#160;</script>
			</head>
			<body>
				<div class="deck-container">
				  <xsl:next-match/>
				</div>

				<footer>
					<img src="{$logo}"/>

					<!-- Begin extension snippets. Add or remove as needed. -->


					<!-- deck.status snippet -->
					<p class="deck-status">
						<span class="deck-status-current"/> / <span class="deck-status-total"/>
					</p>



				</footer>
				<!-- End slides. -->



				<!-- End extension snippets. -->

				<!-- Required JS files. -->
				<script src="jquery.min.js"/>
				<script src="core/deck.core.js"/>

				<!-- Prism code highlighting -->
				<script>
        Prism.plugins.NormalizeWhitespace.setDefaults({
          'remove-trailing': true,
          'remove-indent': true,
          'left-trim': true,
          'right-trim': true,
          'remove-initial-line-feed': true,
          /*'break-lines': 80,
          'indent': 2,
          'tabs-to-spaces': 4,
          'spaces-to-tabs': 4*/
        });  
		  </script>
				<script src="prism.js"/>

				<!-- Extension JS files. Add or remove as needed. -->
				<script src="extensions/menu/deck.menu.js"/>
				<script src="extensions/goto/deck.goto.js"/>
				<script src="extensions/status/deck.status.js"/>
				<script src="extensions/navigation/deck.navigation.js"/>
				<script src="extensions/scale/deck.scale.js"/>

				<!-- Initialize the deck. You can put this in an external file if desired. -->
				<script>
				$(function() {
				$.deck('.slide');
				});
			</script>
			</body>
		</html>		
  </xsl:template>
  
  <!-- Functions -->
  <xd:doc>
    <xd:desc>Adds tokens to attributes</xd:desc>
    <xd:param name="token">The string to add to the list of tokens</xd:param>
    <xd:param name="attribute">The list of tokens, as a whitespace joined string</xd:param>
  </xd:doc>
  <xsl:function name="slide:addToken" as="xs:string">
    <xsl:param name="token" as="xs:string+"/>
    <xsl:param name="attribute" as="xs:string?"/>
    <xsl:value-of select="string-join(($token, tokenize($attribute, '\s')[not(. = $token)]), ' ')"/>
  </xsl:function>
  
  <xd:doc>
    <xd:desc>Simple convenience function for checking class contents via tokenization</xd:desc>
    <xd:param name="tokenList">The list of tokens to be checked against</xd:param>
    <xd:param name="tokens">The token(s) to be checked.</xd:param>
  </xd:doc>
  <xsl:function name="slide:contains" as="xs:boolean">
    <xsl:param name="tokenList" as="xs:string*"/>
    <xsl:param name="tokens" as="xs:string+"/>
    <xsl:variable name="value" as="xs:boolean" select="$tokenList!tokenize('\s') = $tokens"/>
  	<xsl:sequence select="$value"/>
  </xsl:function>
  
</xsl:stylesheet>