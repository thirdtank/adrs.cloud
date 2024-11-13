class Brut::FrontEnd::RouteHooks::CSP < Brut::FrontEnd::RouteHook
  def after(response:,request:)
    csp_reporting_path = uri("/__brut/csp-reporting",request:)
    response.headers["Content-Security-Policy-Report-Only"] = [
      "default-src 'self'",
      "script-src-elem 'self'",
      "script-src-attr 'none'",
      "style-src-elem 'self'",
      "style-src-attr 'none'",
      "report-to csp_reporting",
      "report-uri #{csp_reporting_path}",
    ].join("; ")
    response.headers["Reporting-Endpoints"] = "csp_reporting='#{csp_reporting_path}'"
    continue
  end

private

  def uri(path,request:)
    # Adapted from Sinatra's innards
    host = "http#{'s' if request.secure?}://"
    if request.forwarded? || (request.port != (request.secure? ? 443 : 80))
      host << request.host_with_port
    else
      host << request.host
    end
    uri_parts = [
      host,
      request.script_name.to_s,
      path,
    ]
    File.join(uri_parts)
  end
end
