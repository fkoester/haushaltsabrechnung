<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
	<xsl:import href="common.xsl"/>
	<xsl:import href="transaction-common.xsl" />
	<xsl:output method="html" indent="yes" />

	<xsl:template name="transaction-fieldsets">
		<fieldset class="no-legend" id="common-fields">
			<div class="form-field" id="description-field">
				<label for="description">Beschreibung:</label>
				<div class="field-input">
					<input name="description" class="" type="text" size="40" placeholder="Beschreibung" required="required" value="{transaction-entries/transaction-entry[1]/description}" />
				</div>
			</div>
			<div class="form-field" id="payee-field">
				<label for="payee">Gekauft bei:</label>
				<div class="field-input">
					<input name="payee" class="" type="text" size="40" placeholder="Zahlungsempfänger" required="required" value="{payee}" />
				</div>
			</div>
			<div class="form-field" id="amount-field">
				<label for="amount">Betrag:</label>
				<div class="field-input">
					<input class="arithmetic " name="amount" type="text" size="40" placeholder="Geldbeträge oder Formeln" required="required" value="{transaction-entries/transaction-entry[1]/amount}" />
					<span class="arithmetic-result result-field" />
				</div>
			</div>
			<div class="form-field" id="sub-transactions-field">
				<label for="sub-transactions">Teileinkäufe:</label>
				<div class="field-input">
					<input id="sub-transactions-input-no" type="radio" name="sub-transactions" value="no">
						<xsl:if test="count(transaction-entries/transaction-entry) = 1">
							<xsl:attribute name="checked">checked</xsl:attribute>
						</xsl:if>
					</input>
					<xsl:text>Nein</xsl:text>
					<input id="sub-transactions-input-yes" type="radio" name="sub-transactions" value="yes">
						<xsl:if test="count(transaction-entries/transaction-entry) > 1">
							<xsl:attribute name="checked">checked</xsl:attribute>
						</xsl:if>
					</input>
					<xsl:text>Ja</xsl:text>
				</div>
			</div>
			<div class="form-field" id="occurrences-field">
				<label for="occurrences">Auftreten:</label>
				<div class="field-input">
					<input id="occurrences-input-once" type="radio" name="occurrences" value="once" checked="checked" />Einmalig
					<input id="occurrences-input-multi" type="radio" name="occurrences" value="multi" />Regelmäßig
				</div>
			</div>

			<xsl:apply-templates select="transaction-entries/transaction-entry[1]/debtors" />

			<div class="form-field" id="booking-date-field">
				<label for="booking-date">Datum des Einkaufs:</label>
				<div class="field-input">
					<input id="booking-date-input" class="date " name="booking-date" type="date">
						<xsl:if test="booking-date != ''">
							<xsl:attribute name="value">
								<xsl:value-of select="booking-date" />
							</xsl:attribute>
						</xsl:if>
					</input>
				</div>
			</div>
		</fieldset>
		<fieldset id="sub-transactions-fieldset">
			<legend>Teileinkäufe</legend>
			<label />
			<div class="field-input" id="sub-transactions-buttons-cell">
				<input id="add-sub-transaction-button" class="awesome small" type="submit" title="Teileinkauf hinzufügen" name="add-sub-transaction" value="Teileinkauf hinzufügen" />
				<input id="remove-sub-transaction-button" class="awesome small red" type="submit" title="Den letzten Teileinkauf entfernen" name="remove-sub-transaction" value="Letzten Teileinkauf entfernen" />
			</div>
			<xsl:apply-templates select="transaction-entries/transaction-entry[position() > 1]" />
		</fieldset>
		<fieldset id="standing-order-fieldset">
			<legend>Dauerauftrag</legend>

			<div class="form-field" id="start-date-field">
				<label for="start-date">Startdatum:</label>
				<div class="field-input">
					<input id="start-date-input" class="date" name="start-date" type="date" />
				</div>
			</div>
			
			<div class="form-field" id="end-date-field">
				<label for="end-date">Enddatum (optional):</label>
				<div class="field-input">
					<input id="end-date-input" class="date" name="end-date" type="date" />
				</div>
			</div>

			<div class="form-field" id="recurrence-field">
				<label for="recurrence">Turnus:</label>
				<div class="field-input">
					<input id="recurrence-weekly-radio" type="radio" name="recurrence" value="weekly" />Wöchentlich
					<input id="recurrence-monthly-radio" type="radio" name="recurrence" value="monthly" checked="checked" />Monatlich
				</div>
			</div>
			<div class="form-field" id="recurrence-details-field">
				<label id="recurrence-details-label" for="recurrence-details">Details:</label>
				<div class="field-input">
					<div id="recurrence-weekly-details">
						<div class="multi-input-line">
							<span>Jeden </span>
							<input id="week-interval-input" name="weekly-week-interval" type="number" min="1" max="99" value="1" />
							<span>. </span>
							<select id="weekly-weekday-select" name="weekly-weekday" size="1">
								<option value="1">Montag</option>
								<option value="2">Dienstag</option>
								<option value="3">Mittwoch</option>
								<option value="4">Donnerstag</option>
								<option value="5">Freitag</option>
								<option value="6">Samstag</option>
								<option value="0">Sonntag</option>
							</select>
						</div>
					</div>
					<div id="recurrence-monthly-details" class="multi-line-input">
						<div class="multi-input-line">
							<span>Alle </span>
							<input id="monthly-month-interval-input" name="monthly-month-interval" type="number" min="1" max="99" value="1" />
							<span> Monate</span>
						</div>
						<div class="multi-input-line">
							<input type="radio" checked="checked" name="monthly-type" value="on-day-of-month" />
							<span>am </span>
							<input id="day-of-month-input" name="monthly-day-of-month" type="number" min="1" max="28" value="1" />
							<span>. Tag des Monats</span>
						</div>
						<div class="multi-input-line">
							<input type="radio" name="monthly-type" value="on-weekday" />
							<span>am </span>
							<input id="weekday-number-input" name="monthly-weekday-number" type="number" min="1" max="5" value="1" />
							<span>. </span>
							<select id="monthly-weekday-select" name="monthly-weekday" size="1">
								<option value="1">Montag</option>
								<option value="2">Dienstag</option>
								<option value="3">Mittwoch</option>
								<option value="4">Donnerstag</option>
								<option value="5">Freitag</option>
								<option value="6">Samstag</option>
								<option value="0">Sonntag</option>
							</select>
							<span> des Monats</span>
						</div>
					</div>
				</div>
			</div>
		</fieldset>
	</xsl:template>
</xsl:stylesheet>
