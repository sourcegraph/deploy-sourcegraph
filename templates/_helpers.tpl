{{/* --------------- START OF TEMPLATE ------------- */}}

{{/* Emits environment variables */}}
{{- define "envVars" -}}
{{- range $k, $v := . -}}

{{- if $v }}
- name: {{ $k }}
  {{- if (typeIsLike "float64" $v) }}
  value: {{ printf "%g" $v | printf "%q" }}
  {{- else if (typeIsLike "bool" $v) }}
  value: {{ printf "%t" $v | printf "%q" }}
  {{- else }}
  value: {{ $v }}
  {{- end -}}
{{- end -}}

{{- end -}}
{{- end -}}


{{/* --------------- START OF TEMPLATE ------------- */}}

{{/* Collects config-related environment variables into the `.envVars` field of the argument. */}}
{{- define "collectEnv" -}}

{{- $envVars := (index . 0) -}}
{{- $toAdd := (index . 1) -}}

{{- range $k, $v := $toAdd -}}
{{- $_ := set $envVars $k $v -}}
{{- end -}}

{{- end -}}


{{/* --------------- START OF TEMPLATE ------------- */}}


{{/* Collects config-related environment variables into the `.envVars` field of the argument. */}}
{{- define "collectConfigEnv" -}}
{{- $_ := set .envVars "SOURCEGRAPH_CONFIG_FILE" "/etc/sourcegraph/config.json" -}}
{{- $_ := set .envVars "CONFIG_FILE_HASH" (include "expandedJSON" (dict "val" .Values.site "Files" .Files) | sha256sum) -}}
{{- end -}}

{{/* --------------- START OF TEMPLATE ------------- */}}

{{/* Collects tracing-related environment variables into the `.envVars` field of the argument. */}}
{{- define "collectTracingEnv" -}}
{{- $_ := set .envVars "LIGHTSTEP_PROJECT" .Values.site.lightstepProject -}}
{{- $_ := set .envVars "LIGHTSTEP_ACCESS_TOKEN" .Values.site.lightstepAccessToken -}}
{{- if .Values.site.lightstepAccessToken -}}
    {{- $_ := set .envVars "LIGHTSTEP_INCLUDE_SENSITIVE" "t" -}}
{{- end -}}
{{- end -}}

{{/* --------------- START OF TEMPLATE ------------- */}}

{{- define "collectCustomFrontendEnv" -}}
{{- $_ := set .envVars "DEPLOY_TYPE" "datacenter" -}}
{{- $_ := set .envVars "CORS_ORIGIN" .Values.site.corsOrigin -}}
{{- $_ := set .envVars "NO_GO_GET_DOMAINS" .Values.site.noGoGetDomains -}}
{{- $_ := set .envVars "SRC_APP_DISABLE_SUPPORT_SERVICES" "\"true\"" -}}
{{- $_ := set .envVars "SRC_APP_URL" .Values.site.appURL -}}
{{- if .Values.site.siteID -}}
    {{- $_ := set .envVars "TRACKING_APP_ID" (quote .Values.site.siteID) -}}
{{- end -}}
{{- $_ := set .envVars "SSO_USER_HEADER" .Values.site.ssoUserHeader -}}
{{- $_ := set .envVars "OIDC_OP" .Values.site.oidcProvider -}}
{{- $_ := set .envVars "OIDC_CLIENT_ID" .Values.site.oidcClientID -}}
{{- $_ := set .envVars "OIDC_CLIENT_SECRET" .Values.site.oidcClientSecret -}}
{{- $_ := set .envVars "OIDC_EMAIL_DOMAIN" .Values.site.oidcEmailDomain -}}
{{- $_ := set .envVars "OIDC_OVERRIDE_TOKEN" .Values.site.oidcOverrideToken -}}
{{- $_ := set .envVars "MAX_REPOS_TO_SEARCH" .Values.site.maxReposToSearch -}}
{{- if .Values.site.experimentIndexedSearch -}}
    {{- $_ := set .envVars "SEARCH_UNINDEXED_NOMISSING" "t" -}}
    {{- $_ := set .envVars "SEARCH10_INDEX_DEFAULT" "only" -}}
{{- end -}}
{{- end -}}

{{/* --------------- START OF TEMPLATE ------------- */}}

{{- define "collectPostgresEnv" -}}

{{- $_ := set .envVars "PGDATABASE" "sg" -}}
{{- $_ := set .envVars "PGHOST" "pgsql" -}}
{{- $_ := set .envVars "PGPASSWORD" "" -}}
{{- $_ := set .envVars "PGPORT" "\"5432\"" -}}
{{- $_ := set .envVars "PGSSLMODE" "disable" -}}
{{- $_ := set .envVars "PGUSER" "sg" -}}

{{- end -}}

{{/* --------------- START OF TEMPLATE ------------- */}}


{{- define "collectFrontendCommonEnv" -}}

{{- if .Values.site.htmlBodyBottom -}}
    {{- $_ := set .envVars "HTML_BODY_BOTTOM" .Values.site.htmlBodyBottom -}}
{{- end -}}

{{- if .Values.site.htmlBodyTop -}}
    {{- $_ := set .envVars "HTML_BODY_TOP" .Values.site.htmlBodyTop -}}
{{ end -}}

{{- if .Values.site.htmlHeadBottom -}}
    {{- $_ := set .envVars "HTML_HEAD_BOTTOM" .Values.site.htmlHeadBottom -}}
{{ end -}}

{{- if .Values.site.htmlHeadTop -}}
    {{- $_ := set .envVars "HTML_HEAD_TOP" .Values.site.htmlHeadTop -}}
{{ end -}}

{{- $_ := set .envVars "LSP_PROXY" "lsp-proxy:4388" -}}

{{- $_ := set .envVars "PUBLIC_REPO_REDIRECTS" "\"true\"" -}}
{{- $_ := set .envVars "REDIS_MASTER_ENDPOINT" "redis-cache:6379" -}}
{{- $_ := set .envVars "REPO_UPDATER_URL" "http://repo-updater:3182" -}}
{{- $_ := set .envVars "SEARCHER_URL" "k8s+http://searcher:3181" -}}
{{- $_ := set .envVars "SRC_GIT_SERVERS" (include "gitservers" .) -}}
{{- $_ := set .envVars "SRC_INDEXER" "indexer:3179" -}}
{{- $_ := set .envVars "SRC_LOG_LEVEL" "dbug" -}}
{{- $_ := set .envVars "SRC_SESSION_COOKIE_KEY" .Values.site.sessionCookieKey -}}
{{- $_ := set .envVars "SRC_SESSION_STORE_REDIS" "redis-store:6379" -}}
{{- $_ := set .envVars "SRC_SYNTECT_SERVER" "http://syntect-server:9238" -}}
{{- $_ := set .envVars "SRC_PROF_HTTP" ":6060" -}}
{{- $_ := set .envVars "SYMBOLS_URL" "k8s+http://symbols:3184" -}}

{{- end -}}

{{/* --------------- START OF TEMPLATE ------------- */}}

{{- define "gitservers" -}}
{{- include "joinFmt" (dict "count" (int (default 1 .Values.cluster.gitserver.shards)) "fmt" "gitserver-%d:3178" "sep" " ") -}}
{{- end -}}

{{/* --------------- START OF TEMPLATE ------------- */}}


{{/* joinFmt accepts a dictionary specifying "count", "fmt", and "sep" to prints out the joined formatted list string */}}
{{- define "joinFmt" -}}
{{- range $i, $v := (until (int (sub .count 1))) -}}{{- printf $.fmt (add $i 1) }}{{$.sep}}{{ end -}}
{{- printf .fmt .count -}}
{{- end -}}

{{/* --------------- START OF TEMPLATE ------------- */}}

{{/* expands an object into pretty-printed JSON */}}
{{- define "expandedJSON" -}}

{{- if (typeIsLike "map[string]interface {}" .val) -}}

{
{{- range $i, $k := (keys .val | sortAlpha) -}}{{ $v := (pluck $k $.val | first) }}
  {{ printf "%q" $k }}: {{ include "expandedJSON" (dict "val" $v "Files" $.Files) | indent 2 | trim }}{{ if (ne (add1 $i) (len $.val)) }},{{ end }}
{{- end }}
}
{{- else if (typeIsLike "[]interface {}" .val) -}}

[
{{- range $i, $e := .val }}
  {{ include "expandedJSON" (dict "val" $e "Files" $.Files) | indent 2 | trim }}{{ if (ne (add1 $i) (len $.val)) }},{{ end }}
{{- end }}
]

{{- else if (typeIsLike "string" .val) -}}
    {{ if not .val }}""{{ else }}{{ printf "%q" .val }}{{ end }}
{{- else if (typeIsLike "float64" .val) -}}
    {{ printf "%g" .val }}
{{- else if (typeIsLike "bool" .val) -}}
    {{ printf "%t" .val }}
{{- else if (typeIsLike "<nil>" .val) -}}
    null
{{- else -}}
    {{ call "error: unsupported JSON type" }}
{{- end -}}

{{- end -}}

{{/* --------------- START OF TEMPLATE ------------- */}}

{{/* Sets the `.ret` field of the argument to true if the language specified by `.lang` is enabled */}}
{{- define "hasLanguage" -}}

{{ $args := . }}
{{- $langservers := $args.langservers -}}
{{- $lang := $args.lang -}}

{{- $_ := set $args "ret" false -}}
{{- range $langserver := $langservers -}}
  {{- if (eq $langserver.language $lang) -}}
    {{- $_ := set $args "ret" "true" -}}
  {{- end -}}
{{- end -}}

{{- end -}}

{{/* --------------- START OF TEMPLATE ------------- */}}

{{- define "indexOrEmpty" -}}
{{- $keys := .keys -}}
{{- $obj := .obj -}}

{{- if (eq (len $keys) 0) -}}
    {{ $obj }}
{{- else if typeIsLike "map[string]interface {}" $obj -}}
    {{- if hasKey $obj (first $keys) -}}
        {{- include "indexOrEmpty" (dict "obj" (index $obj (first $keys)) "keys" (rest $keys)) -}}
    {{- else -}}
        {{- "" -}}
    {{- end -}}
{{- else -}}
    {{- "" -}}
{{- end -}}

{{- end -}}

{{/* --------------- START OF TEMPLATE ------------- */}}

{{- define "resourceRequirements" -}}
{{- $Values := index . 0 -}}
{{- $deploy := index . 1 -}}
{{- $container := index . 2 -}}

resources:
  limits:
    cpu: {{ include "indexOrEmpty" (dict "obj" $Values.cluster "keys" (list $deploy "containers" $container "limits" "cpu")) | quote }}
    memory: {{ include "indexOrEmpty" (dict "obj" $Values.cluster "keys" (list $deploy "containers" $container "limits" "memory")) | quote }}
  requests:
    cpu: {{ include "indexOrEmpty" (dict "obj" $Values.cluster "keys" (list $deploy "containers" $container "requests" "cpu")) | quote }}
    memory: {{ include "indexOrEmpty" (dict "obj" $Values.cluster "keys" (list $deploy "containers" $container "requests" "memory")) | quote }}
{{- end -}}


{{/* --------------- START OF TEMPLATE ------------- */}}


{{- define "mountCacheVolume" -}}
{{- $nodeSSDPath := index . 0 -}}

{{- if $nodeSSDPath -}}
- hostPath:
    path: {{ $nodeSSDPath }}/pod-tmp
  name: cache-ssd
{{- else -}}
- emptyDir: {}
  name: cache-ssd
{{- end -}}

{{- end -}}


{{/* --------------- START OF TEMPLATE ------------- */}}

{{- define "nodeSelector" -}}
{{- $Values := index . 0 -}}
{{- $deploy := index . 1 -}}

{{- if and (hasKey $Values.cluster $deploy) (hasKey (index $Values.cluster $deploy) "nodeSelector") -}}
nodeSelector:
{{- range $k, $v := (index $Values.cluster $deploy).nodeSelector }}
  {{ $k }}: {{ $v }}
{{- end -}}
{{- end -}}

{{- end -}}


{{/* --------------- START OF TEMPLATE ------------- */}}

{{- define "securityContext" -}}

{{- if .Values.cluster.securityContext -}}
securityContext:
{{- if .Values.cluster.securityContext.runAsUser }}
  runAsUser: {{ .Values.cluster.securityContext.runAsUser }}
{{- end -}}
{{- if .Values.cluster.securityContext.fsGroup }}
  fsGroup: {{ .Values.cluster.securityContext.fsGroup }}
{{- end -}}
{{- else -}}
securityContext:
  runAsUser: 0
{{- end -}}

{{- end -}}


{{/* --------------- START OF TEMPLATE ------------- */}} 

{{- define "jaeger" -}}

{{- if .Values.site.useJaeger -}}
- command:
  - /go/bin/agent-linux
  - --collector.host-port=jaeger-collector:14267
  image: {{ .Values.const.jaeger.agent.image }}
  name: jaeger-agent
  resources:
    limits:
      cpu: 100m
      memory: 100Mi
    requests:
      cpu: 100m
      memory: 100Mi
{{- end -}}

{{- end -}}


{{/* --------------- START OF TEMPLATE ------------- */}}

{{- define "volumeMounts" -}}

{{- $Values := (index . 0) -}}
{{- $deployment := (index . 1) -}}
{{- $container := (index . 2) -}}

{{- include "expandedYAML" (index (index $Values.cluster $deployment).containers $container).volumeMounts -}}

{{- end -}}


{{/* --------------- START OF TEMPLATE ------------- */}}

{{- define "commonVolumeMounts" -}}
{{- include "expandedYAML" .Values.cluster.commonVolumeMounts -}}
{{- end -}}


{{/* --------------- START OF TEMPLATE ------------- */}}

{{- define "commonVolumes" -}}
{{- include "expandedYAML" .Values.cluster.commonVolumes -}}
{{- end -}}


{{/* --------------- START OF TEMPLATE ------------- */}}

{{/* expands an object into pretty-printed YAML */}}
{{- define "expandedYAML" -}}
{{- if . }}{{ "\n" }}{{- include "_expandedYAML" . | trimSuffix "\n" -}}{{ end -}}
{{- end -}}


{{- define "_expandedYAML" -}}

{{- if (typeIsLike "map[string]interface {}" .) -}}

{{- if len . | eq 0 -}}{}{{- else -}}

{{- range $k, $v := . }}
{{- if (and $v (or (typeIsLike "[]interface {}" $v) (typeIsLike "map[string]interface {}" $v))) -}}
    {{ $k }}:{{ include "_expandedYAML" $v | trimSuffix "\n" | nindent 2 }}{{ "\n" }}
{{- else -}}
    {{ $k }}: {{ include "_expandedYAML" $v }}{{ "\n" }}
{{- end -}}
{{- end -}}

{{- end -}}

{{- else if (typeIsLike "[]interface {}" .) -}}

{{- if len . | eq 0 -}}[]{{- else -}}

{{- range $e := . -}}
{{- if (and $e (or (typeIsLike "[]interface {}" $e) (typeIsLike "map[string]interface {}" $e))) -}}
- {{ include "_expandedYAML" $e | trimSuffix "\n" | indent 2 | trimPrefix "  " }}
{{ else -}}
- {{ include "_expandedYAML" $e }}
{{ end -}}
{{- end -}}

{{- end -}}

{{- else if (typeIsLike "string" .) -}}
    {{- if not . }}{{ "" }}{{ else }}{{ . }}{{ end -}}
{{- else if (typeIsLike "float64" .) -}}
    {{ printf "%g" . }}
{{- else if (typeIsLike "bool" .) -}}
    {{ printf "%t" . }}
{{- else if (typeIsLike "<nil>" .) -}}
    null
{{- else -}}
    {{ call "error: unsupported JSON type" }}
{{- end -}}

{{- end -}}
