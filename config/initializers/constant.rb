# frozen_string_literal: true

AUTH_TOKEN_EXPIRY = 8 * 60 * 60
AUTH_HEADER = 'X_AUTH_TOKEN'
HTTP_AUTH_HEADER = "HTTP_#{AUTH_HEADER}"
ROLES = { admin: 'ADMIN', employee: 'EMPLOYEE' }.freeze
