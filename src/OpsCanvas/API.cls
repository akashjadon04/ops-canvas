Include %occStatus

Class OpsCanvas.API Extends %CSP.REST
{

Parameter HandleCorsRequest = 1;

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
    <Route Url="/" Method="GET" Call="Home"/>
    <Route Url="/api/dashboard" Method="GET" Call="GetDashboard"/>
</Routes>
}

ClassMethod Home() As %Status
{
    set %response.ContentType = "text/html; charset=utf-8"
    write ##class(OpsCanvas.Portal).RenderHome()
    quit $$$OK
}

ClassMethod GetDashboard() As %Status
{
    set %response.ContentType = "application/json; charset=utf-8"
    write ##class(OpsCanvas.Portal).Dashboard().%ToJSON()
    quit $$$OK
}

}
