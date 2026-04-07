{{/*
Renders the BackendConfig objects required by the chart.
*/}}
{{- define "common.backendconfigGateway" -}}
---
apiVersion: networking.gke.io/v1
kind: GCPBackendPolicy
metadata:
  name: {{ include "common.names.fullname" . }}
  {{- with (merge (.Values.controller.labels | default dict) (include "common.labels" $ | fromYaml)) }}
  labels: {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with (merge (.Values.controller.annotations | default dict) (include "common.annotations" $ | fromYaml)) }}
  annotations: {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  default:
    {{ if .Values.backendconfig.gatewayLogs }}
    logging:
      enabled: true
      {{/*
      Converts to value between 0 and 1,000,000. 0 is 0%, 1,000,000 is 100%.
      */}}
      sampleRate: {{ mul .Values.backendconfig.logSamplingPercentage 10000 | int }}
    {{- end }}
    {{ if .Values.backendconfig.securityPolicy }}
    {{- with .Values.backendconfig.securityPolicy.name}}
    securityPolicy: {{ . }}
    {{- end }}
    {{- end }}
    {{- with .Values.backendconfig.timeoutSec}}
    timeoutSec: {{ . }}
    {{- end }}
  targetRef:
    group: ""
    kind: Service
    name: {{ include "common.names.fullname" . }}
---
apiVersion: networking.gke.io/v1
kind: HealthCheckPolicy
metadata:
  name: {{ include "common.names.fullname" . }}
spec:
  default:
    {{- with .Values.backendconfig.healthCheck.checkIntervalSec}}
    checkIntervalSec: {{ . }}
    {{- end }}
    {{- with .Values.backendconfig.healthCheck.timeoutSec}}
    timeoutSec: {{ . }}
    {{- end }}
    {{- with .Values.backendconfig.healthCheck.healthyThreshold}}
    healthyThreshold: {{ . }}
    {{- end }}
    {{- with .Values.backendconfig.healthCheck.unhealthyThreshold}}
    unhealthyThreshold: {{ . }}
    {{- end }}
    {{- with .Values.backendconfig.healthCheck.logConfig}}
    logConfig:
      enabled: {{ . }}
    {{- end }}
    config:
      type: HTTP
      httpHealthCheck:
        portSpecification: USE_FIXED_PORT
        {{- with .Values.backendconfig.healthCheck.port}}
        port: {{ . }}
        {{- end }}
        {{- with .Values.backendconfig.healthCheck.requestPath}}
        requestPath: {{ . }}
        {{- end }}
  targetRef:
    group: ""
    kind: Service
    name: {{ include "common.names.fullname" . }}
{{- end }}
