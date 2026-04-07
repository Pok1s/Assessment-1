{{/*
Renders the Keycloak objects required by the chart.
*/}}
{{- define "common.keycloak" }}
---
apiVersion: k8s.keycloak.org/v2alpha1
kind: Keycloak
{{- $annotations := merge (.Values.controller.annotations | default dict) (include "common.annotations" $ | fromYaml) }}
metadata:
  name: {{ include "common.names.fullname" . }}
  {{- with (merge (.Values.controller.labels | default dict) (include "common.labels" $ | fromYaml)) }}
  labels: {{- toYaml . | nindent 4 }}
    app.kubernetes.io/type: "Keycloak"
  {{- end }}
  {{- if $annotations }}
  annotations: {{- toYaml $annotations | nindent 4 }}
  {{- end }}
spec:
  {{- with .Values.keycloak }}
  {{- toYaml . | nindent 2 }}
  {{- else }}
  {}
  {{- end }}
{{- end }}
