{{/*
Renders a value that contains template.
Usage:
{{ include "common.valuesrender" ( dict "value" .Values.path.to.the.Value "context" $) }}
*/}}
{{- define "common.valuesrender" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}
