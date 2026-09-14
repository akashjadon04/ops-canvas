Class OpsCanvas.Portal
{

/// Returns the least-privilege lanes used by the UI. The application is
/// intentionally read-only: it helps an administrator inspect a system before
/// making changes in the Management Portal.
ClassMethod RoleProfiles() As %DynamicArray
{
    set profiles = []
    do profiles.%Push({
        "id":"operator",
        "title":"Operator",
        "resource":"%Admin_Operate",
        "focus":"Observe system status, process activity, and operational signals.",
        "tone":"observe"
    })
    do profiles.%Push({
        "id":"manager",
        "title":"Manager",
        "resource":"%Admin_Manage",
        "focus":"Review configuration, databases, namespaces, and planned changes.",
        "tone":"plan"
    })
    do profiles.%Push({
        "id":"security",
        "title":"Security manager",
        "resource":"%Admin_Secure",
        "focus":"Review application access and permission-sensitive surfaces.",
        "tone":"protect"
    })
    quit profiles
}

/// Provides the small, server-derived payload that powers the browser UI.
/// The management API base is deliberately relative so the browser reuses the
/// authenticated IRIS session when it reads REST application inventory.
ClassMethod Dashboard(namespace As %String = $namespace, version As %String = $zv) As %DynamicObject
{
    set dashboard = {
        "productVersion":(version),
        "namespace":(namespace),
        "managementApiBase":("/api/mgmnt/v1/"_namespace),
        "restAppsEndpoint":("/api/mgmnt/v1/"_namespace_"/restapps"),
        "roles":(..RoleProfiles())
    }
    quit dashboard
}

/// Renders a dependency-free management companion that can run entirely inside
/// an IRIS CSP REST application. The inventory request is made from the
/// browser to IRIS' documented Management API endpoint, preserving the
/// privileges of the signed-in administrator rather than proxying credentials.
ClassMethod RenderHome(namespace As %String = $namespace, version As %String = $zv) As %String
{
    set state = ..Dashboard(namespace, version).%ToJSON()
    set page = "<!doctype html><html lang='en'><head><meta charset='utf-8'><meta name='viewport' content='width=device-width,initial-scale=1'><title>Ops Canvas</title>"
    set page = page_"<style>:root{--ink:#10213a;--muted:#61708a;--surface:#fff;--canvas:#eef4fb;--line:#d9e3ef;--blue:#1967d2;--amber:#c67800;--green:#12745b}*{box-sizing:border-box}body{margin:0;background:var(--canvas);color:var(--ink);font:16px/1.5 ui-sans-serif,system-ui,-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif}.shell{max-width:1120px;margin:auto;padding:44px 24px 72px}.eyebrow{color:var(--blue);font-size:.76rem;font-weight:800;letter-spacing:.13em;text-transform:uppercase}.hero{display:grid;grid-template-columns:1.4fr .8fr;gap:24px;align-items:end;margin-bottom:24px}h1{font-size:clamp(2.2rem,6vw,4.5rem);line-height:.95;letter-spacing:-.065em;margin:.35rem 0 1rem}.lede{max-width:670px;color:var(--muted);font-size:1.08rem}.status{background:var(--ink);color:#fff;border-radius:20px;padding:22px}.status span{display:block;color:#b9cced;font-size:.78rem;font-weight:700;letter-spacing:.08em;text-transform:uppercase}.status strong{display:block;font-size:1.1rem;margin:.35rem 0}.status code{font-size:.82rem;color:#dce9ff;word-break:break-all}.grid{display:grid;grid-template-columns:repeat(3,1fr);gap:14px}.card,.inventory{background:var(--surface);border:1px solid var(--line);border-radius:18px;padding:22px;box-shadow:0 12px 26px rgba(27,56,92,.05)}.card h2{font-size:1.05rem;margin:.25rem 0}.card p{color:var(--muted);font-size:.92rem;margin:0}.tag{display:inline-flex;background:#e7f0fe;color:#1559b2;border-radius:999px;font:700 .76rem/1 ui-monospace,SFMono-Regular,Menlo,monospace;padding:7px 9px;margin-bottom:18px}.inventory{margin-top:24px}.inventory header{display:flex;gap:18px;justify-content:space-between;align-items:end}.inventory h2{font-size:1.45rem;letter-spacing:-.03em;margin:.2rem 0}.inventory p{color:var(--muted);margin:.2rem 0}.counter{color:var(--blue);font-weight:800}.apps{display:grid;grid-template-columns:repeat(auto-fill,minmax(210px,1fr));gap:12px;margin-top:20px}.app{border:1px solid var(--line);border-radius:13px;padding:16px}.app b,.app small{display:block}.app small{color:var(--muted);margin-top:4px;word-break:break-all}.message{margin-top:18px;border-left:4px solid var(--amber);background:#fff8e8;padding:13px 15px;color:#704900}.footer{color:var(--muted);font-size:.84rem;margin-top:20px}.action{border:1px solid var(--line);border-radius:9px;background:#fff;color:var(--blue);padding:9px 11px;font-weight:750;cursor:pointer}.action:hover{background:#f5f9ff}@media(max-width:720px){.hero{grid-template-columns:1fr}.grid{grid-template-columns:1fr}}</style></head><body><main class='shell'><div class='hero'><section><div class='eyebrow'>InterSystems IRIS management companion</div><h1>Know the surface<br>before you change it.</h1><p class='lede'>Ops Canvas turns a raw REST application list into a small, least-privilege briefing. It is read-only by design, so the signed-in administrator can inspect the system first and make changes intentionally.</p></section><aside class='status'><span>Connected namespace</span><strong id='namespace'></strong><span>IRIS runtime</span><strong id='version'></strong><code id='endpoint'></code></aside></div><section class='grid' id='roles'></section><section class='inventory'><header><div><div class='eyebrow'>Live management API feed</div><h2>REST application inventory</h2><p>Loaded with the current IRIS session from the documented Management API.</p></div><button class='action' id='copy'>Copy endpoint</button></header><div class='apps' id='apps'><div class='app'>Loading REST-enabled applications…</div></div><div class='footer'>Ops Canvas never stores credentials and does not mutate configuration. The Management Portal remains the authority for changes.</div></section></main><script>const state="_state_";const byId=id=>document.getElementById(id);byId('namespace').textContent=state.namespace;byId('version').textContent=state.productVersion;byId('endpoint').textContent=state.restAppsEndpoint;byId('roles').innerHTML=state.roles.map(role=>'<article class=card><span class=tag>'+role.resource+'</span><h2>'+role.title+'</h2><p>'+role.focus+'</p></article>').join('');byId('copy').onclick=async()=>{try{await navigator.clipboard.writeText(state.restAppsEndpoint);byId('copy').textContent='Endpoint copied'}catch(error){byId('copy').textContent='Copy unavailable'}};const escape=value=>String(value??'').replace(/[&<>]/g,char=>({'&':'&amp;','<':'&lt;','>':'&gt;'}[char]));const render=items=>{if(!items.length){byId('apps').innerHTML='<div class=message>No REST applications were returned for this namespace.</div>';return}byId('apps').innerHTML=items.map(app=>{const name=app.Name||app.name||app.Url||app.url||'Unnamed application';const url=app.Url||app.url||app.DispatchClass||app.dispatchClass||'Management API record';return '<article class=app><b>'+escape(name)+'</b><small>'+escape(url)+'</small></article>'}).join('')};fetch(state.restAppsEndpoint,{credentials:'same-origin',headers:{Accept:'application/json'}}).then(response=>{if(!response.ok)throw new Error('HTTP '+response.status);return response.json()}).then(data=>render(Array.isArray(data)?data:(data.restapps||data.items||[]))).catch(error=>{byId('apps').innerHTML='<div class=message>The Management API could not be read with this session. Sign in with a role that can view the target namespace, then refresh.</div>'});</script></body></html>"
    quit page
}

}
