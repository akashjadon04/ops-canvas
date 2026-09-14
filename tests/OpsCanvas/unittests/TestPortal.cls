Class OpsCanvas.unittests.TestPortal Extends %UnitTest.TestCase
{

Method TestRoleProfiles()
{
    set profiles = ##class(OpsCanvas.Ui).RoleProfiles()

    do $$$AssertEquals(profiles.%Size(), 3, "The UI presents three least-privilege operating lanes")
    do $$$AssertEquals(profiles.%Get(0).%Get("resource"), "%Admin_Operate")
    do $$$AssertEquals(profiles.%Get(1).%Get("resource"), "%Admin_Manage")
    do $$$AssertEquals(profiles.%Get(2).%Get("resource"), "%Admin_Secure")
}

Method TestDashboard()
{
    set dashboard = ##class(OpsCanvas.Ui).Dashboard()

    do $$$AssertEquals(dashboard.%Get("namespace"), $namespace)
    do $$$AssertEquals(dashboard.%Get("productVersion"), $zv)
    do $$$AssertEquals(dashboard.%Get("restAppsEndpoint"), "/api/mgmnt/v1/"_$namespace_"/restapps")
    do $$$AssertEquals(dashboard.%Get("username"), $username)
}

Method TestRenderedPage()
{
    set page = ##class(OpsCanvas.Ui).RenderHome()

    do $$$AssertTrue(page["Ops Canvas", "The page presents the product identity")
    do $$$AssertTrue(page["api/overview", "The UI loads the multi-surface overview")
    do $$$AssertTrue(page["Inspection only", "The UI clearly labels its read-only boundary")
}

Method TestUnavailableSection()
{
    set section = ##class(OpsCanvas.Overview).Unavailable()

    do $$$AssertEquals(section.%Get("available"), 0)
    do $$$AssertEquals(section.%Get("rows").%Size(), 0)
}

}
