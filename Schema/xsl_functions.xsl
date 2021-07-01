<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:slide="https://schema.expertml.com/training-slides" 
  exclude-result-prefixes="xs"
  version="2.0">
  
  <xsl:param name="minsPerSlide" as="xs:integer" select="(/*/slide:settings/slide:minsPerSlide, 2)[1]"/>
  
  <xsl:function name="slide:is-duration" as="xs:boolean">
    <xsl:param name="duration" as="xs:string"/>
    <xsl:sequence select="matches(normalize-space($duration), '^(\d+h( \d{1,2}m)?|\d{1,2}m)$')"/>
  </xsl:function>
  
  <xsl:function name="slide:add-durations" as="xs:string">
    <xsl:param name="duration1" as="xs:string"/>
    <xsl:param name="duration2" as="xs:string"/>
    <xsl:variable name="d1" as="xs:integer" select="slide:get-minutes-from-duration($duration1)"/>
    <xsl:variable name="d2" as="xs:integer" select="slide:get-minutes-from-duration($duration2)"/>
    <xsl:variable name="total" as="xs:integer" select="$d1 + $d2"/>
    <xsl:sequence select="slide:get-duration-from-minutes($total)"/>
  </xsl:function>
  
  <xsl:function name="slide:get-minutes-from-duration" as="xs:integer">
    <xsl:param name="duration" as="xs:string"/>
    <xsl:if test="not(slide:is-duration($duration))">
      <xsl:message terminate="yes"><xsl:value-of select="$duration"/> is not a valid duration.</xsl:message>
    </xsl:if>
    <xsl:variable name="hours" select="xs:integer((replace($duration[matches(., 'h')], '^.*?(\d+)h.*$', '$1')[normalize-space(.) ne ''], '0')[1])" as="xs:integer"/>
    <xsl:variable name="minutes" select="xs:integer((replace($duration[matches(., 'm')], '^.*?(\d+)m.*$', '$1')[normalize-space(.) ne ''], '0')[1])" as="xs:integer"/>
    <xsl:sequence select="$minutes + ($hours * 60)"/>
  </xsl:function>
  
  <xsl:function name="slide:get-duration-from-minutes" as="xs:string">
    <xsl:param name="minutes" as="xs:integer"/>
    <xsl:variable name="hours" select="floor($minutes div 60)"/>
    <xsl:variable name="minutes" select="$minutes mod 60"/>
    <xsl:value-of select="concat($hours, 'h')[$hours ne 0], concat($minutes, 'm')[not($hours and $minutes eq 0)]" separator=" "/>
  </xsl:function>
  
  <xsl:function name="slide:get-duration-from-node" as="xs:string">
    <xsl:param name="node" as="node()+"/>
    <xsl:sequence select="slide:get-minutes-from-node($node) => slide:get-duration-from-minutes()"/>
  </xsl:function>
  
  <xsl:function name="slide:get-minutes-from-node" as="xs:integer">
    <xsl:param name="node" as="node()+"/>
    <xsl:variable name="minutes" as="xs:integer*">
      <xsl:apply-templates select="$node" mode="slide:getDurations"/>
    </xsl:variable>
    <xsl:sequence select="sum($minutes)"/>
  </xsl:function>
  
  <!-- slide:getDurations mode: retrieves durations from slides and slide sets -->
  
  <xsl:mode name="slide:getDurations" on-multiple-match="use-last" on-no-match="shallow-skip" warning-on-no-match="false" warning-on-multiple-match="false"/>
  
  <xsl:template mode="slide:getDurations" as="xs:integer*" match="slide:set">
    <xsl:apply-templates mode="#current" select="@duration"/>
    <xsl:on-empty>
      <xsl:apply-templates mode="#current"/>
    </xsl:on-empty>
  </xsl:template>
  
  <xsl:template mode="slide:getDurations" as="xs:integer?" match="slide:slide">
    <xsl:apply-templates mode="#current" select="@duration"/>
    <xsl:on-empty>
      <!-- Use a default timing per slide -->
      <xsl:sequence select="$minsPerSlide"/>
    </xsl:on-empty>
  </xsl:template>
  
  <xsl:template mode="slide:getDurations" as="xs:integer?" match="slide:title">
    <!-- Give ourselves a minute for each title slide -->
    <xsl:sequence select="1"/>
  </xsl:template>
  
  <xsl:template mode="slide:getDurations" as="xs:integer?" match="@duration">
    <xsl:sequence select="slide:get-minutes-from-duration(.)"/>
  </xsl:template>
  
  <xsl:template mode="slide:getDurations" as="xs:integer*" match="slide:ref">
    <xsl:apply-templates mode="#current" select="doc(resolve-uri(@href, base-uri(.)))"/>
  </xsl:template>
  
</xsl:stylesheet>