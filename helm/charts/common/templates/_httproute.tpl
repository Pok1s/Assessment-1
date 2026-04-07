{{/* Renders the HTTPRoute objects required by the chart */}}
{{- define "common.httproute" -}}
  {{- range $name, $route := .Values.route }}
    {{- if $route.enabled -}}
      {{- $routeValues := $route -}}

      {{/* Sets default name, if no nameOverride */}}
      {{- if not $routeValues.nameOverride -}}
        {{- $_ := set $routeValues "nameOverride" $name -}}
      {{- end -}}

      {{/* Passing values to a render classes */}}
      {{- $_ := set $ "ObjectValues" (dict "route" $routeValues) -}}
      {{ include "common.classes.httproute" $ }}
    {{- end }}
  {{- end }}
{{- end }}