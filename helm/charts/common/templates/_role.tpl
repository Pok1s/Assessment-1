{{- define "common.rbac.roles" -}}
{{- $root := . -}}
{{- $items := default (list) .Values.rbac.roles -}}
{{- range $i, $r := $items }}
{{- $ns := default $root.Release.Namespace $r.namespace -}}
{{- $name := default (printf "%s-%s-role-%d" $root.Release.Name $root.Chart.Name $i) $r.name -}}
{{- if not $r.rules }}
  {{- fail (printf "rbac.roles[%d].rules is required" $i) -}}
{{- end }}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: {{ $name | trunc 63 | trimSuffix "-" }}
  namespace: {{ $ns | quote }}
  labels:
    {{- include "common.labels" $root | nindent 4 }}
    {{- with $r.labels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- with $r.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
rules:
  {{- toYaml $r.rules | nindent 2 }}
{{- end }}
{{- end -}}