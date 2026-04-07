{{/* Common annotations shared across objects */}}
{{- define "common.annotations" -}}
  {{- with .Values.global.annotations }}
    {{- range $k, $v := . }}
      {{- $name := $k }}
      {{- $value := tpl $v $ }}
{{ $name }}: {{ quote $value }}
    {{- end }}
  {{- end }}
{{- end -}}

{{/* Determine the Pod annotations used in the controller */}}
{{- define "common.podAnnotations" -}}
  {{- if .Values.podAnnotations -}}
    {{- $anns := dict -}}

    {{/* Vault Injector: always prefix role with namespace (<ns>-<role>) */}}
    {{- range $k, $v := .Values.podAnnotations -}}
      {{- if eq $k "vault.hashicorp.com/role" -}}
        {{- $_ := set $anns $k (printf "%s-%s" $.Release.Namespace $v) -}}
      {{- else -}}
        {{- $_ := set $anns $k $v -}}
      {{- end -}}
    {{- end -}}

    {{- tpl (toYaml $anns) . | nindent 0 -}}
  {{- end -}}

  {{- $configMapsFound := false -}}
  {{- range $name, $configmap := .Values.configmap -}}
    {{- if $configmap.enabled -}}
      {{- $configMapsFound = true -}}
    {{- end -}}
  {{- end -}}
  {{- if $configMapsFound -}}
    {{- printf "checksum/config: %v" (include ("common.configmap") . | sha256sum) | nindent 0 -}}
  {{- end -}}
{{- end -}}
