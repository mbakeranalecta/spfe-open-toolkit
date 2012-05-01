<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
	xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions" 
	xmlns:ss="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/synthesis" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:config="http://spfeopentoolkit.org/spfe-ot/1.0/schemas/spfe-config"
	exclude-result-prefixes="#all"
	>
	
	<xsl:include href="http://spfeopentoolkit.org/spfe-ot/1.0/scripts/link-catalog/topic/topic-link-catalog.xsl"/> 
	
	<xsl:template match="schema-element">
		<target type="xml-element-name">
			<label><xsl:value-of select="name"/></label>
			<key><xsl:value-of select="xpath"/></key>
		</target>
		<target type="xpath">
			<label><xsl:value-of select="xpath"/></label>
			<key><xsl:value-of select="xpath"/></key>
		</target>
	</xsl:template>

</xsl:stylesheet>
