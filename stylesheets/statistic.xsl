<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
	<xsl:import href="common.xsl"/>
	<xsl:import href="xosgr2svg.xsl"/>
	<xsl:output method="html" indent="yes" />

	<!-- Abschnitt für das Menü  -->
	<xsl:template match="/">
		<xsl:call-template name="common">
			<xsl:with-param name="active-section">statistic</xsl:with-param>
			<xsl:with-param name="active-action">show-statistic</xsl:with-param>
			<xsl:with-param name="title">Statistiken</xsl:with-param>
			<xsl:with-param name="scripts">js/3rdparty/jquery-1.6.min.js,js/3rdparty/jquery-ui-1.8.14.custom.min.js,js/arithmetic.js,js/datepicker.js,js/create-transaction-form.js,js/3rdparty/jquery.ui.datepicker-de.js</xsl:with-param>
			<xsl:with-param name="stylesheets">css/3rdparty/ui-lightness/jquery-ui-1.8.14.custom.css</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- Abschnitt für die Diagramme  -->
	<xsl:template match="charts">
		<h2>Hallo <xsl:value-of select="/parameters/environment/current-user/user/display-name" />!</h2>
		<div id="filter-panel">
			<form action="show-statistic.xql" method="post" id="filter-transaction-form">
				<fieldset class="no-legend" id="common-fields">
					<div id="filter">
					<input type="radio" name="filter-date" value="filter-date">
						<select id="month-field" name="month" title="Bitte wählen Sie einen Monat aus"  size="1">
							<option value="1">Januar</option>
							<option value="2">Februar</option>
							<option value="3">März</option>
							<option value="4">April</option>
							<option value="5">Mai</option>
							<option value="6">Juni</option>
							<option value="7">Juli</option>
							<option value="8">August</option>
							<option value="9">September</option>
							<option value="10">Oktober</option>
							<option value="11">November</option>
							<option value="12">Dezember</option>
						</select>
						<span> des Jahres</span>
						<input id="year-number-field" name="year" type="number" min="2000" max="2100" title="Bitte geben Sie ein Jahr ein"  maxlength="4" value="2011" />
					</input>
					<br />
					<input type="radio" name="filter-date" value="filter-date">
						Von <input id="filter-start-date" class="date " name="filter-start-date" title="Bitte geben Sie das Startdatum ein" type="date" />					
						bis <input id="filter-end-date" class="date " name="filter-end-date" title="Bitte geben Sie das Enddatum ein" type="date" />
					</input>
					<br />
					<xsl:call-template name="state-input" />
					</div>
					<br />
				<input type="submit" id="submit" />
				</fieldset>
			</form>
		</div>
		<section id="svg-overview" class="svg-section">
			<xsl:apply-templates/>
		</section>
	</xsl:template>
	
</xsl:stylesheet>
