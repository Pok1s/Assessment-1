{{- define "common.rbac.rolebindings" -}}
{{- $root := . -}}
{{- $items := default (list) .Values.rbac.roleBindings -}}
{{- range $i, $rb := $items }}
{{- $ns := default $root.Release.Namespace $rb.namespace -}}
{{- $name := default (printf "%s-%s-rb-%d" $root.Release.Name $root.Chart.Name $i) $rb.name -}}
{{- if not $rb.roleRef }}
  {{- fail (printf "rbac.roleBindings[%d].roleRef is required" $i) -}}
{{- end }}
{{- if or (not $rb.roleRef.kind) (not $rb.roleRef.name) }}
  {{- fail (printf "rbac.roleBindings[%d].roleRef.kind and roleRef.name are required" $i) -}}
{{- end }}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: {{ $name | trunc 63 | trimSuffix "-" }}
  namespace: {{ $ns | quote }}
  labels:
    {{- include "common.labels" $root | nindent 4 }}
    {{- with $rb.labels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- with $rb.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: {{ $rb.roleRef.kind | quote }}
  name: {{ $rb.roleRef.name | quote }}
subjects:
  {{- if $rb.subjects }}
  {{- toYaml $rb.subjects | nindent 2 }}
  {{- else }}
  - kind: ServiceAccount
    name: {{ include "common.names.serviceAccountName" $root }}
    namespace: {{ $root.Release.Namespace }}
  {{- end }}
{{- end }}
{{- end -}}