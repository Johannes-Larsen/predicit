# A7 Reflection

This app's authentication is only a teaching mock, not real security. A real app would not store plaintext passwords in a bundled `users.json` file because anyone who has the app can inspect the bundle and read those passwords. Real authentication should verify credentials on a server, store passwords as slow salted hashes such as bcrypt or Argon2, and use session tokens that expire and can be revoked. It should also use secure transport like TLS so credentials and tokens are not readable in transit.
