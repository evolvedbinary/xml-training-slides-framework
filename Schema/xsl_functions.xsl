<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:slide="https://schema.expertml.com/training-slides" 
  exclude-result-prefixes="xs"
  version="2.0">
  
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
  
</xsl:stylesheet>