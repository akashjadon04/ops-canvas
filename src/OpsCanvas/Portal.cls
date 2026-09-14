Class OpsCanvas.Portal
{

/// The role lanes are explanatory only. Access to every live surface remains
/// enforced by the native IRIS API or SQL query used to retrieve it.
ClassMethod RoleProfiles() As %DynamicArray
{
    set profiles = []
    do profiles.%Push({"id":"operator","title":"Operator","resource":"%Admin_Operate","focus":"Observe processes, capacity, and operational signals."})
    do profiles.%Push({"id":"manager","title":"Manager","resource":"%Admin_Manage","focus":"Review configuration and maintenance plans."})
    do profiles.%Push({"id":"security","title":"Security manager","resource":"%Admin_Secure","focus":"Review users, roles, TLS, certificates, OAuth, and audit activity."})
    quit profiles
}

/// API URLs are relative so requests reuse the authenticated IRIS browser
/// session. The application never receives or persists a password or token.
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

/// Dependency-free shell for the six read-only portal surfaces. The strings are
/// intentionally split into small ASCII-only fragments for IRIS source loading.
ClassMethod RenderHome() As %String
{
    set page = "<!doctype html><html lang='en'><head><meta charset='utf-8'><meta name='viewport' content='width=device-width,initial-scale=1'><title>Ops Canvas</title>"
    set page = page_"<style>:root{--ink:#10213a;--muted:#61708a;--canvas:#eef4fb;--surface:#fff;--line:#d9e3ef;--blue:#1967d2;--green:#12745b;--amber:#a86600}*{box-sizing:border-box}body{margin:0;background:var(--canvas);color:var(--ink);font:15px/1.5 system-ui,sans-serif}.shell{max-width:1240px;margin:auto;padding:40px 22px 68px}.eyebrow{color:var(--blue);font-size:.76rem;font-weight:800;letter-spacing:.12em;text-transform:uppercase}.hero{display:flex;gap:28px;justify-content:space-between;align-items:end;margin-bottom:24px}.hero h1{font-size:clamp(2.4rem,6vw,4.7rem);line-height:.92;letter-spacing:-.06em;margin:.35rem 0 1rem}.lede{max-width:700px;color:var(--muted);font-size:1.08rem}.context{min-width:245px;background:var(--ink);color:#fff;border-radius:18px;padding:19px}.context span{display:block;color:#b9cced;font-size:.74rem;font-weight:800;letter-spacing:.08em;text-transform:uppercase}.context strong{display:block;font-size:1rem;margin:.25rem 0 1rem;word-break:break-word}"
    set page = page_".notice{display:flex;gap:10px;align-items:center;border:1px solid #bde6d8;background:#f1fbf7;border-radius:14px;color:#075c45;padding:12px 15px;margin-bottom:20px}.dot{width:9px;height:9px;border-radius:50%;background:var(--green);flex:none}.refresh{margin-left:auto;border:1px solid var(--line);border-radius:8px;background:#fff;color:var(--blue);cursor:pointer;font-weight:750;padding:8px 10px}.roles{display:grid;grid-template-columns:repeat(3,1fr);gap:10px;margin-bottom:20px}.role,.panel{background:var(--surface);border:1px solid var(--line);border-radius:16px;padding:18px}.role code{display:block;color:var(--blue);font-size:.75rem;font-weight:800;margin-bottom:8px}.role strong{display:block}.role span,.panel p,.foot{color:var(--muted)}.role span{font-size:.86rem}.grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:15px}.wide{grid-column:span 2}.panel h2{font-size:1.2rem;margin:.15rem 0}.panel p{margin:.35rem 0 15px}.items{display:grid;gap:8px}.item{display:grid;grid-template-columns:minmax(0,1fr) auto;gap:10px;border:1px solid var(--line);border-radius:11px;padding:11px 12px}.item b,.item small{display:block}.item small{color:var(--muted);word-break:break-word}.pill{border-radius:999px;background:#e7f0fe;color:#1559b2;font:700 .71rem/1 ui-monospace,monospace;padding:7px 8px;white-space:nowrap}.empty{border-left:4px solid var(--amber);background:#fff8e8;color:#704900;padding:12px}.foot{font-size:.83rem;margin-top:19px}@media(max-width:780px){.hero{display:block}.context{margin-top:20px}.grid,.roles{grid-template-columns:1fr}.wide{grid-column:auto}}</style></head>"
    set page = page_"<body><main class='shell'><div class='hero'><section><div class='eyebrow'>InterSystems IRIS management companion</div><h1>Know the surface<br>before you change it.</h1><p class='lede'>A read-only briefing across six operational areas. Each request uses the signed-in IRIS user. Ops Canvas never stores credentials and never changes configuration.</p></section><aside class='context'><span>Signed-in user</span><strong id='user'>Loading</strong><span>Namespace</span><strong id='namespace'>Loading</strong><span>IRIS runtime</span><strong id='version'>Loading</strong></aside></div>"
    set page = page_"<div class='notice'><i class='dot'></i><span>Inspection only. Use the Management Portal for any change.</span><button class='refresh' id='refresh'>Refresh</button></div><section class='roles' id='roles'></section><section class='grid'><article class='panel wide'><div class='eyebrow'>REST discovery</div><h2>Web applications and REST APIs</h2><p>REST-enabled applications in the current namespace.</p><div class='items' id='apps'><div class='item'>Loading application inventory</div></div></article><article class='panel'><div class='eyebrow'>Access review</div><h2>Permissions</h2><p>Roles and account state visible to this session.</p><div class='items' id='permissions'></div></article><article class='panel'><div class='eyebrow'>Protected configuration</div><h2>Security and secrets</h2><p>TLS, X.509, and OAuth names only. No secret values.</p><div class='items' id='security'></div></article>"
    set page = page_"<article class='panel'><div class='eyebrow'>Scheduler</div><h2>Tasks</h2><p>Scheduled work and current state.</p><div class='items' id='tasks'></div></article><article class='panel'><div class='eyebrow'>Host and capacity</div><h2>Operations</h2><p>Processes and mounted database capacity.</p><div class='items' id='operations'></div></article><article class='panel wide'><div class='eyebrow'>Audit trail</div><h2>Recent system activity</h2><p>Recent audit metadata without descriptions or payloads.</p><div class='items' id='audit'></div></article></section><div class='foot'>Denied sources are clearly marked unavailable; permitted panels continue to work.</div></main>"
    set page = page_"<script>const byId=id=>document.getElementById(id);const escape=value=>String(value==null?'':value).replace(/[&<>]/g,char=>({'&':'&amp;','<':'&lt;','>':'&gt;'}[char]));const unavailable='<div class=empty>This surface is unavailable to the current session. Request only the least privilege needed, then refresh.</div>';const show=(id,section)=>{const host=byId(id);if(!section||!section.available){host.innerHTML=unavailable;return}const rows=section.rows||[];host.innerHTML=rows.length?rows.map(row=>'<div class=item><div><b>'+escape(row.name||row.kind||'Record')+'</b><small>'+escape(row.detail||'No additional metadata')+'</small></div><span class=pill>'+escape(row.kind||'read-only')+'</span></div>').join(''):'<div class=empty>No records were returned for this surface.</div>'};"
    set page = page_"const showApps=endpoint=>fetch(endpoint,{credentials:'same-origin',headers:{Accept:'application/json'}}).then(response=>{if(!response.ok)throw Error();return response.json()}).then(items=>{byId('apps').innerHTML=items.length?items.map(app=>'<div class=item><div><b>'+escape(app.name||'Unnamed application')+'</b><small>'+escape(app.dispatchClass||'No dispatch class reported')+'</small></div><span class=pill>'+escape(app.enabled?'enabled':'disabled')+'</span></div>').join(''):'<div class=empty>No REST-enabled applications were returned.</div>'}).catch(()=>{byId('apps').innerHTML=unavailable});"
    set page = page_"const load=()=>fetch('api/overview',{credentials:'same-origin',headers:{Accept:'application/json'}}).then(response=>{if(!response.ok)throw Error();return response.json()}).then(data=>{const context=data.context||{};byId('user').textContent=context.username||'Unknown';byId('namespace').textContent=context.namespace||'Unknown';byId('version').textContent=context.productVersion||'Unknown';byId('roles').innerHTML=(context.roles||[]).map(role=>'<article class=role><code>'+escape(role.resource)+'</code><strong>'+escape(role.title)+'</strong><span>'+escape(role.focus)+'</span></article>').join('');show('permissions',data.permissions);show('security',data.security);show('tasks',data.tasks);show('operations',data.operations);show('audit',data.audit);return showApps(context.restAppsEndpoint)}).catch(()=>{['permissions','security','tasks','operations','audit','apps'].forEach(id=>{byId(id).innerHTML=unavailable})});byId('refresh').onclick=load;load();</script></body></html>"
    quit page
}

}
