Include %occStatus

Class OpsCanvas.Overview
{

/// A uniform unavailable state. We never expose database, credential, or audit
/// error text to the browser because those messages can disclose configuration.
ClassMethod Unavailable() As %DynamicObject
{
    quit {"available":0,"rows":[]}
}

ClassMethod Available(rows As %DynamicArray) As %DynamicObject
{
    quit {"available":1,"rows":(rows)}
}

/// Builds the complete read-only briefing. Each surface is evaluated
/// independently so lack of one privilege does not suppress other information.
ClassMethod Build() As %DynamicObject
{
    quit {
        "context":(##class(OpsCanvas.Portal).Dashboard()),
        "permissions":(..Permissions()),
        "security":(..Security()),
        "tasks":(..Tasks()),
        "operations":(..Operations()),
        "audit":(..Audit())
    }
}

ClassMethod Permissions() As %DynamicObject
{
    set rows = []
    try {
        set statement = ##class(%SQL.Statement).%New()
        set sc = statement.%Prepare("SELECT Name, Description FROM Security.Roles_List() ORDER BY Name")
        if $$$ISERR(sc) quit ..Unavailable()
        set result = statement.%Execute()
        for {
            quit:'result.%Next()
            quit:rows.%Size()=12
            set description = result.%Get("Description")
            if description="" set description = "Role available to the current security context"
            do rows.%Push({"kind":"role","name":(result.%Get("Name")),"detail":(description)})
        }
        set statement = ##class(%SQL.Statement).%New()
        set sc = statement.%Prepare("SELECT Name, Enabled FROM Security.Users_List() ORDER BY Name")
        if $$$ISERR(sc) quit ..Available(rows)
        set result = statement.%Execute()
        for {
            quit:'result.%Next()
            quit:rows.%Size()=18
            set state = $select(result.%Get("Enabled"):"enabled",1:"disabled")
            do rows.%Push({"kind":"user","name":(result.%Get("Name")),"detail":("Account is "_state)})
        }
        quit ..Available(rows)
    } catch error {
        quit ..Unavailable()
    }
}

/// Lists configuration identities only. Private keys, passwords, wallet values,
/// OAuth tokens, and audit payloads are never read or emitted by this class.
ClassMethod Security() As %DynamicObject
{
    set rows = []
    try {
        set statement = ##class(%SQL.Statement).%New()
        set sc = statement.%Prepare("SELECT Name, Description, Enabled, Type FROM Security.SSLConfigs_List('*') ORDER BY Name")
        if $$$ISERR(sc) quit ..Unavailable()
        set result = statement.%Execute()
        for {
            quit:'result.%Next()
            quit:rows.%Size()=8
            set state = $select(result.%Get("Enabled"):"enabled",1:"disabled")
            set description = result.%Get("Description")
            if description="" set description = result.%Get("Type")_" TLS configuration"
            do rows.%Push({"kind":"tls "_state,"name":(result.%Get("Name")),"detail":(description)})
        }
        set alias = ""
        for {
            set credential = ##class(%SYS.X509Credentials).GetNext(.alias)
            quit:'$isobject(credential)
            quit:rows.%Size()=14
            set expiry = credential.ValidityNotAfter
            if expiry="" set expiry = "No expiration metadata reported"
            do rows.%Push({"kind":"x509","name":(credential.Alias),"detail":("Valid through "_expiry)})
        }
        set statement = ##class(%SQL.Statement).%New()
        set sc = statement.%Prepare("SELECT IssuerEndpoint, SSLConfiguration FROM OAuth2.ServerDefinition ORDER BY IssuerEndpoint")
        if $$$ISERR(sc) quit ..Available(rows)
        set result = statement.%Execute()
        for {
            quit:'result.%Next()
            quit:rows.%Size()=18
            set tls = result.%Get("SSLConfiguration")
            if tls="" set tls = "No TLS configuration name reported"
            do rows.%Push({"kind":"oauth","name":(result.%Get("IssuerEndpoint")),"detail":(tls)})
        }
        quit ..Available(rows)
    } catch error {
        quit ..Unavailable()
    }
}

ClassMethod Tasks() As %DynamicObject
{
    set rows = []
    try {
        set statement = ##class(%SQL.Statement).%New()
        set sc = statement.%Prepare("SELECT Name, Description, Status, Suspended FROM %SYS.Task ORDER BY Name")
        if $$$ISERR(sc) quit ..Unavailable()
        set result = statement.%Execute()
        for {
            quit:'result.%Next()
            quit:rows.%Size()=12
            set state = $select(result.%Get("Suspended"):"suspended",1:result.%Get("Status"))
            set description = result.%Get("Description")
            if description="" set description = "No task description reported"
            do rows.%Push({"kind":(state),"name":(result.%Get("Name")),"detail":(description)})
        }
        quit ..Available(rows)
    } catch error {
        quit ..Unavailable()
    }
}

/// Returns an intentionally bounded process list plus mounted database capacity.
/// Querying only selected process columns avoids sending intrusive mailbox
/// requests for all process metadata.
ClassMethod Operations() As %DynamicObject
{
    set rows = []
    try {
        set statement = ##class(%SQL.Statement).%New()
        set sc = statement.%Prepare("SELECT Pid, NameSpace, UserName, Routine, CPUTime, MemoryUsed FROM %SYS.ProcessQuery ORDER BY MemoryUsed DESC")
        if $$$ISERR(sc) quit ..Unavailable()
        set result = statement.%Execute()
        for {
            quit:'result.%Next()
            quit:rows.%Size()=8
            set detail = result.%Get("NameSpace")_" · "_result.%Get("Routine")_" · "_result.%Get("MemoryUsed")_" KB"
            do rows.%Push({"kind":"process","name":("PID "_result.%Get("Pid")_" · "_result.%Get("UserName")),"detail":(detail)})
        }
        set statement = ##class(%SQL.Statement).%New()
        set sc = statement.%Prepare("SELECT DatabaseName, Size, Available, DiskFreeSpace, Status FROM %SYS.DatabaseQuery_FreeSpace(?)")
        if $$$ISERR(sc) quit ..Available(rows)
        set result = statement.%Execute("*")
        for {
            quit:'result.%Next()
            quit:rows.%Size()=16
            set detail = "Size "_result.%Get("Size")_" · available "_result.%Get("Available")_" · disk free "_result.%Get("DiskFreeSpace")
            do rows.%Push({"kind":("database "_result.%Get("Status")),"name":(result.%Get("DatabaseName")),"detail":(detail)})
        }
        quit ..Available(rows)
    } catch error {
        quit ..Unavailable()
    }
}

/// Displays high-level audit metadata only. In particular, EventData is not
/// selected because it may contain protected context from another subsystem.
ClassMethod Audit() As %DynamicObject
{
    set rows = []
    try {
        set statement = ##class(%SQL.Statement).%New()
        set sc = statement.%Prepare("SELECT TOP 12 UTCTimeStamp, EventSource, EventType, Event, Username FROM %SYS.Audit ORDER BY UTCTimeStamp DESC")
        if $$$ISERR(sc) quit ..Unavailable()
        set result = statement.%Execute()
        for {
            quit:'result.%Next()
            set actor = result.%Get("Username")
            if actor="" set actor = "system"
            do rows.%Push({"kind":(result.%Get("EventSource")_"/"_result.%Get("EventType")),"name":(result.%Get("Event")),"detail":(actor_" · "_result.%Get("UTCTimeStamp"))})
        }
        quit ..Available(rows)
    } catch error {
        quit ..Unavailable()
    }
}

}
