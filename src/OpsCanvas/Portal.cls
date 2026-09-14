Class OpsCanvas.Portal
{

ClassMethod RoleProfiles() As %DynamicArray
{
    set profiles = []
    quit profiles
}

ClassMethod Dashboard(namespace As %String = $namespace, version As %String = $zv) As %DynamicObject
{
    set dashboard = {}
    quit dashboard
}

ClassMethod RenderHome() As %String
{
    quit "Ops Canvas api/overview Inspection only"
}

}
