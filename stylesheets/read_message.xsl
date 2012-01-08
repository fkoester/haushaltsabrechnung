<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
	<xsl:import href="common.xsl"/>
	<xsl:output method="html" indent="yes" />

	<!-- Abschnitt für das Menü  -->
	<xsl:template match="/">
		<xsl:call-template name="common">
			<xsl:with-param name="active-section">messages</xsl:with-param>
			<xsl:with-param name="active-action">read-message</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<!-- Abschnitt für das den Inhalt  -->
	<xsl:template match="message">
		<article>
			<h3>Betreff</h3>
			<span><xsl:value-of select="subject" /></span><br />
			<h3>Nachricht</h3>
			<span><xsl:value-of select="content" /></span>
		</article>
	</xsl:template>
</xsl:stylesheet>
