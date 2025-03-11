import{_ as e,c as t,o as i,ae as s}from"./chunks/framework.Dh1jimFm.js";const b=JSON.parse('{"title":"FieldMappingsUtil Class","description":"","frontmatter":{},"headers":[],"relativePath":"miscellaneous/FieldMappingsUtil.md","filePath":"miscellaneous/FieldMappingsUtil.md"}'),r={name:"miscellaneous/FieldMappingsUtil.md"};function n(l,a,h,d,o,p){return i(),t("div",null,a[0]||(a[0]=[s('<h1 id="fieldmappingsutil-class" tabindex="-1">FieldMappingsUtil Class <a class="header-anchor" href="#fieldmappingsutil-class" aria-label="Permalink to &quot;FieldMappingsUtil Class&quot;">​</a></h1><p><code>APIVERSION: 62</code><code>STATUS: ACTIVE</code></p><p>Created by: DC Solutions Created on: 2019-11-06</p><p>Description: Utility class to parse out and use Field Mapping metadata to copy fields from one object (source) to another (target)</p><p><strong>See</strong> FieldMapping custom metadata type</p><h2 id="fields" tabindex="-1">Fields <a class="header-anchor" href="#fields" aria-label="Permalink to &quot;Fields&quot;">​</a></h2><h3 id="mappingsbytargetobj" tabindex="-1"><code>mappingsByTargetObj</code> <a class="header-anchor" href="#mappingsbytargetobj" aria-label="Permalink to &quot;`mappingsByTargetObj`&quot;">​</a></h3><h4 id="signature" tabindex="-1">Signature <a class="header-anchor" href="#signature" aria-label="Permalink to &quot;Signature&quot;">​</a></h4><div class="language-apex vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">apex</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">public</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> mappingsByTargetObj</span></span></code></pre></div><h4 id="type" tabindex="-1">Type <a class="header-anchor" href="#type" aria-label="Permalink to &quot;Type&quot;">​</a></h4><p>Map&lt;String,Map&lt;String,Field_Mapping__mdt&gt;&gt;</p><hr><h3 id="objectapiname" tabindex="-1"><code>objectAPIName</code> <a class="header-anchor" href="#objectapiname" aria-label="Permalink to &quot;`objectAPIName`&quot;">​</a></h3><h4 id="signature-1" tabindex="-1">Signature <a class="header-anchor" href="#signature-1" aria-label="Permalink to &quot;Signature&quot;">​</a></h4><div class="language-apex vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">apex</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">private</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> objectAPIName</span></span></code></pre></div><h4 id="type-1" tabindex="-1">Type <a class="header-anchor" href="#type-1" aria-label="Permalink to &quot;Type&quot;">​</a></h4><p>String</p><hr><h3 id="testmappings" tabindex="-1"><code>testMappings</code> <a class="header-anchor" href="#testmappings" aria-label="Permalink to &quot;`testMappings`&quot;">​</a></h3><p><code>TESTVISIBLE</code></p><h4 id="signature-2" tabindex="-1">Signature <a class="header-anchor" href="#signature-2" aria-label="Permalink to &quot;Signature&quot;">​</a></h4><div class="language-apex vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">apex</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">private</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;"> static</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> testMappings</span></span></code></pre></div><h4 id="type-2" tabindex="-1">Type <a class="header-anchor" href="#type-2" aria-label="Permalink to &quot;Type&quot;">​</a></h4><p>List&lt;Field_Mapping__mdt&gt;</p><h2 id="properties" tabindex="-1">Properties <a class="header-anchor" href="#properties" aria-label="Permalink to &quot;Properties&quot;">​</a></h2><h3 id="globaldescribe" tabindex="-1"><code>globalDescribe</code> <a class="header-anchor" href="#globaldescribe" aria-label="Permalink to &quot;`globalDescribe`&quot;">​</a></h3><p>Return schema information for all objects in org</p><h4 id="signature-3" tabindex="-1">Signature <a class="header-anchor" href="#signature-3" aria-label="Permalink to &quot;Signature&quot;">​</a></h4><div class="language-apex vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">apex</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">public</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;"> static</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;"> globalDescribe</span></span></code></pre></div><h4 id="type-3" tabindex="-1">Type <a class="header-anchor" href="#type-3" aria-label="Permalink to &quot;Type&quot;">​</a></h4><p>Map&lt;String,Schema.sObjectType&gt;</p><h2 id="constructors" tabindex="-1">Constructors <a class="header-anchor" href="#constructors" aria-label="Permalink to &quot;Constructors&quot;">​</a></h2><h3 id="fieldmappingsutil-processname" tabindex="-1"><code>FieldMappingsUtil(processName)</code> <a class="header-anchor" href="#fieldmappingsutil-processname" aria-label="Permalink to &quot;`FieldMappingsUtil(processName)`&quot;">​</a></h3><h4 id="signature-4" tabindex="-1">Signature <a class="header-anchor" href="#signature-4" aria-label="Permalink to &quot;Signature&quot;">​</a></h4><div class="language-apex vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">apex</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">public</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;"> FieldMappingsUtil</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(String processName)</span></span></code></pre></div><h4 id="parameters" tabindex="-1">Parameters <a class="header-anchor" href="#parameters" aria-label="Permalink to &quot;Parameters&quot;">​</a></h4><table tabindex="0"><thead><tr><th>Name</th><th>Type</th><th>Description</th></tr></thead><tbody><tr><td>processName</td><td>String</td><td></td></tr></tbody></table><h2 id="methods" tabindex="-1">Methods <a class="header-anchor" href="#methods" aria-label="Permalink to &quot;Methods&quot;">​</a></h2><h3 id="buildsoqlquery-targetobjectname-blnsourcefields" tabindex="-1"><code>buildSoqlQuery(targetObjectName, blnSourceFields)</code> <a class="header-anchor" href="#buildsoqlquery-targetobjectname-blnsourcefields" aria-label="Permalink to &quot;`buildSoqlQuery(targetObjectName, blnSourceFields)`&quot;">​</a></h3><p>Build and return a SOQL query from configured field names for our process. targetObjectName indicates the target object for which mappings are being returned.</p><h4 id="signature-5" tabindex="-1">Signature <a class="header-anchor" href="#signature-5" aria-label="Permalink to &quot;Signature&quot;">​</a></h4><div class="language-apex vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">apex</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">public</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;"> String</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;"> buildSoqlQuery</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">String</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;"> targetObjectName</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">Boolean</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;"> blnSourceFields</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div><h4 id="parameters-1" tabindex="-1">Parameters <a class="header-anchor" href="#parameters-1" aria-label="Permalink to &quot;Parameters&quot;">​</a></h4><table tabindex="0"><thead><tr><th>Name</th><th>Type</th><th>Description</th></tr></thead><tbody><tr><td>targetObjectName</td><td>String</td><td>API Name of target object</td></tr><tr><td>blnSourceFields</td><td>Boolean</td><td>true if building soql for source object, false if building it for</td></tr><tr><td>targetObjectName.</td><td></td><td></td></tr></tbody></table><h4 id="return-type" tabindex="-1">Return Type <a class="header-anchor" href="#return-type" aria-label="Permalink to &quot;Return Type&quot;">​</a></h4><p><strong>String</strong></p><p>comma-separated list of fields to be retrieved suitable for a soql query</p><hr><h3 id="getsrcfields-targetobjectname" tabindex="-1"><code>getSrcFields(targetObjectName)</code> <a class="header-anchor" href="#getsrcfields-targetobjectname" aria-label="Permalink to &quot;`getSrcFields(targetObjectName)`&quot;">​</a></h3><p>Return the set of source fields for the given target object mappings.</p><h4 id="signature-6" tabindex="-1">Signature <a class="header-anchor" href="#signature-6" aria-label="Permalink to &quot;Signature&quot;">​</a></h4><div class="language-apex vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">apex</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">public</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;"> Set</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">&lt;</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">String</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">&gt; </span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;">getSrcFields</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">String</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;"> targetObjectName</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div><h4 id="parameters-2" tabindex="-1">Parameters <a class="header-anchor" href="#parameters-2" aria-label="Permalink to &quot;Parameters&quot;">​</a></h4><table tabindex="0"><thead><tr><th>Name</th><th>Type</th><th>Description</th></tr></thead><tbody><tr><td>targetObjectName</td><td>String</td><td>API name of target object mappings</td></tr></tbody></table><h4 id="return-type-1" tabindex="-1">Return Type <a class="header-anchor" href="#return-type-1" aria-label="Permalink to &quot;Return Type&quot;">​</a></h4><p><strong>Set&lt;String&gt;</strong></p><p>set of source fields for targetObjectName mappings</p><hr><h3 id="mapvalues-toobject-fromobject" tabindex="-1"><code>mapValues(toObject, fromObject)</code> <a class="header-anchor" href="#mapvalues-toobject-fromobject" aria-label="Permalink to &quot;`mapValues(toObject, fromObject)`&quot;">​</a></h3><p>Map values from the source record (fromObject) to the target record (toObject) using our configured mappings</p><h4 id="signature-7" tabindex="-1">Signature <a class="header-anchor" href="#signature-7" aria-label="Permalink to &quot;Signature&quot;">​</a></h4><div class="language-apex vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">apex</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">public</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;"> void</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;"> mapValues</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">SObject</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;"> toObject</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, </span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">SObject</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;"> fromObject</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div><h4 id="parameters-3" tabindex="-1">Parameters <a class="header-anchor" href="#parameters-3" aria-label="Permalink to &quot;Parameters&quot;">​</a></h4><table tabindex="0"><thead><tr><th>Name</th><th>Type</th><th>Description</th></tr></thead><tbody><tr><td>toObject</td><td>SObject</td><td>instance of configured source object</td></tr><tr><td>fromObject</td><td>SObject</td><td>instance of configured target object to copy values to</td></tr></tbody></table><h4 id="return-type-2" tabindex="-1">Return Type <a class="header-anchor" href="#return-type-2" aria-label="Permalink to &quot;Return Type&quot;">​</a></h4><p><strong>void</strong></p><hr><h3 id="mapvalues-mapping-toobject-fromobject" tabindex="-1"><code>mapValues(mapping, toObject, fromObject)</code> <a class="header-anchor" href="#mapvalues-mapping-toobject-fromobject" aria-label="Permalink to &quot;`mapValues(mapping, toObject, fromObject)`&quot;">​</a></h3><p>Internal method to map individual value for prop on fromObject to toField on toObject.</p><h4 id="signature-8" tabindex="-1">Signature <a class="header-anchor" href="#signature-8" aria-label="Permalink to &quot;Signature&quot;">​</a></h4><div class="language-apex vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">apex</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">private</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;"> void</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;"> mapValues</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">Field_Mapping__mdt</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;"> mapping</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, </span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">SObject</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;"> toObject</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, </span><span style="--shiki-light:#005CC5;--shiki-dark:#79B8FF;">SObject</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;"> fromObject</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div><h4 id="parameters-4" tabindex="-1">Parameters <a class="header-anchor" href="#parameters-4" aria-label="Permalink to &quot;Parameters&quot;">​</a></h4><table tabindex="0"><thead><tr><th>Name</th><th>Type</th><th>Description</th></tr></thead><tbody><tr><td>mapping</td><td>Field_Mapping__mdt</td><td>Configuration details for the field currently being mapped from</td></tr><tr><td>fromObject to toObject</td><td></td><td></td></tr><tr><td>toObject</td><td>SObject</td><td>instance of configured source object</td></tr><tr><td>fromObject</td><td>SObject</td><td>instance of configured target object to copy values to</td></tr></tbody></table><h4 id="return-type-3" tabindex="-1">Return Type <a class="header-anchor" href="#return-type-3" aria-label="Permalink to &quot;Return Type&quot;">​</a></h4><p><strong>void</strong></p><hr><h3 id="isvalidobjectname-objname" tabindex="-1"><code>isValidObjectName(objName)</code> <a class="header-anchor" href="#isvalidobjectname-objname" aria-label="Permalink to &quot;`isValidObjectName(objName)`&quot;">​</a></h3><p>Return true or false to indicate if objName is a valid object</p><h4 id="signature-9" tabindex="-1">Signature <a class="header-anchor" href="#signature-9" aria-label="Permalink to &quot;Signature&quot;">​</a></h4><div class="language-apex vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">apex</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">public</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;"> static</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;"> boolean</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;"> isValidObjectName</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">String</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;"> objName</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div><h4 id="parameters-5" tabindex="-1">Parameters <a class="header-anchor" href="#parameters-5" aria-label="Permalink to &quot;Parameters&quot;">​</a></h4><table tabindex="0"><thead><tr><th>Name</th><th>Type</th><th>Description</th></tr></thead><tbody><tr><td>objName</td><td>String</td><td>API Name of object to verify</td></tr></tbody></table><h4 id="return-type-4" tabindex="-1">Return Type <a class="header-anchor" href="#return-type-4" aria-label="Permalink to &quot;Return Type&quot;">​</a></h4><p><strong>boolean</strong></p><p>true if objName is a valid API Object Name</p><hr><h3 id="isvalidfield-objname-fieldname" tabindex="-1"><code>isValidField(objName, fieldName)</code> <a class="header-anchor" href="#isvalidfield-objname-fieldname" aria-label="Permalink to &quot;`isValidField(objName, fieldName)`&quot;">​</a></h3><p>Return true or false to indicate if fieldName is a valid field on object named objName</p><h4 id="signature-10" tabindex="-1">Signature <a class="header-anchor" href="#signature-10" aria-label="Permalink to &quot;Signature&quot;">​</a></h4><div class="language-apex vp-adaptive-theme"><button title="Copy Code" class="copy"></button><span class="lang">apex</span><pre class="shiki shiki-themes github-light github-dark vp-code" tabindex="0"><code><span class="line"><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">public</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;"> static</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;"> boolean</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;"> isValidField</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">(</span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">String</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;"> objName</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">, </span><span style="--shiki-light:#D73A49;--shiki-dark:#F97583;">String</span><span style="--shiki-light:#6F42C1;--shiki-dark:#B392F0;"> fieldName</span><span style="--shiki-light:#24292E;--shiki-dark:#E1E4E8;">)</span></span></code></pre></div><h4 id="parameters-6" tabindex="-1">Parameters <a class="header-anchor" href="#parameters-6" aria-label="Permalink to &quot;Parameters&quot;">​</a></h4><table tabindex="0"><thead><tr><th>Name</th><th>Type</th><th>Description</th></tr></thead><tbody><tr><td>objName</td><td>String</td><td>API Name of object to verify</td></tr><tr><td>fieldName</td><td>String</td><td>API Name of field to check objName for validity</td></tr></tbody></table><h4 id="return-type-5" tabindex="-1">Return Type <a class="header-anchor" href="#return-type-5" aria-label="Permalink to &quot;Return Type&quot;">​</a></h4><p><strong>boolean</strong></p><p>true if fieldName on objName is valid</p>',95)]))}const g=e(r,[["render",n]]);export{b as __pageData,g as default};
