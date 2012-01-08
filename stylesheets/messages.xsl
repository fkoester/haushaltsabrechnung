<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ab-common="http://wob2.iai.uni-bonn.de/ab/common" version="2.0">
	<xsl:output method="html" indent="yes" />

	<xsl:template match="info">
		<section id="info" class="info-section">
			<xsl:choose>
				<xsl:when test="@type='error'">
					<div class="error"><xsl:value-of select="message" /></div>
				</xsl:when>
				<xsl:when test="@type='warning'">
					<div class="warning"><xsl:value-of select="message" /></div>
				</xsl:when>
				<xsl:when test="@type='success'">
					<div class="success"><xsl:value-of select="message" /></div>
				</xsl:when>
				<xsl:otherwise>
					<div class="info"><xsl:value-of select="message" /></div>
				</xsl:otherwise>
			</xsl:choose>
		</section>
	</xsl:template>

</xsl:stylesheet>
