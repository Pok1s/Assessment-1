{{/*
Renders the serviceMonitor objects required by the chart.
*/}}
{{- define "common.serviceMonitor" }}
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: {{ include "common.names.fullname" . }}
  {{- with (merge (.Values.controller.labels | default dict) (include "common.labels" $ | fromYaml)) }}
  labels: {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with (merge (.Values.controller.annotations | default dict) (include "common.annotations" $ | fromYaml)) }}
  annotations: {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  endpoints:
      {{- with .Values.serviceMonitor.port | default "metrics"}}
    - port: {{ . }}
      {{- end }}
      {{- with .Values.serviceMonitor.path | default "/metrics"}}
      path: {{ . }}
      {{- end }}
      {{- with .Values.serviceMonitor.interval | default "30s"}}
      interval: {{ . }}
      {{- end }}
      {{- with .Values.serviceMonitor.scrapeTimeout | default "30s"}}
      scrapeTimeout: {{ . }}
      {{- end }}
      {{- if .Values.serviceMonitor.honorLabels }}
      honorLabels: {{ .Values.serviceMonitor.honorLabels }}
      {{- end }}
      {{- if .Values.serviceMonitor.metricRelabelings }}
      metricRelabelings: {{- toYaml .Values.serviceMonitor.metricRelabelings | nindent 6 }}
      {{- end }}
      {{- if .Values.serviceMonitor.relabelings }}
      relabelings: {{ toYaml .Values.serviceMonitor.relabelings | nindent 6 }}
      {{- end }}
  {{- if .Values.serviceMonitor.jobLabel }}
  jobLabel: {{ .Values.serviceMonitor.jobLabel }}
  {{- end }}
  namespaceSelector:
    matchNames:
      - {{ .Release.Namespace }}
  selector:
      matchLabels:
        {{- include "common.labels.selectorLabels" . | nindent 8 }}
{{- end }}
