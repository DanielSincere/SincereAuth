import Vapor

enum AppleFixtures {
  static let successfulSiwaSignUpResponse = ClientResponse(status: .ok,
                                                     headers: HTTPHeaders([("Server", "Apple"),
                                                                          ("Date", "Thu, 24 Nov 2022 00:46:24 GMT"),
                                                                          ("Content-Type", "application/json;charset=ISO-8859-1"),
                                                                          ("Content-Length", "1071"),
                                                                          ("Connection", "keep-alive"),
                                                                          ("Cache-Control", "no-store"),
                                                                          ("Pragma", "no-cache"),
                                                                          ("Host", "appleid.apple.com")]),
                                                     body: ByteBuffer(string: "{\"access_token\":\"ae522011cf01e4794b51b1b7609e2b7fd.0.rsqsu.F3IbmMJb6HLy9Kjb9W7E7Q\",\"token_type\":\"Bearer\",\"expires_in\":3600,\"refresh_token\":\"r0e4d7fa2c7264a7eb656340c0e99676e.0.rsqsu.eSbGyzdwHHy3LdTGcj6ACw\",\"id_token\":\"eyJraWQiOiJZdXlYb1kiLCJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJodHRwczovL2FwcGxlaWQuYXBwbGUuY29tIiwiYXVkIjoiY29tLmZ1bGxxdWV1ZWRldmVsb3Blci5GUUF1dGhTYW1wbGVpT1NBcHAiLCJleHAiOjE2NjkzMzcxODQsImlhdCI6MTY2OTI1MDc4NCwic3ViIjoiMDAyMDI0LjE5NTE5MzZjNjFmYTQ3ZGViYjJiMDc2ZTY4OTZjY2MxLjE5NDkiLCJhdF9oYXNoIjoiSFRtamF3YzlDamZBWTAtQ0NhcF9RUSIsImVtYWlsIjoiZnVsbHF1ZXVlZGV2ZWxvcGVyQGZ1bGxxdWV1ZWRldmVsb3Blci5jb20iLCJlbWFpbF92ZXJpZmllZCI6InRydWUiLCJhdXRoX3RpbWUiOjE2NjkyNTA3ODEsIm5vbmNlX3N1cHBvcnRlZCI6dHJ1ZSwicmVhbF91c2VyX3N0YXR1cyI6Mn0.z-rzD5M4fTVjY-edZLh3XORO6IzF8Vq-fr9e7JaYZprQbjxcGrdxoahbXdHww-ppyxKDZW9wVH7QULvg9W26hSVHGOVPvJ7aQ8U0oY3UH5dANGEw-dIiU-O-pavCR_Didyt_DOVmv07HxDd2VDIHY1riF-aQ2o95ajnqhKAsCIl479k_W26DeHtfik2me3UHiaRZ3bxhlHUb78TVJYQGL2ozegVZ4npYt5VWrPS9gSomOOfqMh7q5bAaoBX9-_Yt4yYrGDesougtUqYSdNrAcs1euf9CHLY7YS1Zw6_wKb_hAPph8E5CCXsi_N_XBEXBzpOf8sN4sIucQE-DeVlnrA\"}"))
  static let successfulSiwaSignInResponse = ClientResponse(status: .ok,
                                                           headers: HTTPHeaders([("Server", "Apple"),
                                                                                 ("Date", "Sun, 04 Dec 2022 03:57:29 GMT"),
                                                                                 ("Content-Type", "application/json;charset=ISO-8859-1"),
                                                                                 ("Content-Length", "1043"),
                                                                                 ("Connection", "keep-alive"),
                                                                                 ("Cache-Control", "no-store"),
                                                                                 ("Pragma", "no-cache"),
                                                                                 ("Host", "appleid.apple.com")]),
                                                           body: ByteBuffer(string: Self.successfulSiwaSignInBody))
  static let successfulSiwaSignInBody = """
    {"access_token":"a8725df60b37c4894af23724edbd3a15c.0.rsqsu.mzsChoTGGE9JJSYDeRKPww","token_type":"Bearer","expires_in":3600,"refresh_token":"rb2ae81cc3283454cbc9e8f010530a7dd.0.rsqsu.fi7hx7kpvMDrwWQrBrJmhA","id_token":"eyJraWQiOiJZdXlYb1kiLCJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJodHRwczovL2FwcGxlaWQuYXBwbGUuY29tIiwiYXVkIjoiY29tLmZ1bGxxdWV1ZWRldmVsb3Blci5GUUF1dGhTYW1wbGVpT1NBcHAiLCJleHAiOjE2NzAyMTI2NDksImlhdCI6MTY3MDEyNjI0OSwic3ViIjoiMDAyMDI0LjE5NTE5MzZjNjFmYTQ3ZGViYjJiMDc2ZTY4OTZjY2MxLjE5NDkiLCJhdF9oYXNoIjoiQ2I3Y05LTWtueHNvb1RjRmw5bEVqUSIsImVtYWlsIjoiZnVsbHF1ZXVlZGV2ZWxvcGVyQGZ1bGxxdWV1ZWRldmVsb3Blci5jb20iLCJlbWFpbF92ZXJpZmllZCI6InRydWUiLCJhdXRoX3RpbWUiOjE2NzAxMjYyNDcsIm5vbmNlX3N1cHBvcnRlZCI6dHJ1ZX0.PMb9KYOA_Ula5mmAfZYOSNcEXQgnYPOooFAMnDEddv40DORJlflrnM39msxIwrSzLMPTrh9mXF5DHgIYWxZ1EE9qc4lfb26eCjXuLdrVX8p8GZmIewU5sxf_MwB5EW0Kc0Gf267EOkqOJF7ECfXrfUghZRdkReqXmvurPrQhMkdQG7kEZzg67VQJSsDa3WQF-cPq2koCih5cJk9DCHcDy6fNn41ABIy-m8MIkpS4YLfwZ8MxLT7txgBgVrlHwTVNVrbjShmsBXFsosztjDvy6_PG0Ili9LLK6kx2luadepZ1LnMXaDKSy4s8BabPzP3hAfpVPcdPROz0nv17GdcJJg"}
    """
  
  static let siwaNotificationBody = """
    {"payload":"eyJraWQiOiJmaDZCczhDIiwiYWxnIjoiUlMyNTYifQ.eyJpc3MiOiJodHRwczovL2FwcGxlaWQuYXBwbGUuY29tIiwiYXVkIjoiY29tLmZ1bGxxdWV1ZWRldmVsb3Blci5GUUF1dGhTYW1wbGVpT1NBcHAiLCJleHAiOjE2NzAxMDI1MzEsImlhdCI6MTY3MDAxNjEzMSwianRpIjoiMFBxbHhZRjAxMWUxNUlNUU94RXNGUSIsImV2ZW50cyI6IntcInR5cGVcIjpcImNvbnNlbnQtcmV2b2tlZFwiLFwic3ViXCI6XCIwMDIwMjQuMTk1MTkzNmM2MWZhNDdkZWJiMmIwNzZlNjg5NmNjYzEuMTk0OVwiLFwiZXZlbnRfdGltZVwiOjE2NzAwMTYxMjUyOTV9In0.CjKB3Lk49HQltGEQTyBUwD1OXUkVEF7bvmiu0lVlqDBx7z5b1WbedAN1JsD8mSbBxjAq4zMhIB-5UmD4v8EufEEXhYVNnoPvP0Nl5OUSCPbB8_40R544wUkg3CwAuujj0l21GYHpkt4Ni3wUT7Jr_DE_yNtIaDKcM89WfBksIiaVyKv53nGho6ruKQblH7I6Zf2Zt1ctYX9X5ezhO4khGoy0N6FLhnDTsPnUc7aLNOzJ4zOeHI5pqc75P4m7Z_o7hm2JRlSdf_9uqdMWspNlEaKoK6Lwkr3lVneSca_9mIalV-pHu_MvSTo3e9udMiV0Bokqlukx77Ue0n3j81wzYA"}
    """
}
