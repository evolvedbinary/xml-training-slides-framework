<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron"
  xmlns:slide="https://schema.expertml.com/training-slides"  queryBinding="xslt2"
  xmlns:sqf="http://www.schematron-quickfix.com/validator/process">
  
  <sch:ns uri="https://schema.expertml.com/training-slides" prefix="slide"/>
  
  <sch:pattern>
  
    <sch:rule context="*:slide|*:title|*:code[namespace-uri() ne 'http://www.w3.org/1999/xhtml']">
      <sch:assert id="SlideNS" test="prefix-from-QName(node-name(.)) eq 'slide'" role="warning" sqf:fix="fixSlideNS">Prefer the 'slide' prefix</sch:assert>  
    </sch:rule>
  
  </sch:pattern>
  
  <sch:pattern id="abstracts">
    
  </sch:pattern>
  
  <sqf:fixes>
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
  
</sch:schema>