{{- define "common.clusterrolebinding" -}}
{{- $sa := .Values.serviceAccount | default dict -}}
{{- $rbac := $sa.rbac | default dict -}}
{{- $enabled := eq (toString ($rbac.enabled | default "false")) "true" -}}
{{- if $enabled -}}
  {{- $crb := $rbac.clusterRoleBinding | default dict -}}
  {{- $existing := and (hasKey $crb "existingName") (ne (toString $crb.existingName) "") -}}
  {{- $create   := and (hasKey $crb "create") (eq (toString $crb.create) "true") -}}

  {{- if and $existing $create -}}
    {{- fail "Invalid RBAC config: set either serviceAccount.rbac.clusterRoleBinding.existingName OR serviceAccount.rbac.clusterRoleBinding.create=true, not both." -}}
  {{- end -}}

  {{- if $existing -}}
    {{- /* Use pre-created CRB: render nothing */ -}}
  {{- else if $create -}}
    {{- $name := default (include "common.names.serviceAccountName" .) $crb.name -}}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: {{ $name | trunc 63 | trimSuffix "-" }}
  labels: {{- include "common.labels" $ | nindent 4 }}
  {{- with $crb.annotations }}
  annotations: {{- toYaml . | nindent 4 }}
  {{- end }}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: {{ required "serviceAccount.rbac.clusterRoleBinding.roleRef.kind is required" $crb.roleRef.kind }}
  name: {{ required "serviceAccount.rbac.clusterRoleBinding.roleRef.name is required" $crb.roleRef.name }}
subjects:
  {{- if $crb.subjects }}
  {{- toYaml $crb.subjects | nindent 2 }}
  {{- else }}
  - kind: ServiceAccount
    name: {{ include "common.names.serviceAccountName" $ }}
    namespace: {{ $.Release.Namespace }}
  {{- end }}
  {{- end -}}
{{- end -}}
{{- end -}}