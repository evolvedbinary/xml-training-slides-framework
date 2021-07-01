<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:math="http://www.w3.org/2005/xpath-functions/math"
  xmlns:slide="https://schema.expertml.com/training-slides" 
  exclude-result-prefixes="#all"
  version="3.0">
  
  <xsl:import href="../Schema/xsl_functions.xsl"/>
  
  <xsl:preserve-space elements="*"/>
  
  <xsl:accumulator name="timings" as="xs:integer" initial-value="0">
    <xsl:accumulator-rule match="slide:set|slide:ref|slide:slide">
      <xsl:variable name="durations" as="xs:integer+">
        <xsl:apply-templates select="." mode="slide:getDurations"/>
      </xsl:variable>
      <xsl:sequence select="$value + sum($durations)"/>
    </xsl:accumulator-rule>
  </xsl:accumulator>
  
  <!-- Default mode: adds estimates to courses and sessions -->
  
  <xsl:mode on-no-match="shallow-copy" on-multiple-match="use-last" warning-on-multiple-match="false" warning-on-no-match="false" use-accumulators="#all"/>
  
  <xsl:template match="(slide:course | slide:session)">
    <xsl:variable name="timing"
      select="(accumulator-after('timings') - accumulator-before('timings')) => slide:get-duration-from-minutes()"
      as="xs:string"/>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:sequence>
        <xsl:apply-templates select="slide:courseIntro">
          <xsl:with-param name="timing" select="$timing"/>
        </xsl:apply-templates>
        <xsl:on-empty>
          <slide:courseIntro>
            <slide:estimated>
              <xsl:value-of select="$timing"/>
            </slide:estimated>
          </slide:courseIntro>
        </xsl:on-empty>
      </xsl:sequence>
      <xsl:apply-templates select="node() except slide:courseIntro"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="slide:courseIntro">
    <xsl:param name="timing" as="xs:string"/>
    <xsl:copy>
      <xsl:apply-templates select="node() except (slide:estimate)"/>
      <slide:estimated>
        <xsl:value-of select="$timing"/>
      </slide:estimated>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="text()|comment()|processing-instruction()">
    <xsl:copy-of select="."/>
  </xsl:template>
   
  
</xsl:stylesheet>