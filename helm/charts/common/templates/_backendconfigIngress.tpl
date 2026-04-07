{{/*
Renders the BackendConfig objects required by the chart.
*/}}
{{- define "common.backendconfigIngress" -}}
---
apiVersion: cloud.google.com/v1
kind: BackendConfig
metadata:
  name: {{ include "common.names.fullname" . }}
  {{- with (merge (.Values.controller.labels | default dict) (include "common.labels" $ | fromYaml)) }}
  labels: {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with (merge (.Values.controller.annotations | default dict) (include "common.annotations" $ | fromYaml)) }}
  annotations: {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- with .Values.backendconfig.timeoutSec}}
  timeoutSec: {{ . }}
  {{- end }}
  healthCheck:
    {{- with .Values.backendconfig.healthCheck.timeoutSec}}
    timeoutSec: {{ . }}
    {{- end }}
    {{- with .Values.backendconfig.healthCheck.checkIntervalSec}}
    checkIntervalSec: {{ . }}
    {{- end }}
    {{- with .Values.backendconfig.healthCheck.healthyThreshold}}
    healthyThreshold: {{ . }}
    {{- end }}
    {{- with .Values.backendconfig.healthCheck.unhealthyThreshold}}
    unhealthyThreshold: {{ . }}
    {{- end }}
    {{- with .Values.backendconfig.healthCheck.port}}
    port: {{ . }}
    {{- end }}
    {{- with .Values.backendconfig.healthCheck.type}}
    type: {{ . }}
    {{- end }}
    {{- with .Values.backendconfig.healthCheck.requestPath}}
    requestPath: {{ . }}
    {{- end }}
  {{ if .Values.backendconfig.securityPolicy }}
  {{- with .Values.backendconfig.securityPolicy.name}}
  securityPolicy:
    name: {{ . }}
  {{- end }}
  {{- end }}
{{- end }}
