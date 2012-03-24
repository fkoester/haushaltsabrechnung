<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ab-common="http://wob2.iai.uni-bonn.de/ab/common" version="2.0">
	<xsl:import href="common.xsl"/>
	<xsl:output method="html" indent="yes" />

	<!-- Abschnitt für das Menü  -->
	<xsl:template match="/">
		<xsl:call-template name="common">
			<xsl:with-param name="active-section">transaction</xsl:with-param>
			<xsl:with-param name="active-action">list-transactions</xsl:with-param>
			<xsl:with-param name="title">Ausgaben</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- zentraler Bereich  -->
	<xsl:template match="transactions">
		<article>
			<h2>Ausgaben der Gruppe <em><xsl:value-of select="/parameters/environment/current-group/group/name" /></em></h2>
			<table class="transactions">
				<colgroup>
					<col class="action-column" />
					<col class="last-change-column" />
					<col class="booking-date-column" />
					<col class="amount-column" />
					<col class="users-share-column" />
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
								<xsl:with-param name="label">Änd.</xsl:with-param>
								<xsl:with-param name="sort-key">last-changed</xsl:with-param>
							</xsl:call-template>
						</th>

						<th>
							<xsl:call-template name="table-header">
								<xsl:with-param name="label">Datum</xsl:with-param>
								<xsl:with-param name="sort-key">booking-date</xsl:with-param>
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
								<xsl:with-param name="label">Anteil</xsl:with-param>
								<xsl:with-param name="sort-key">users-share</xsl:with-param>
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
								<xsl:with-param name="label">Beschreibung</xsl:with-param>
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
					<xsl:apply-templates select="transaction"/>
				</tbody>
			</table>
		</article>
	</xsl:template>

	<xsl:template match="transaction">
		<tr>
			<th>
				<xsl:if test="creditor/@id = /parameters/environment/current-user/user/@id">
					<xsl:call-template name="link">
						<xsl:with-param name="target">transaction.xql</xsl:with-param>
						<xsl:with-param name="params">id=<xsl:value-of select="@id" />&amp;operation=edit</xsl:with-param>
						<xsl:with-param name="tooltip">Kosten bearbeiten</xsl:with-param>
						<xsl:with-param name="class">edit-link</xsl:with-param>
						<xsl:with-param name="label">Bearbeiten</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
				<xsl:if test="@created-from-standing-order-id">
					<xsl:call-template name="link">
						<xsl:with-param name="target">edit_standing-order.xql</xsl:with-param>
						<xsl:with-param name="params">id=<xsl:value-of select="@created-from-standing-order-id" /></xsl:with-param>
						<xsl:with-param name="tooltip">Aus Dauerauftrag erstellt. Klicken um zum zugehörigen Dauerauftrag zu gelangen.</xsl:with-param>
						<xsl:with-param name="class">standing-order-link</xsl:with-param>
						<xsl:with-param name="label">Dauerauftrag</xsl:with-param>
					</xsl:call-template>
				</xsl:if>
			</th>
			<td><xsl:value-of select="format-dateTime((if(@last-modified) then @last-modified else @created), '[D01].[M01].[Y0001]')"/></td>
			<td><xsl:value-of select="format-date(booking-date, '[D01].[M01].[Y0001]')"/></td>
			<td><xsl:value-of select="ab-common:format-amount(transaction-entries/transaction-entry[1]/amount)"/></td>
			<td><xsl:value-of select="if(transaction-entries/transaction-entry/debtors/user/@id = /parameters/environment/current-user/user/@id) then ab-common:format-amount(transaction-entries/transaction-entry/amount div count(transaction-entries/transaction-entry/debtors/user)) else ab-common:format-amount(0)"/></td>
			<td><xsl:apply-templates select="transaction-entries/transaction-entry[1]/debtors/user"/></td>
			<td><xsl:value-of select="payee"/></td>
			<td><xsl:value-of select="transaction-entries/transaction-entry[1]/description"/></td>
			<td><xsl:value-of select="/parameters/environment/group-members/user[@id = current()/creditor/@id]/display-name"/></td>
		</tr>
	</xsl:template>

	<xsl:template match="user">
		<xsl:value-of select="/parameters/environment/group-members/user[@id = current()/@id]/display-name" /><xsl:if test="not(position() = last())">, </xsl:if>
	</xsl:template>

	<xsl:template name="table-header">
		<xsl:param name="label" />
		<xsl:param name="sort-key" />

		<xsl:call-template name="link">
			<xsl:with-param name="target">list_transactions.xql</xsl:with-param>
			<xsl:with-param name="params">orderby=<xsl:value-of select="$sort-key" /></xsl:with-param>
			<xsl:with-param name="label"><xsl:value-of select="$label" /></xsl:with-param>
			<xsl:with-param name="class">sort-key</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="link">
			<xsl:with-param name="target">list_transactions.xql</xsl:with-param>
			<xsl:with-param name="params">orderby=<xsl:value-of select="$sort-key" />&amp;sort-dir=ascending</xsl:with-param>
			<xsl:with-param name="label">auf</xsl:with-param>
			<xsl:with-param name="tooltip">Aufsteigend sortieren</xsl:with-param>
			<xsl:with-param name="class">sort-dir-asc</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="link">
			<xsl:with-param name="target">list_transactions.xql</xsl:with-param>
			<xsl:with-param name="params">orderby=<xsl:value-of select="$sort-key" />&amp;sort-dir=descending</xsl:with-param>
			<xsl:with-param name="label">ab</xsl:with-param>
			<xsl:with-param name="tooltip">Absteigend sortieren</xsl:with-param>
			<xsl:with-param name="class">sort-dir-desc</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
</xsl:stylesheet>
