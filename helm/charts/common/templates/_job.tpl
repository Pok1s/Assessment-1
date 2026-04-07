{{/*
Renders the Job objects required by the chart.
*/}}
{{- define "common.job" }}
---
apiVersion: batch/v1
kind: Job
{{- $annotations := merge (.Values.controller.annotations | default dict) (include "common.annotations" $ | fromYaml) }}
metadata:
  name: {{ include "common.names.fullname" . }}
  {{- with (merge (.Values.controller.labels | default dict) (include "common.labels" $ | fromYaml)) }}
  labels: {{- toYaml . | nindent 4 }}
    app.kubernetes.io/type: "Job"
  {{- end }}
  {{- if $annotations }}
  annotations: {{- toYaml $annotations | nindent 4 }}
  {{- end }}
spec:
  {{- if .Values.job.parallelism }}
  parallelism: {{ .Values.job.parallelism }}
  {{- end }}
  {{- if .Values.job.completions }}
  completions: {{ .Values.job.completions }}
  {{- end }}
  {{- if .Values.job.activeDeadlineSeconds }}
  activeDeadlineSeconds: {{ .Values.job.activeDeadlineSeconds }}
  {{- end }}
  {{- if .Values.job.backoffLimit }}
  backoffLimit: {{ .Values.job.backoffLimit }}
  {{- end }}
  {{- if .Values.job.ttlSecondsAfterFinished }}
  ttlSecondsAfterFinished: {{ .Values.job.ttlSecondsAfterFinished }}
  {{- end }}
  template:
    metadata:
      {{- with (merge (.Values.controller.labels | default dict) (include "common.labels" $ | fromYaml)) }}
      labels: {{- toYaml . | nindent 8 }}
        app.kubernetes.io/type: "Job"
      {{- end }}
      {{- with include ("common.podAnnotations") . }}
      annotations:
        {{- . | nindent 8 }}
      {{- end }}
    spec:
      {{- with .Values.job.restartPolicy | default "Never" }}
      restartPolicy: {{ . }}
      {{- end }}
      {{- include "common.controller.pod" . | nindent 6 -}}
{{- end }}
