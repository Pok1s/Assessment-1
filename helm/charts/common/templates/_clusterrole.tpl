{{- define "common.rbac.clusterroles" -}}
{{- $sa := .Values.serviceAccount | default dict -}}
{{- $rbac := $sa.rbac | default dict -}}
{{- $enabled := eq (toString ($rbac.enabled | default "false")) "true" -}}

{{- if $enabled -}}
  {{- $root := . -}}
  {{- $items := default (list) $rbac.clusterRoles -}}
  {{- range $i, $cr := $items }}
    {{- $name := default (printf "%s-%s-cr-%d" $root.Release.Name $root.Chart.Name $i) $cr.name -}}
    {{- if and $cr.aggregationRule $cr.rules }}
      {{- fail (printf "serviceAccount.rbac.clusterRoles[%d]: use either aggregationRule or rules, not both" $i) -}}
    {{- end }}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: {{ $name | trunc 63 | trimSuffix "-" }}
  labels:
    {{- include "common.labels" $root | nindent 4 }}
    {{- with $cr.labels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- with $cr.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- if $cr.aggregationRule }}
aggregationRule:
  {{- toYaml $cr.aggregationRule | nindent 2 }}
{{- else if $cr.rules }}
rules:
  {{- toYaml $cr.rules | nindent 2 }}
{{- else }}
rules: []
{{- end }}
  {{- end }}
{{- end -}}
{{- end -}}