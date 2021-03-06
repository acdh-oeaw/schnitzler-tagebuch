xquery version "3.0";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;

declare variable $exist:base_url := "https://schnitzler-tagebuch.acdh.oeaw.ac.at";

if ($exist:path eq '') then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{request:get-uri()}/"/>
    </dispatch>
else if (contains($exist:path, "/entity/")) then
    let $ent_id := tokenize(substring-after($exist:path, "/entity/"), "/")
    return
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{$exist:base_url}/pages/hits.html?searchkey={$ent_id}"/>
    </dispatch>
else if (contains($exist:path, "/v/")) then
    let $ed := tokenize(substring-after($exist:path, "/v/"), "/")
    return
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="https://schnitzler-tagebuch.acdh.oeaw.ac.at/pages/show.html?document={$ed[2]}.xml&amp;directory={$ed[1]}"/>
    </dispatch>
else if ($exist:path eq "/") then
    (: forward root path to index.xql :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="pages/index.html"/>
    </dispatch>

else if (ends-with($exist:resource, ".html")) then
    (: the html page is run through view.xql to expand templates :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <view>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </view>
		<error-handler>
			<forward url="{$exist:controller}/error-page.html" method="get"/>
			<forward url="{$exist:controller}/modules/view.xql"/>
		</error-handler>
    </dispatch>
(: Resource paths starting with $shared are loaded from the shared-resources app :)
else if (contains($exist:path, "/$shared/")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="/shared-resources/{substring-after($exist:path, '/$shared/')}">
            <set-header name="Cache-Control" value="max-age=3600, must-revalidate"/>
        </forward>
    </dispatch>

(: Resource paths starting with $app-root are loaded from the application's root collection :)
else if (contains($exist:path,"$app-root")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/{substring-after($exist:path, '$app-root/')}">
            <set-header name="Cache-Control" value="no"/>
        </forward>
    </dispatch>

else
    (: everything else is passed through :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
    </dispatch>
