Include %occStatus

Class OpsCanvas.Ui
{

ClassMethod Dashboard() As %DynamicObject
{
    set ns = $namespace, productVersion = $zv
    quit {
        "productVersion":(productVersion),
        "namespace":(ns),
        "username":($username),
        "managementApiBase":("/api/mgmnt/v1/"_ns),
        "restAppsEndpoint":("/api/mgmnt/v1/"_ns_"/restapps")
    }
}

ClassMethod RenderHome() As %String
{
    quit "Ops Canvas api/overview Inspection only"
}

}
