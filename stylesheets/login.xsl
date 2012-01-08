<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
	<xsl:import href="messages.xsl" />
	<xsl:output method="html" indent="yes" />

	<xsl:template match="/">
		<html lang="de">
			<head>
				<meta charset="utf-8" />
				<title>Login | Haushaltsabrechnung</title>
				<link rel="stylesheet" href="css/main.css" type="text/css" />
			</head>	
			<body>
				<section id="login">
					<xsl:apply-templates select="info" />
					<h1>Haushaltsabrechnung</h1>
					<div id="loginform">
						<form action="login.xql" method="post">
							<fieldset>
								<div class="form-field">
									<label for="user">Name:</label>
									<input name="user" class="textfield" type="text" size="40" placeholder="Benutzername" />
								</div>
								<div class="form-field">
									<label for="password">Passwort:</label>
									<input name="password" class="textfield" type="password" size="40" value="" />
								</div>
								<input id="login-button" class="awesome green submit" type="submit" value="Anmelden" />
							</fieldset>
						</form>
						<a href="">Registrierung</a>
						<a href="">Passwort vergessen?</a>
					</div>
				</section>
			</body>

		</html>
	</xsl:template>
</xsl:stylesheet>
