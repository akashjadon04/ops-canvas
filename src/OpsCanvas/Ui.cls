Include %occStatus

Class OpsCanvas.Ui
{

ClassMethod Dashboard(namespace As %String = $namespace, version As %String = $zv) As %DynamicObject
{
    quit {
        "productVersion":(version),
        "namespace":(namespace),
        "username":($username),
        "managementApiBase":("/api/mgmnt/v1/"_namespace),
        "restAppsEndpoint":("/api/mgmnt/v1/"_namespace_"/restapps")
    }
}

ClassMethod RenderHome() As %String
{
    quit "Ops Canvas api/overview Inspection only"
}

}
