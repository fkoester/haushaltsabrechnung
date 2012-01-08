<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ab-common="http://wob2.iai.uni-bonn.de/ab/common" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0" exclude-result-prefixes="ab-common xs xsl">
	<xsl:import href="messages.xsl" />
	<xsl:output method="html" indent="yes" />

	<xsl:decimal-format name="euro" decimal-separator="," grouping-separator="."/>

	<xsl:template name="common">
		<xsl:param name="active-section" />
		<xsl:param name="active-action" />
		<xsl:param name="title" />
		<xsl:param name="scripts" />
		<xsl:param name="stylesheets" />

		<html lang="de">
			<head>
				<meta charset="utf-8" />
				<title><xsl:value-of select="$title" /> | Haushaltsabrechnung</title>
				<link rel="stylesheet" href="css/main.css" type="text/css" />
				<xsl:for-each select="tokenize($stylesheets, ',')">
					<link rel="stylesheet" type="text/css">
						<xsl:attribute name="href"><xsl:value-of select="." /></xsl:attribute>
					</link>
				</xsl:for-each>
				<xsl:for-each select="tokenize($scripts, ',')">
					<script type="text/javascript">
						<xsl:attribute name="src"><xsl:value-of select="." /></xsl:attribute>
					</script>
				</xsl:for-each>
			</head>	
			<body>
				<header id="header">
					<h1>Haushaltsabrechnung</h1>
					<nav>
						<ul class="mainNav">
							<xsl:call-template name="section-link">
								<xsl:with-param name="target">overview.xql</xsl:with-param>
								<xsl:with-param name="label">Übersicht</xsl:with-param>
								<xsl:with-param name="active-section"><xsl:value-of select="$active-section" /></xsl:with-param>
								<xsl:with-param name="section">overview</xsl:with-param>
							</xsl:call-template>
							<xsl:call-template name="section-link">
								<xsl:with-param name="target">list_transactions.xql</xsl:with-param>
								<xsl:with-param name="label">Ausgaben</xsl:with-param>
								<xsl:with-param name="active-section"><xsl:value-of select="$active-section" /></xsl:with-param>
								<xsl:with-param name="section">transaction</xsl:with-param>
							</xsl:call-template>
							<li><a href="">Forderungen &amp; Transfers</a></li>
							<xsl:call-template name="section-link">
								<xsl:with-param name="target">list_messages.xql</xsl:with-param>
								<xsl:with-param name="label">Nachrichten</xsl:with-param>
								<xsl:with-param name="active-section"><xsl:value-of select="$active-section" /></xsl:with-param>
								<xsl:with-param name="section">messages</xsl:with-param>
							</xsl:call-template>
							<!--<xsl:call-template name="section-link">
								<xsl:with-param name="target">show-statistic.xql</xsl:with-param>
								<xsl:with-param name="label">Statistiken</xsl:with-param>
								<xsl:with-param name="active-section"><xsl:value-of select="$active-section" /></xsl:with-param>
								<xsl:with-param name="section">statistic</xsl:with-param>
							</xsl:call-template>-->
							<li><a href="">Statistiken</a></li>
							<li><a href="">Benutzer &amp; Gruppen</a></li>
							<li><a href="logout.xql">Logout</a></li>
						</ul>
					</nav>
					<xsl:if test="count(/parameters/environment/groups/group) > 1">
						<div id="group-selection-panel">
							<form>
								<select id="group-selection" name="current-group-id" size="1">
									<xsl:apply-templates select="/parameters/environment/groups" />
								</select>
								<input type="submit" class="awesome small" id="change-group-button" value="Gruppe wechseln" title="Klicken Sie hier um die auf die ausgewählte Gruppe zu wechseln"/>
							</form>
						</div>
					</xsl:if>
				</header>
				<aside>
					<ul class="sideNav">
						<xsl:if test="$active-section='transaction' or $active-section='overview'">
							<xsl:call-template name="action-link">
								<xsl:with-param name="target">transaction.xql</xsl:with-param>
								<xsl:with-param name="label">Ausgaben eintragen</xsl:with-param>
								<xsl:with-param name="active-action"><xsl:value-of select="$active-action" /></xsl:with-param>
								<xsl:with-param name="action">create-transaction</xsl:with-param>
							</xsl:call-template>
						</xsl:if>
						<xsl:if test="$active-section='transaction'">
							<xsl:call-template name="action-link">
								<xsl:with-param name="target">list_transactions.xql</xsl:with-param>
								<xsl:with-param name="label">Ausgabenübersicht</xsl:with-param>
								<xsl:with-param name="active-action"><xsl:value-of select="$active-action" /></xsl:with-param>
								<xsl:with-param name="action">list-transactions</xsl:with-param>
							</xsl:call-template>
						</xsl:if>
						<xsl:if test="$active-section='transaction'">
							<xsl:call-template name="action-link">
								<xsl:with-param name="target">list_standing_orders.xql</xsl:with-param>
								<xsl:with-param name="label">Daueraufträge auflisten</xsl:with-param>
								<xsl:with-param name="active-action"><xsl:value-of select="$active-action" /></xsl:with-param>
								<xsl:with-param name="action">list-standing-orders</xsl:with-param>
							</xsl:call-template>
						</xsl:if>
						<xsl:if test="$active-section='messages'">
							<xsl:call-template name="action-link">
								<xsl:with-param name="target">list_messages.xql</xsl:with-param>
								<xsl:with-param name="label">Nachrichten auflisten</xsl:with-param>
								<xsl:with-param name="active-action"><xsl:value-of select="$active-action" /></xsl:with-param>
								<xsl:with-param name="action">list-messages</xsl:with-param>
							</xsl:call-template>
						</xsl:if>
						<xsl:if test="$active-section='messages'">
							<xsl:call-template name="action-link">
								<xsl:with-param name="target">create_message.xql</xsl:with-param>
								<xsl:with-param name="label">Nachricht versenden</xsl:with-param>
								<xsl:with-param name="active-action"><xsl:value-of select="$active-action" /></xsl:with-param>
								<xsl:with-param name="action">create-message</xsl:with-param>
							</xsl:call-template>
						</xsl:if>
					</ul>
				</aside>
				<section id="content">
					<xsl:apply-templates />
				</section>
			</body>
		</html>
	</xsl:template>

	<xsl:template match="groups/group">
		<option>
			<xsl:attribute name="value"><xsl:value-of select="@id" /></xsl:attribute>
			<xsl:if test="@id = /parameters/environment/current-group/group/@id">
				<xsl:attribute name="selected">selected</xsl:attribute>
			</xsl:if>
			<xsl:value-of select="name" />
		</option>
	</xsl:template>

	<xsl:template name="section-link">
		<xsl:param name="target" />
		<xsl:param name="label" />
		<xsl:param name="section" />
		<xsl:param name="active-section" />
		<li>
			<a>
				<xsl:attribute name="href"><xsl:value-of select="$target" />?<xsl:value-of select="/parameters/environment/state-params" /></xsl:attribute>
				<xsl:if test="$active-section=$section"><xsl:attribute name="class">active</xsl:attribute></xsl:if>
				<xsl:value-of select="$label" />
			</a>
		</li>
	</xsl:template>

	<xsl:template name="action-link">
		<xsl:param name="target" />
		<xsl:param name="label" />
		<xsl:param name="action" />
		<xsl:param name="active-action" />
		<li>
			<a>
				<xsl:attribute name="href"><xsl:value-of select="$target" />?<xsl:value-of select="/parameters/environment/state-params" /></xsl:attribute>
				<xsl:if test="$active-action=$action"><xsl:attribute name="class">active</xsl:attribute></xsl:if>
				<xsl:value-of select="$label" />
			</a>
		</li>
	</xsl:template>

	<xsl:template name="link">
		<xsl:param name="target" />
		<xsl:param name="label" />
		<xsl:param name="class" />
		<xsl:param name="params" />
		<xsl:param name="tooltip" />
		<a>
			<xsl:attribute name="href"><xsl:value-of select="$target" />?<xsl:value-of select="/parameters/environment/state-params" />&amp;<xsl:value-of select="$params" /></xsl:attribute>
			<xsl:attribute name="title"><xsl:value-of select="$tooltip" /></xsl:attribute>
			<xsl:attribute name="class"><xsl:value-of select="$class" /></xsl:attribute>
			<span><xsl:value-of select="$label" /></span>
		</a>
	</xsl:template>

	<xsl:template name="state-input">
		<xsl:for-each select="/parameters/environment/state/property">
			<input type="hidden">
				<xsl:attribute name="name">
					<xsl:value-of select="name" />
				</xsl:attribute>
				<xsl:attribute name="value">
					<xsl:value-of select="value" />
				</xsl:attribute>
			</input>
		</xsl:for-each>
	</xsl:template>

	<xsl:function name="ab-common:format-amount">
		<xsl:param name="amount" />
		<xsl:text>€ </xsl:text><xsl:value-of select="format-number($amount, '#.##0,00', 'euro')" />
	</xsl:function>

	<xsl:function name="ab-common:format-interval">
		<xsl:param name="interval" />
		<xsl:choose>
			<xsl:when test="$interval = 'P1M'">Monatlich</xsl:when>
			<xsl:when test="$interval = 'P3M'">Quartalsweise</xsl:when>
			<xsl:when test="$interval = 'P7D'">Wöchentlich</xsl:when>
			<xsl:when test="$interval = 'P6M'">Halbjährlich</xsl:when>
			<xsl:when test="$interval = 'P12M'">Jährlich</xsl:when>
			<xsl:when test="ends-with($interval, 'D')"><xsl:value-of select="xs:integer(substring-before(substring-after($interval, 'P'),'D')) div 7" />-Wöchentlich</xsl:when>
			<xsl:when test="ends-with($interval, 'M')"><xsl:value-of select="xs:integer(substring-before(substring-after($interval, 'P'),'M'))" />-Monatlich</xsl:when>
			<xsl:otherwise><xsl:value-of select="$interval" /></xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<!-- Environment variables must be matched directly -->
	<xsl:template match="environment" />

</xsl:stylesheet>
