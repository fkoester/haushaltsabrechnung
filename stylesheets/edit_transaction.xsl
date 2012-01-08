<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
	<xsl:import href="common.xsl"/>
	<xsl:import href="transaction_fieldsets.xsl" />
	<xsl:output method="html" indent="yes" />

	<!-- Abschnitt für das Menü  -->
	<xsl:template match="/">
		<xsl:call-template name="common">
			<xsl:with-param name="active-section">transaction</xsl:with-param>
			<xsl:with-param name="active-action">edit-transaction</xsl:with-param>
			<xsl:with-param name="title">Kosten bearbeiten</xsl:with-param>
			<xsl:with-param name="scripts">js/3rdparty/jquery-1.6.min.js,js/3rdparty/jquery-ui-1.8.14.custom.min.js,js/arithmetic.js,js/datepicker.js,js/3rdparty/jquery.transform.js,js/create-transaction-form.js,js/3rdparty/jquery.ui.datepicker-de.js</xsl:with-param>
			<xsl:with-param name="stylesheets">css/3rdparty/ui-lightness/jquery-ui-1.8.14.custom.css</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="sub-transaction-count">
		<!-- Do nothing -->
	</xsl:template>

	<!-- zentraler Bereich  -->
	<xsl:template match="transaction">
		<article>
			<h2>Ausgaben bearbeiten</h2>
			<form action="transaction.xql" method="post" id="transaction-form" class="table-form" accept-charset="utf-8" enctype="multipart/form-data">
				<xsl:call-template name="transaction-fieldsets" />
				<xsl:call-template name="state-input" />
				<input type="hidden" name="operation" value="edit" />
				<input type="hidden" name="id" value="{@id}" />
				<input class="green awesome submit" type="submit" value="Änderungen speichern" />
			</form>
		</article>
	</xsl:template>
</xsl:stylesheet>
