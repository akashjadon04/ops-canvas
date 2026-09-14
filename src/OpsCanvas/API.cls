Include %occStatus

Class OpsCanvas.API Extends %CSP.REST
{

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
    <Route Url="/" Method="GET" Call="Home"/>
    <Route Url="/api/dashboard" Method="GET" Call="GetDashboard"/>
    <Route Url="/api/overview" Method="GET" Call="GetOverview"/>
</Routes>
}

ClassMethod Home() As %Status
{
    set %response.ContentType = "text/html; charset=utf-8"
    write ##class(OpsCanvas.Ui).RenderHome()
    quit $$$OK
}

ClassMethod GetDashboard() As %Status
{
    set %response.ContentType = "application/json; charset=utf-8"
    write ##class(OpsCanvas.Ui).Dashboard().%ToJSON()
    quit $$$OK
}

ClassMethod GetOverview() As %Status
{
    set %response.ContentType = "application/json; charset=utf-8"
    write ##class(OpsCanvas.Overview).Build().%ToJSON()
    quit $$$OK
}

}
