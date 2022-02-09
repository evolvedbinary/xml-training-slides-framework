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
    
    <sch:rule context="@duration">
      <sch:extends rule="durationFormat"/>
      <sch:let name="claimed" value="slide:get-minutes-from-duration(.)"/>
      <sch:let name="calculated" value="slide:get-minutes-from-node((parent::slide:slide, ..[not(self::slide:slide)]/node()))"/>      
      <sch:report test="$calculated gt $claimed" role="error" sqf:fix="fixDuration">Duration is shorter than total of all slides!  Claimed duration: <sch:value-of select="$claimed"/>.  Calculated duration: <sch:value-of select="$calculated"/></sch:report>
      <sch:report test="$calculated lt $claimed" role="info" sqf:fix="fixDuration">Claimed duration: <sch:value-of select="$claimed"/>.  Calculated duration: <sch:value-of select="$calculated"/></sch:report>
    </sch:rule>
    
    <sch:rule context="slide:estimated">
      <sch:extends rule="durationFormat"/>
      <sch:let name="claimed" value="slide:get-minutes-from-duration(.)"/>
      <sch:let name="calculated" value="slide:get-minutes-from-node(../..)"/>
      <sch:report test="$calculated gt $claimed" role="error" sqf:fix="fixEstimate">Duration is shorter than total of all slides!  Claimed duration: <sch:value-of select="$claimed"/>.  Calculated duration: <sch:value-of select="$calculated"/></sch:report>
      <sch:report test="$calculated le $claimed" role="info" sqf:fix="fixEstimate">Claimed duration: <sch:value-of select="$claimed"/>.  Calculated duration: <sch:value-of select="$calculated"/></sch:report>
    </sch:rule>
    
    <sch:rule context="slide:set">
      <sch:extends rule="durationInfo"/>
    </sch:rule>
    
    <sch:rule context="slide:slide">
      <sch:extends rule="durationInfo"/>
    </sch:rule>
    
    <sch:rule context="slide:session">
      <sch:extends rule="estimatedInfo"/>
    </sch:rule>
    
    <sch:rule context="slide:course">
      <sch:extends rule="estimatedInfo"/>
    </sch:rule>
    
    <sch:rule context="slide:ref">
      <sch:extends rule="durationInfo"/>
    </sch:rule>
    
    <sch:rule context="slide:conref">
      <sch:assert test="key('ID', @ref, (.[@href]/doc(@href), /)[1])" role="error">slide:conref must refer to existing content.  Can't find <sch:value-of select="@ref"/><sch:value-of select="if (@href) then concat('in file: ', @href) else ()"/>.</sch:assert>
    </sch:rule>
    
    
    <!-- Abstracts -->
        
    <sch:rule abstract="true" id="durationFormat">
      <sch:assert test="slide:is-duration(.)" role="error" sqf:fix="fixEstimate fixDuration">Duration must be in the format '1h 30m'.  Current duration is "<sch:value-of select="."/>"</sch:assert>
    </sch:rule>
    <sch:rule abstract="true" id="durationInfo">
      <sch:assert test="@duration[slide:is-duration(.)]" role="info" sqf:fix="addDuration">Estimated duration: <sch:value-of select="slide:get-duration-from-node(.)"/>.</sch:assert>
    </sch:rule>
    <sch:rule abstract="true" id="estimatedInfo">
      <sch:assert test="slide:courseIntro/slide:estimated[slide:is-duration(.)]" role="info" sqf:fix="addEstimate">Estimated duration: <sch:value-of select="slide:get-duration-from-node(.)"/>.</sch:assert>
    </sch:rule>
    
  </sch:pattern>
  
  <sch:pattern id="wildcardedElements">
  
    <sch:rule context="p:*[not(self::title/parent::slide:slide)]">
      <sch:assert id="SlideNS" test="prefix-from-QName(node-name(.)) eq 'slide'" role="warning" sqf:fix="fixSlideNS">Prefer the 'slide' prefix</sch:assert>  
    </sch:rule>
  
  </sch:pattern>
    
  <sqf:fixes>
    <sqf:fix id="addEstimate">
      <sqf:description>
        <sqf:title>Adds a duration estimate using the calculated value</sqf:title>
      </sqf:description>
      <sqf:add match="slide:courseIntro" node-type="element" position="last-child" target="slide:estimated" select="slide:get-duration-from-node(..)"/>
    </sqf:fix>
    <sqf:fix id="fixEstimate">
      <sqf:description>
        <sqf:title>Replace a course/session estimate with its calculated value</sqf:title>
      </sqf:description>
      <sqf:replace node-type="element" target="slide:estimated">
        <sqf:copy-of select="@*"/>
        <sqf:copy-of select="slide:get-duration-from-node(../..)"/>
      </sqf:replace>
    </sqf:fix>
    <sqf:fix id="fixDuration">
      <sqf:description>
        <sqf:title>Replace a timing with its calculated value</sqf:title>
      </sqf:description>
      <sqf:replace node-type="attribute" target="duration" select="slide:get-duration-from-node(../node())"/>
    </sqf:fix>
    <sqf:fix id="addDuration">
      <sqf:description>
        <sqf:title>Add a duration from the calculated value</sqf:title>
      </sqf:description>
      <sqf:add match="." node-type="attribute" target="duration" select="slide:get-duration-from-node(.)"/>
    </sqf:fix>
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