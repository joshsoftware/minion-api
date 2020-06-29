module CommonMethods
  def add_request_headers(user: nil)
    header 'Content-Type', 'application/json'
    header 'X-Auth-Token', user ? JwtService.encode(user) : ""
  end
end
