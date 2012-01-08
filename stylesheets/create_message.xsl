<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
	<xsl:import href="common.xsl"/>
	<xsl:output method="html" indent="yes" />

	<!-- Abschnitt für das Menü  -->
	<xsl:template match="/">
		<xsl:call-template name="common">
			<xsl:with-param name="active-section">messages</xsl:with-param>
			<xsl:with-param name="active-action">create-message</xsl:with-param>
			<xsl:with-param name="title">Nachrichten</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<!-- zentraler Bereich  -->
	<xsl:template match="/parameters">
		<article>
			<h2>Nachricht versenden</h2>
			<form action="create_message.xql" id="message-form" class="table-form">
				<fieldset class="no-legend">
					<div class="form-field" id="subject-field">
						<label for="subject">Betreff:</label>
						<div class="field-input">
							<input name="subject" class="textInput" type="text" size="40" title="Bitte geben Sie den Betreff ein" placeholder="Betreff" />
						</div>
					</div>
					<div class="form-field" id="content-field">
						<label for="content">Nachricht:</label>
						<div class="field-input">
							<textarea name="content" class="textInput" value="Content" title="Bitte geben Sie hier die Nachricht ein" placeholder="Nachricht" cols="50" rows="10"></textarea>
						</div>
					</div>
					<div class="form-field" id="recipients-field">
						<label for="recipients">Empfänger:</label>
						<div class="field-input">
							<xsl:for-each select="/parameters/environment/group-members/user">
								<input name="recipients" type="checkbox" checked="checked" value="{@id}" title="Bitte wählen Sie die Empfänger der Nachricht aus">
									<xsl:value-of select="display-name" />
								</input>
							</xsl:for-each>
						</div>
					</div>
					<xsl:call-template name="state-input" />
				</fieldset>
				<input type="submit" class="large green awesome submit" value="Senden" />
			</form>
		</article>
	</xsl:template>
</xsl:stylesheet>
