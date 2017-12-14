require 'net/https'
require 'uri'

require 'json'

def get(url)
  begin
    uri = URI.parse(URI.escape(url)) # 何故かescape必要?
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    req = Net::HTTP::Get.new(uri.path)
    res = http.request(req)
    return nil unless res
    return res.body
  rescue
    return nil
  end
end

if __FILE__ == $0 then
  puts get("https://scrapbox.io/api/pages/Gyazo/glossary/text")
end
