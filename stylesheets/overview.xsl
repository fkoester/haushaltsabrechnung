<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ab-common="http://wob2.iai.uni-bonn.de/ab/common" version="2.0" exclude-result-prefixes="ab-common">
	<xsl:import href="common.xsl"/>
	<xsl:output method="html" indent="yes" />

	<!-- Abschnitt für das Menü  -->
	<xsl:template match="/">
		<xsl:call-template name="common">
			<xsl:with-param name="active-section">overview</xsl:with-param>
			<xsl:with-param name="active-action">overview</xsl:with-param>
			<xsl:with-param name="title">Übersicht</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- zentraler Bereich  -->
	<xsl:template match="overview-data">
		<article>
			<h2>Hallo <xsl:value-of select="/parameters/environment/current-user/user/display-name" />!</h2>

			<xsl:if test="count(messages/message) > 0">
				<section id="messages-overview" class="overview-section">
					<h3>Nachrichten</h3>
					<xsl:apply-templates select="messages"/>
				</section>
			</xsl:if>

			<section id="transactions-overview" class="overview-section">
				<h3>Ausgaben</h3>
				<p>Die zuletzt eingetragenen (oder geänderten) Ausgaben in der Gruppe <em><xsl:value-of select="/parameters/environment/current-group/group/name" /></em>, an deren Kosten du beteiligt bist:</p>
				<xsl:apply-templates select="transactions[@creditor-id != /parameters/environment/current-user/user/@id]"/>
				<xsl:apply-templates select="transactions[@creditor-id = /parameters/environment/current-user/user/@id]"/>
			</section>

			<section id="balance-overview" class="overview-section">
				<h3>Bilanz</h3>
				<xsl:apply-templates select="balances"/>
			</section>
		</article>
	</xsl:template>

	<xsl:template match="transactions">
		<xsl:if test="count(transaction) > 0">
			<h4>
				<xsl:choose>
					<xsl:when test="@creditor-id != /parameters/environment/current-user/user/@id">
						<xsl:value-of select="/parameters/environment/group-members/user[@id = current()/@creditor-id]/display-name" /><xsl:text>:</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>Deine Ausgaben:</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</h4>
			<div class="transactions-overview">
				<div class="table-header">
					<span class="table-column-title" />
					<span class="table-column-title">Eingetragen / Geändert</span>
					<span class="table-column-title">Buchungsdatum</span>
					<span class="table-column-title">Beschreibung</span>
					<span class="table-column-title">Kosten</span>
					<span class="table-column-title">Dein Anteil</span>
				</div>
				<xsl:apply-templates select="transaction" />
			</div>
		</xsl:if>
	</xsl:template>

	<xsl:template match="transaction">
		<div class="transaction-overview">
			<span class="flags">
				<xsl:if test="@created-from-standing-order-id">
					<xsl:call-template name="link">
						<xsl:with-param name="target">edit_standing-order.xql</xsl:with-param>
						<xsl:with-param name="params">id=<xsl:value-of select="@created-from-standing-order-id" /></xsl:with-param>
						<xsl:with-param name="tooltip">Aus Dauerauftrag erstellt. Klicken um zum zugehörigen Dauerauftrag zu gelangen.</xsl:with-param>
						<xsl:with-param name="class">standing-order-link</xsl:with-param>
						<xsl:with-param name="label">Dauerauftrag</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
			</span>
			<time class="last-changed-date">
				<xsl:variable name="last-change">
					<xsl:value-of select="if(@last-modified) then @last-modified else @created" />
				</xsl:variable>
				<xsl:attribute name="dateTime"><xsl:value-of select="$last-change" /></xsl:attribute>
				<xsl:value-of select="format-dateTime($last-change, '[FNn,0-2], [D01].[M01]. [H01]:[m01]')" />
			</time>
			<time class="booking-date">
				<xsl:attribute name="dateTime"><xsl:value-of select="booking-date" /></xsl:attribute>
				<xsl:value-of select="format-date(booking-date, '[FNn,0-2], [D01].[M01].')" />
			</time>
			<span class="description"><xsl:value-of select="transaction-entries/transaction-entry/description" /></span>
			<span class="amount">
				<xsl:value-of select="ab-common:format-amount(transaction-entries/transaction-entry/amount)" />
			</span>
			<span class="users-share">
				<xsl:value-of select="ab-common:format-amount(transaction-entries/transaction-entry/amount div count(transaction-entries/transaction-entry/debtors/user))" />	
			</span>
		</div>
	</xsl:template>

	<xsl:template match="balances">
		<p>Die Bilanzen in der Gruppe <em><xsl:value-of select="/parameters/environment/current-group/group/name" /></em>:</p>
		<div class="balances-of-group">
			<xsl:apply-templates select="balance" />
			<div class="balance-sum-label"><strong>Insgesamt:</strong></div>
			<div class="balance-sum-value">
				<span>
					<xsl:variable name="amount-sum" select="sum(balance/amount)" />
					<xsl:choose>
						<xsl:when test="$amount-sum >= 0">
							<xsl:attribute name="class">positive-balance</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="class">negative-balance</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:value-of select="ab-common:format-amount($amount-sum)" />
				</span>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="balance">
		<div class="balance-between-users">
			<div class="balance-name">
				<strong><xsl:value-of select="user/display-name" /></strong>:
			</div>
			<div class="balance-value">
				<span>
					<xsl:choose>
						<xsl:when test="amount >= 0">
							<xsl:attribute name="class">positive-balance</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="class">negative-balance</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose><xsl:value-of select="ab-common:format-amount(amount)" />
				</span>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="messages">
		<ul>
			<xsl:apply-templates select="message" />
		</ul>
	</xsl:template>

	<xsl:template match="message">
		<li><b><xsl:value-of select="sender/@id" /></b> schreibt <em><a title="Nachricht lesen"><xsl:attribute name="href">read_message.xql?id=<xsl:value-of select="@id" /></xsl:attribute><xsl:value-of select="subject" /></a></em> in Gruppe <xsl:value-of select="/parameters/environment/groups/group[@id = current()/group/@id]/name" /></li>
	</xsl:template>

</xsl:stylesheet>
