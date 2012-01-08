<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ab-common="http://wob2.iai.uni-bonn.de/ab/common" version="2.0" exclude-result-prefixes="xsl ab-common">
	<xsl:output method="html" indent="yes" />

	<xsl:template match="environment" />

	<xsl:template match="/parameters/sub-transaction-index" />

	<xsl:template match="transaction-entry">
		<xsl:call-template name="sub-transaction-form" /> 
	</xsl:template>

	<xsl:template name="sub-transaction-form">
		<xsl:variable name="index">
			<xsl:choose>
				<xsl:when test="count(/parameters/sub-transaction-index) > 0">
					<xsl:value-of select="/parameters/sub-transaction-index" />
				</xsl:when>
				<xsl:when test="position() > 1">
					<xsl:value-of select="position() - 1" />
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<div class="sub-transaction-form">
			<xsl:attribute name="id">sub-transaction-form_<xsl:value-of select="$index" /></xsl:attribute>
			<div class="form-field">
				<label>
					<xsl:attribute name="for">sub-transaction-description_<xsl:value-of select="$index" /></xsl:attribute>
					<xsl:text>Beschreibung:</xsl:text>
				</label>
				<div id="field-input">
					<input type="text" size="40" placeholder="Beschreibung des Teileinkaufs" name="sub-transaction-description_{$index}" value="{description}" />
				</div>
			</div>
			<div class="form-field">
				<label>
					<xsl:attribute name="for">sub-transaction-amount_<xsl:value-of select="$index" /></xsl:attribute>
					<xsl:text>Kosten des Teileinkaufs:</xsl:text>
				</label>
				<div id="field-input">
					<input class="arithmetic" type="text" size="40" placeholder="Betrag des Teileinkaufs" name="sub-transaction-amount_{$index}" value="{amount}" />
					<span class="arithmetic-result result-field" />
				</div>
			</div>
			<xsl:apply-templates select="debtors" />
		</div>
	</xsl:template>

	<xsl:template match="debtors">
		<xsl:call-template name="group-members-selection" />
	</xsl:template>

	<xsl:template name="group-members-selection">
		<xsl:variable name="index">
			<xsl:choose>
				<xsl:when test="count(/parameters/sub-transaction-index) > 0">
					<xsl:value-of select="/parameters/sub-transaction-index" />
				</xsl:when>
				<xsl:when test="position() > 1">
					<xsl:value-of select="position() - 1" />
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="name-prefix">
			<xsl:if test="count(/parameters/sub-transaction-index) > 0 or position() > 1">
				<xsl:text>sub-transaction-</xsl:text>
			</xsl:if>
		</xsl:variable>
		<div class="form-field" id="{$name-prefix}group-members-field_{$index}">
			<xsl:attribute name="id">
				<xsl:value-of select="$name-prefix" />
				<xsl:text>group-members-field</xsl:text>
				<xsl:if test="$index != ''">
					<xsl:text>_</xsl:text>
					<xsl:value-of select="$index" />
				</xsl:if>
			</xsl:attribute>
			<xsl:variable name="debtors-fieldname">
				<xsl:value-of select="$name-prefix" />
				<xsl:text>debtors</xsl:text>
				<xsl:if test="$index != ''">
					<xsl:text>_</xsl:text>
					<xsl:value-of select="$index" />
				</xsl:if>
			</xsl:variable>
			<label for="{$debtors-fieldname}">Beteiligte Gruppenmitglieder:</label>
			<xsl:variable name="debtors" select="."/>
			<div id="field-input">
				<xsl:for-each select="/parameters/environment/group-members/user">
					<input type="checkbox" name="{$debtors-fieldname}" value="{@id}">
						<xsl:if test="$debtors/user/@id = @id">
							<xsl:attribute name="checked">checked</xsl:attribute>
						</xsl:if>
					</input>
					<xsl:value-of select="display-name" />
				</xsl:for-each>
			</div>
		</div>
	</xsl:template>
</xsl:stylesheet>
