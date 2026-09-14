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
    quit {
        "productVersion":(version),
        "namespace":(namespace),
        "username":($username),
        "managementApiBase":("/api/mgmnt/v1/"_namespace),
        "restAppsEndpoint":("/api/mgmnt/v1/"_namespace_"/restapps"),
        "roles":(..RoleProfiles())
    }
}

/// Dependency-free UI for six read-only portal surfaces. Small string fragments
/// keep this CSP class safe to import across supported IRIS editions.
ClassMethod RenderHome() As %String
{
    set page = "<!doctype html><html lang='en'><head><meta charset='utf-8'>"
    set page = page_"<meta name='viewport' content='width=device-width,initial-scale=1'>"
    set page = page_"<title>Ops Canvas</title><style>"
    set page = page_":root{--ink:#10213a;--muted:#61708a;--canvas:#eef4fb;--surface:#fff;--line:#d9e3ef;--blue:#1967d2;--amber:#a86600}"
    set page = page_"*{box-sizing:border-box}body{margin:0;background:var(--canvas);color:var(--ink);font:15px/1.5 system-ui,sans-serif}"
    set page = page_".shell{max-width:1200px;margin:auto;padding:38px 20px 60px}.eyebrow{color:var(--blue);font-size:.76rem;font-weight:800;letter-spacing:.12em;text-transform:uppercase}"
    set page = page_".hero{display:flex;gap:24px;justify-content:space-between;align-items:end;margin-bottom:22px}.hero h1{font-size:clamp(2.4rem,6vw,4.6rem);line-height:.92;letter-spacing:-.06em;margin:.3rem 0 1rem}"
    set page = page_".lede,.panel p,.foot{color:var(--muted)}.lede{max-width:680px;font-size:1.08rem}.context{min-width:230px;background:var(--ink);color:#fff;border-radius:16px;padding:18px}"
    set page = page_".context span{display:block;color:#b9cced;font-size:.73rem;font-weight:800;letter-spacing:.08em;text-transform:uppercase}.context strong{display:block;margin:.25rem 0 1rem;word-break:break-word}"
    set page = page_".notice{display:flex;gap:10px;align-items:center;border:1px solid #bde6d8;background:#f1fbf7;border-radius:12px;color:#075c45;padding:11px 14px;margin-bottom:18px}"
    set page = page_".refresh{margin-left:auto;border:1px solid var(--line);background:#fff;border-radius:7px;color:var(--blue);font-weight:750;padding:8px 10px;cursor:pointer}"
    set page = page_".roles{display:grid;grid-template-columns:repeat(3,1fr);gap:10px;margin-bottom:18px}.role,.panel{background:var(--surface);border:1px solid var(--line);border-radius:15px;padding:17px}"
    set page = page_".role code{display:block;color:var(--blue);font-size:.75rem;font-weight:800;margin-bottom:8px}.role span{color:var(--muted);font-size:.86rem}"
    set page = page_".grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:14px}.wide{grid-column:span 2}.panel h2{font-size:1.18rem;margin:.15rem 0}.panel p{margin:.3rem 0 14px}"
    set page = page_".items{display:grid;gap:8px}.item{display:grid;grid-template-columns:minmax(0,1fr) auto;gap:8px;border:1px solid var(--line);border-radius:10px;padding:10px 11px}"
    set page = page_".item b,.item small{display:block}.item small{color:var(--muted);word-break:break-word}"
    set page = page_".pill{background:#e7f0fe;color:#1559b2;border-radius:999px;font:700 .71rem/1 ui-monospace,monospace;padding:7px 8px;white-space:nowrap}"
    set page = page_".empty{border-left:4px solid var(--amber);background:#fff8e8;color:#704900;padding:11px}.foot{font-size:.83rem;margin-top:18px}"
    set page = page_"@media(max-width:780px){.hero{display:block}.context{margin-top:18px}.grid,.roles{grid-template-columns:1fr}.wide{grid-column:auto}}</style></head>"
    set page = page_"<body><main class='shell'><div class='hero'><section><div class='eyebrow'>InterSystems IRIS management companion</div><h1>Know the surface<br>before you change it.</h1>"
    set page = page_"<p class='lede'>A read-only briefing across six operational areas. Every request uses the signed-in IRIS user. Ops Canvas never stores credentials or changes configuration.</p></section>"
    set page = page_"<aside class='context'><span>Signed-in user</span><strong id='user'>Loading</strong><span>Namespace</span><strong id='namespace'>Loading</strong><span>IRIS runtime</span><strong id='version'>Loading</strong></aside></div>"
    set page = page_"<div class='notice'><span>Inspection only. Use the Management Portal for any change.</span><button class='refresh' id='refresh'>Refresh</button></div><section class='roles' id='roles'></section><section class='grid'>"
    set page = page_"<article class='panel wide'><div class='eyebrow'>REST discovery</div><h2>Web applications and REST APIs</h2><p>REST-enabled applications in the current namespace.</p><div class='items' id='apps'>Loading</div></article>"
    set page = page_"<article class='panel'><div class='eyebrow'>Access review</div><h2>Permissions</h2><p>Roles and account state visible to this session.</p><div class='items' id='permissions'></div></article>"
    set page = page_"<article class='panel'><div class='eyebrow'>Protected configuration</div><h2>Security and secrets</h2><p>TLS, X.509, and OAuth names only. No secret values.</p><div class='items' id='security'></div></article>"
    set page = page_"<article class='panel'><div class='eyebrow'>Scheduler</div><h2>Tasks</h2><p>Scheduled work and current state.</p><div class='items' id='tasks'></div></article>"
    set page = page_"<article class='panel'><div class='eyebrow'>Host and capacity</div><h2>Operations</h2><p>Processes and mounted database capacity.</p><div class='items' id='operations'></div></article>"
    set page = page_"<article class='panel wide'><div class='eyebrow'>Audit trail</div><h2>Recent system activity</h2><p>Recent audit metadata without descriptions or payloads.</p><div class='items' id='audit'></div></article></section>"
    set page = page_"<div class='foot'>Denied sources are marked unavailable; permitted panels continue to work.</div></main><script>"
    set page = page_"const byId=id=>document.getElementById(id);const escape=value=>String(value==null?'':value).replace(/[&<>]/g,char=>({'&':'&amp;','<':'&lt;','>':'&gt;'}[char]));"
    set page = page_"const unavailable='<div class=empty>This surface is unavailable to the current session. Request only the least privilege needed, then refresh.</div>';"
    set page = page_"const show=(id,section)=>{const host=byId(id);if(!section||!section.available){host.innerHTML=unavailable;return}const rows=section.rows||[];"
    set page = page_"host.innerHTML=rows.length?rows.map(row=>'<div class=item><div><b>'+escape(row.name||row.kind||'Record')+'</b><small>'+escape(row.detail||'No additional metadata')+'</small>"
    set page = page_"</div><span class=pill>'+escape(row.kind||'read-only')+'</span></div>').join(''):'<div class=empty>No records were returned for this surface.</div>'};"
    set page = page_"const showApps=endpoint=>fetch(endpoint,{credentials:'same-origin',headers:{Accept:'application/json'}}).then(response=>{if(!response.ok)throw Error();return response.json()}).then(items=>{"
    set page = page_"byId('apps').innerHTML=items.length?items.map(app=>'<div class=item><div><b>'+escape(app.name||'Unnamed application')+'</b><small>'+escape(app.dispatchClass||'No dispatch class reported')+'</small>"
    set page = page_"</div><span class=pill>'+escape(app.enabled?'enabled':'disabled')+'</span></div>').join(''):'<div class=empty>No REST-enabled applications were returned.</div>'})"
    set page = page_".catch(()=>{byId('apps').innerHTML=unavailable});"
    set page = page_"const load=()=>fetch('api/overview',{credentials:'same-origin',headers:{Accept:'application/json'}}).then(response=>{if(!response.ok)throw Error();return response.json()}).then(data=>{const context=data.context||{};"
    set page = page_"byId('user').textContent=context.username||'Unknown';byId('namespace').textContent=context.namespace||'Unknown';byId('version').textContent=context.productVersion||'Unknown';"
    set page = page_"byId('roles').innerHTML=(context.roles||[]).map(role=>'<article class=role><code>'+escape(role.resource)+'</code><strong>'+escape(role.title)+'</strong><span>'+escape(role.focus)+'</span></article>').join('');"
    set page = page_"show('permissions',data.permissions);show('security',data.security);show('tasks',data.tasks);show('operations',data.operations);show('audit',data.audit);return showApps(context.restAppsEndpoint)}).catch(()=>{"
    set page = page_"['permissions','security','tasks','operations','audit','apps'].forEach(id=>{byId(id).innerHTML=unavailable})});byId('refresh').onclick=load;load();</script></body></html>"
    quit page
}

}
