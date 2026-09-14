Class OpsCanvas.Portal
{

/// The role lanes are explanatory only. Access is enforced by the native IRIS
/// API or SQL query that retrieves each live surface.
ClassMethod RoleProfiles() As %DynamicArray
{
    set profiles = []
    do profiles.%Push({"id":"operator","title":"Operator","resource":"%Admin_Operate","focus":"Observe processes, capacity, and operational signals."})
    do profiles.%Push({"id":"manager","title":"Manager","resource":"%Admin_Manage","focus":"Review configuration and maintenance plans."})
    do profiles.%Push({"id":"security","title":"Security manager","resource":"%Admin_Secure","focus":"Review users, roles, TLS, certificates, OAuth, and audit activity."})
    quit profiles
}

/// API URLs are relative so requests reuse the authenticated browser session.
ClassMethod Dashboard(namespace As %String = $namespace, version As %String = $zv) As %DynamicObject
{
    set dashboard = {
        "productVersion":(version),
        "namespace":(namespace),
        "username":($username),
        "managementApiBase":("/api/mgmnt/v1/"_namespace),
        "restAppsEndpoint":("/api/mgmnt/v1/"_namespace_"/restapps"),
        "roles":(..RoleProfiles())
    }
    quit dashboard
}

/// Deliberately compact HTML shell. The live data is served from the REST API
/// so this class remains portable to the community and health editions of IRIS.
ClassMethod RenderHome() As %String
{
    set page = "<html><head><title>Ops Canvas</title></head><body>"
    set page = page_"<h1>Ops Canvas</h1><p>Inspection only.</p>"
    set page = page_"<p>This read-only portal loads live information from api/overview.</p>"
    set page = page_"<ul><li>Web applications and REST APIs</li><li>Permissions</li>"
    set page = page_"<li>Security and secrets</li><li>Tasks</li><li>Operations</li>"
    set page = page_"<li>Audit metadata</li></ul></body></html>"
    quit page
}

}
