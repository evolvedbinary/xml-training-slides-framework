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
	<xsl:param name="html-file-name" select="(/slide:course/slide:settings/slide:webpage/@filename, 'index.html')[1]"></xsl:param>
  <xsl:param name="code-line-numbers" select="false()" as="xs:boolean"/>
  
  <xsl:variable name="quot"><![CDATA["]]></xsl:variable>
  <xsl:variable name="apos"><![CDATA[']]></xsl:variable>
  
  <xsl:output method="xhtml" html-version="5" indent="true" name="html"/>
  
  <xsl:mode name="html" on-no-match="shallow-copy"/>
  <xsl:mode name="title" on-no-match="shallow-skip" warning-on-no-match="false"/>
  <xsl:mode name="code" on-no-match="text-only-copy" on-multiple-match="use-last" warning-on-multiple-match="false" warning-on-no-match="false"/>
  <xsl:mode on-no-match="shallow-skip"/>
  
  <xd:doc>
  	<xd:desc></xd:desc>
  </xd:doc>
	
  <!-- title mode -->
  <xsl:mode name="title" on-no-match="shallow-skip"/>
  
  <xd:doc>
    <xd:desc>Find candidates to be the page title</xd:desc>
  </xd:doc>
  <xsl:template match="slide:courseName|slide:title[not(h1)]|slide:title/h1" mode="title">
    <!-- Normally we'd frown on the use of xsl:value-of rather than xsl:sequence, but we specifically want the value as a single xs:string -->
    <xsl:value-of select="."/>
  </xsl:template>
  
  <!-- html mode -->
  
  <xd:doc>
    <xd:desc>Creates slides from slide:slide</xd:desc>
  </xd:doc>
  <xsl:template match="slide:slide" mode="html">
    <article class="slide" id="{(@xml:id, @id, generate-id())[1]}">
      <xsl:apply-templates mode="#current"/>
    </article>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Create course introduction</xd:desc>
  </xd:doc>
  <xsl:template match="slide:courseIntro" mode="html">
    <!-- Cover slide -->
    <article class="slide" id="front_cover">
      <xsl:apply-templates select="slide:courseName, slide:audience, slide:date" mode="#current"/>
    </article>
    <!-- Trainer Info -->
    <xsl:apply-templates select="slide:trainerInfo" mode="#current"/>
    <!-- Other slides -->
    <xsl:apply-templates select="slide:ref|slide:slide|slide:set" mode="#current"/>
    <!-- Build course Overview -->
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Create course title from courseName</xd:desc>
  </xd:doc>
  <xsl:template match="slide:courseName" mode="html">
    <h1><xsl:apply-templates mode="#current"/></h1>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Create course audience</xd:desc>
  </xd:doc>
  <xsl:template match="slide:audience" mode="html">
    <p><xsl:apply-templates mode="#current"/></p>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Create course date</xd:desc>
  </xd:doc>
  <xsl:template match="slide:date" mode="html" expand-text="true">
    <p>{format-date(@start, '[FNn] [D1o] [MNn] [Y0001]')}</p>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Create title slides</xd:desc>
  </xd:doc>
  <xsl:template match="slide:title[not(h1)]" mode="html">
    <article class="slide">
      <h1><xsl:apply-templates mode="#current"/></h1>
    </article>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Standardise all titles on slides as h2; we can keep the heading levels for the ToC</xd:desc>
  </xd:doc>
  <xsl:template match="(h1|h2|h3|h4|h5|h6)[parent::slide:slide and not(preceding-sibling::*)]" mode="html">
    <h2>
      <xsl:apply-templates select="@*|node()" mode="#current"/>
    </h2>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Create code blocks; escape all markup</xd:desc>
  </xd:doc>
  <xsl:template match="slide:code" mode="html">
    <pre>
      <xsl:if test="matches(@class, '\sdata-start--?\d+')">
        <xsl:attribute name="data-start" select="replace(@class, '.*?\sdata-start-(-?\d+).*', '$1')"/>
      </xsl:if>
      <xsl:call-template name="slide:codeClass"/>
      <code contenteditable="">
        <xsl:apply-templates select="node()" mode="code"/>
      </code>
    </pre>
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
      <xsl:apply-templates select="@type" mode="code"/>
    </xsl:variable>
    <xsl:attribute name="class" select="slide:addToken(($lineNumbers, ($language, 'language-none')[1]), @class)"/>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Add syntax highlighting for languages: this will only work if there is a prism language definition for "'language-'{@type}"</xd:desc>
  </xd:doc>
  <xsl:template match="slide:code/@type" mode="code">
    <xsl:text expand-text="true">language-{.}</xsl:text>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Add syntax highlighting for markup languages in code</xd:desc>
  </xd:doc>
  <xsl:template match="slide:code/@type[. = ('xml', 'xhtml', 'xslt', 'xsl')]" mode="code">
    <xsl:text>language-markup</xsl:text>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>No XPath syntax highlighting available, so use xquery instead</xd:desc>
  </xd:doc>
  <xsl:template match="slide:code/@type[. = ('xpath')]" mode="code">
    <xsl:text>language-xquery</xsl:text>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Escape comment characters in code blocks</xd:desc>
  </xd:doc>
  <xsl:template match="comment()" mode="code">
    <xsl:text><![CDATA[<!--]]></xsl:text>
    <xsl:value-of select="."/>
    <xsl:text><![CDATA[-->]]></xsl:text>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Escape attribute values in code blocks</xd:desc>
  </xd:doc>
  <xsl:template match="@*" mode="code">
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
  <xsl:template match="*" mode="code">
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
  
  <xd:doc>
    <xd:desc>Default slide:* handling is to simply recurse</xd:desc>
  </xd:doc>
  <xsl:template match="slide:*" mode="html">
    <xsl:apply-templates mode="html"/>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>Default handling of html elements is to copy without namespaces</xd:desc>
  </xd:doc>
  <xsl:template match="html:*" mode="html">
    <xsl:copy copy-namespaces="false">
      <xsl:apply-templates select="@*|node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
	
	<!-- Mixed Modes -->
  
  <xd:doc>
    <xd:desc>Root elements need to create HTML outer elements; actual processing is done in the html mode.</xd:desc>
  </xd:doc>
  <xsl:template match="slide:course|slide:set" mode="#default">
		<html xmlns="http://www.w3.org/1999/xhtml">
			<head>
				<meta name="viewport" content="width=1024, user-scalable=no"/>

				<title>
					<!-- Find title from first available title: should either be the course title, or a title page on the slide.-->
					<xsl:variable name="titles" as="xs:string*">
						<xsl:apply-templates mode="title"/>
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
					<xsl:apply-templates mode="html"/>
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
  
  <xd:doc>
    <xd:desc>Create html structures for sub-pages</xd:desc>
  </xd:doc>
  <xsl:template match="(slide:course|slide:set)[$html-file-name ne 'index.html']" mode="html">
    <xsl:apply-templates select="." mode="#default"/>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>If the filename isn't index.html, we need to create one!</xd:desc>
  </xd:doc>
  <xsl:template match="(slide:course|slide:set)[$html-file-name ne 'index.html']" mode="#default html">
    <xsl:result-document href="{$html-file-name}" format="html">
      <xsl:next-match/>
    </xsl:result-document>
  </xsl:template>
  
  <xd:doc>
    <xd:desc>include slide:ref references</xd:desc>
  </xd:doc>
  <xsl:template match="slide:ref" mode="html overview">
    <xsl:try>
      <xsl:apply-templates select="doc(resolve-uri(@href, base-uri(.)))" mode="#current"/>
      <xsl:catch>
        <xsl:message expand-text="true">ERROR: processing {resolve-uri(@href, base-uri(.))}.</xsl:message>
        <xsl:message expand-text="true">{$err:code}: {$err:description}</xsl:message>
      </xsl:catch>
    </xsl:try>
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