<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ab-common="http://wob2.iai.uni-bonn.de/ab/common" version="2.0">
	<xsl:import href="common.xsl"/>
	<xsl:output method="html" indent="yes" />

	<!-- Abschnitt für das Menü  -->
	<xsl:template match="/">
		<xsl:call-template name="common">
			<xsl:with-param name="active-section">transaction</xsl:with-param>
			<xsl:with-param name="active-action">list-standing-orders</xsl:with-param>
			<xsl:with-param name="title">Daueraufträge</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- zentraler Bereich  -->
	<xsl:template match="standing-orders">
		<article>
			<h2>Daueraufträge der Gruppe <em><xsl:value-of select="/parameters/environment/current-group/group/name" /></em></h2>
			<table class="standing-orders">
				<colgroup>
					<col class="action-column" />
					<col class="recurrence-column" />
					<col class="amount-column" />
					<col class="debtors-column" />
					<col class="payee-column" />
					<col class="description-column" />
					<col class="creditor-column" />
				</colgroup>
				<thead>
					<tr>
						<th />
						<th>
							<xsl:call-template name="table-header">
								<xsl:with-param name="label">Turnus</xsl:with-param>
								<xsl:with-param name="sort-key">interval</xsl:with-param>
							</xsl:call-template>
						</th>

						<th>
							<xsl:call-template name="table-header">
								<xsl:with-param name="label">Preis</xsl:with-param>
								<xsl:with-param name="sort-key">amount</xsl:with-param>
							</xsl:call-template>
						</th>
						<th>
							<xsl:call-template name="table-header">
								<xsl:with-param name="label">Teilnehmer</xsl:with-param>
								<xsl:with-param name="sort-key">debtors</xsl:with-param>
							</xsl:call-template>
						</th>

						<th>
							<xsl:call-template name="table-header">
								<xsl:with-param name="label">Ort</xsl:with-param>
								<xsl:with-param name="sort-key">payee</xsl:with-param>
							</xsl:call-template>
						</th>
						<th>
							<xsl:call-template name="table-header">
								<xsl:with-param name="label">Verwendungszweck</xsl:with-param>
								<xsl:with-param name="sort-key">description</xsl:with-param>
							</xsl:call-template>
						</th>
						<th>
							<xsl:call-template name="table-header">
								<xsl:with-param name="label">Käufer</xsl:with-param>
								<xsl:with-param name="sort-key">creditor</xsl:with-param>
							</xsl:call-template>
						</th>
					</tr>
				</thead>
				<tbody>
					<xsl:apply-templates select="standing-order"/>
				</tbody>
			</table>
		</article>
	</xsl:template>

	<xsl:template match="standing-order">
		<tr>
			<th>
				<xsl:call-template name="link">
					<xsl:with-param name="target">edit_standing-order.xql</xsl:with-param>
					<xsl:with-param name="params">id=<xsl:value-of select="@id" /></xsl:with-param>
					<xsl:with-param name="tooltip">Dauerauftrag bearbeiten</xsl:with-param>
					<xsl:with-param name="class">edit-link</xsl:with-param>
					<xsl:with-param name="label">Bearbeiten</xsl:with-param>
				</xsl:call-template>
			</th>
			<td>
				<xsl:choose>
					<xsl:when test="recurrence/month-year-interval">
						<xsl:value-of select="ab-common:format-interval(recurrence/month-year-interval)"/>
					</xsl:when>
					<xsl:when test="recurrence/day-time-interval">
						<xsl:value-of select="ab-common:format-interval(recurrence/day-time-interval)"/>
					</xsl:when>
				</xsl:choose>
			</td>
			<td><xsl:value-of select="ab-common:format-amount(transaction/transaction-entries/transaction-entry[1]/amount)"/></td>
			<td><xsl:apply-templates select="transaction/transaction-entries/transaction-entry[1]/debtors/user"/></td>
			<td><xsl:value-of select="transaction/payee"/></td>
			<td><xsl:value-of select="transaction/transaction-entries/transaction-entry[1]/description"/></td>
			<td><xsl:value-of select="/parameters/environment/group-members/user[@id = current()/transaction/creditor/@id]/display-name"/></td>
		</tr>
	</xsl:template>

	<xsl:template match="user">
		<xsl:value-of select="/parameters/environment/group-members/user[@id = current()/@id]/display-name" /><xsl:if test="not(position() = last())">, </xsl:if>
	</xsl:template>

	<xsl:template name="table-header">
		<xsl:param name="label" />
		<xsl:param name="sort-key" />

		<xsl:call-template name="link">
			<xsl:with-param name="target">list_standing_orders.xql</xsl:with-param>
			<xsl:with-param name="params">orderby=<xsl:value-of select="$sort-key" /></xsl:with-param>
			<xsl:with-param name="label"><xsl:value-of select="$label" /></xsl:with-param>
			<xsl:with-param name="class">sort-key</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="link">
			<xsl:with-param name="target">list_standing_orders.xql</xsl:with-param>
			<xsl:with-param name="params">orderby=<xsl:value-of select="$sort-key" />&amp;sort-dir=ascending</xsl:with-param>
			<xsl:with-param name="label">auf</xsl:with-param>
			<xsl:with-param name="tooltip">Aufsteigend sortieren</xsl:with-param>
			<xsl:with-param name="class">sort-dir-asc</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="link">
			<xsl:with-param name="target">list_standing_orders.xql</xsl:with-param>
			<xsl:with-param name="params">orderby=<xsl:value-of select="$sort-key" />&amp;sort-dir=descending</xsl:with-param>
			<xsl:with-param name="label">ab</xsl:with-param>
			<xsl:with-param name="tooltip">Absteigend sortieren</xsl:with-param>
			<xsl:with-param name="class">sort-dir-desc</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
</xsl:stylesheet>
