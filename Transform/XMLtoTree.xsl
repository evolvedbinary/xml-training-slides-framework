<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:math="http://www.w3.org/2005/xpath-functions/math"
  xmlns:t="https://schema.expertml.com/svg/trees"
  xmlns="http://www.w3.org/2000/svg"
  exclude-result-prefixes="xs math t"
  version="3.0">
  
  <xsl:accumulator name="y-offset" initial-value="-3">
    <xsl:accumulator-rule match="*" phase="start" select="$value + 3"/>
    <xsl:accumulator-rule match="*" phase="end" select="$value + 1"/>
  </xsl:accumulator>
  
  <xsl:mode name="t:box" on-no-match="shallow-skip" use-accumulators="#all" on-multiple-match="use-last"/>
  
  <xsl:template match="*" mode="t:box">
    <xsl:param name="max-width" tunnel="yes" as="xs:integer"/>
    <xsl:variable name="depth" select="count(ancestor-or-self::*)" as="xs:integer"/>
    <xsl:variable name="width" select="$max-width - (2 * ($depth - 1))"/>
    <xsl:variable name="y-offset" select="accumulator-before('y-offset')"/>
    <xsl:variable name="height" select="2 + accumulator-after('y-offset') - accumulator-before('y-offset')"/>
    
    <rect x="{$depth - 1}em" y="{$y-offset}em" width="{$width}em" height="{$height}em" fill="white" stroke="black" stroke-width="2px"/>
    <text x="{$depth}em" y="{$y-offset + 2}em">
      <xsl:value-of select="name()"/>
    </text>
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="/*" mode="t:box">
    <xsl:variable name="max-width" select="max(descendant-or-self::* ! (string-length(name(.)) + 2*count(ancestor-or-self::*)))" as="xs:integer"/>
    <svg>
      <style type="text/css">text {font-family: Consolas, Monaco, "Andale Mono", "Ubuntu Mono", monospace;}</style>
      <xsl:next-match>
        <xsl:with-param tunnel="yes" name="max-width" select="$max-width"/>
      </xsl:next-match>
    </svg>
  </xsl:template>
  
  <xsl:mode name="t:vertical" on-no-match="shallow-skip" use-accumulators="#all" on-multiple-match="use-last"/>
  
  <xsl:template match="*" mode="t:vertical">
    <xsl:param name="docOrder" tunnel="yes"/>
    <xsl:param name="vertStart" select="(2 * (t:node-index-of($docOrder, ..) +1) ) + 0.2"/>
    <xsl:variable name="docOrderNumber" select="(t:node-index-of($docOrder, .) +1)"/>
    <xsl:variable name="baseline" select="2 * $docOrderNumber"/>
    <xsl:variable name="depth" select="count(ancestor-or-self::*)"/>
    <line class="structure" x1="{$depth}em" x2="{$depth}em" y1="{$vertStart}em" y2="{$baseline - 0.2}em"/>
    <line class="structure" x1="{$depth}em" x2="{$depth + 0.8}em" y1="{$baseline - 0.2}em" y2="{$baseline - 0.2}em"/>
    <text x="{1+$depth}em" y="{$baseline}em">
      <xsl:value-of select="name()"/>
    </text>
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="*[preceding-sibling::*]" mode="t:vertical">
    <xsl:param name="docOrder" tunnel="yes"/>
    <xsl:next-match>
      <xsl:with-param name="vertStart" select="(2 * ((t:node-index-of($docOrder, preceding-sibling::*[1])) + 1)) - 0.2"/>
    </xsl:next-match>
  </xsl:template>
  
  <xsl:template match="/*" name="treevert-start" mode="t:vertical">
    <xsl:variable name="docOrder" select="(./descendant-or-self::*)"/>
    <svg>
      <style type="text/css">
        text {font-family: Consolas, Monaco, "Andale Mono", "Ubuntu Mono", monospace;}
        .structure {
        stroke: black;
        stroke-width: 1.25px;
        }
      </style>
      <text x="1em" y="2em">/</text>
      <xsl:next-match>
        <xsl:with-param name="docOrder" tunnel="yes" select="$docOrder"/>
        <xsl:with-param name="vertStart" select="2.2"/>
      </xsl:next-match>
    </svg>
  </xsl:template>
  
  <xsl:function name="t:node-index-of" as="xs:integer*">
    <xsl:param name="sequence" as="node()*"/>
    <xsl:param name="item" as="node()?"/>
    <xsl:variable name="boolean_sequence" select="for $s in $sequence return $s is $item" as="xs:boolean*"/>
    <xsl:sequence select="index-of($boolean_sequence, true())"/>
  </xsl:function>
  
</xsl:stylesheet>