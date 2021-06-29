<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron"
  xmlns:slide="https://schema.expertml.com/training-slides" 
  xmlns:p="toReplace" queryBinding="xslt2"
  xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  >
  
  <sch:ns uri="https://schema.expertml.com/training-slides" prefix="slide"/>
  <sch:ns uri="toReplace" prefix="p"/>
  
  <!--<sch:phase id="all">
    <sch:active pattern="namedElements"/>
    <sch:active pattern="wildcardedElements"/>
  </sch:phase>-->
  
  <sch:pattern id="namedElements" >
    <sch:rule context="slide:slide/p:title">
      <sch:report test="true()" role="error" sqf:fix="h2-replace">Use heading levels for slide titles</sch:report>
    </sch:rule>
    <sch:rule context="slide:slide/slide:title">
      <sch:report test="true()" role="error" sqf:fix="h2-replace">Use heading levels for slide titles</sch:report>
    </sch:rule>
    <sch:rule context="slide:set/@duration">
      <sch:extends rule="durationFormat"/>
    </sch:rule>
    <sch:rule context="slide:estimate">
      <sch:extends rule="durationFormat"/>
    </sch:rule>
        
    <sch:rule abstract="true" id="durationFormat">
      <sch:assert test="slide:is-duration(.)" role="error">Duration must be in the format '1h 30m'.  Current duration is "<sch:value-of select="."/>"</sch:assert>
    </sch:rule>
  </sch:pattern>
  
  <sch:pattern id="wildcardedElements">
  
    <sch:rule context="p:*[not(self::title/parent::slide:slide)]">
      <sch:assert id="SlideNS" test="prefix-from-QName(node-name(.)) eq 'slide'" role="warning" sqf:fix="fixSlideNS">Prefer the 'slide' prefix</sch:assert>  
    </sch:rule>
  
  </sch:pattern>
  
  <sch:pattern id="abstracts">
    
  </sch:pattern>
  
  <sqf:fixes>
    <sqf:fix id="h2-replace">
      <sqf:description>
        <sqf:title>Replace element with h2</sqf:title>
      </sqf:description>
      <sqf:replace node-type="element" target="h2">
        <sqf:copy-of select="@*"/>
        <sqf:copy-of select="node()"/>
      </sqf:replace>
    </sqf:fix>
    <sqf:fix id="fixSlideNS">
      <sqf:description>
        <sqf:title>Replace namespace with slide:</sqf:title>
      </sqf:description>
      <sqf:replace node-type="element" target="slide:{local-name(.)}">
        <sqf:copy-of select="@*"/>
        <sqf:copy-of select="node()"/>
      </sqf:replace>
    </sqf:fix>
  </sqf:fixes>
  
  <xsl:include href="xsl_functions.xsl"/>
  
</sch:schema>