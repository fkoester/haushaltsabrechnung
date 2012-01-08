<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
	<xsl:import href="common.xsl"/>
	<xsl:output method="html" indent="yes" />

	<!-- Abschnitt für das Menü  -->
	<xsl:template match="/">
		<xsl:call-template name="common">
			<xsl:with-param name="active-section">messages</xsl:with-param>
			<xsl:with-param name="active-action">list-messages</xsl:with-param>
			<xsl:with-param name="title">Nachrichten</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- zentraler Bereich  -->
	<xsl:template match="messages">
		<article>
			<h2>Nachrichten lesen</h2>
			<ul>
				<xsl:apply-templates select="message"/>
			</ul>
		</article>
	</xsl:template>
	
	<xsl:template match="message">
		<li>
			<a href="read_message.xql?id={@id}" title="Nachricht lesen"><xsl:value-of select="subject"/></a><br />
			<span>Datum: <xsl:value-of select="creation-timestamp"/></span><br />
			<span>Absender: <xsl:value-of select="/parameters/environment/group-members/user[@id = current()/sender/@id]/display-name" /></span>
		</li>
	</xsl:template>
	
</xsl:stylesheet>
