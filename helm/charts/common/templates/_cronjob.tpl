{{/*
Renders the CronJob objects required by the chart.
*/}}
{{- define "common.cronjob" }}
---
apiVersion: batch/v1
kind: CronJob
{{- $annotations := merge (.Values.controller.annotations | default dict) (include "common.annotations" $ | fromYaml) }}
metadata:
  name: {{ include "common.names.fullname" . }}
  {{- with (merge (.Values.controller.labels | default dict) (include "common.labels" $ | fromYaml)) }}
  labels: {{- toYaml . | nindent 4 }}
  {{- end }}
    app.kubernetes.io/type: "CronJob"
  {{- if $annotations }}
  annotations: {{- toYaml $annotations | nindent 4 }}
  {{- end }}
spec:
  schedule: "{{ .Values.cronJob.schedule }}"
  {{- with .Values.cronJob.concurrencyPolicy | default "Forbid"}}
  concurrencyPolicy: {{ . }}
  {{- end }}
  {{- with .Values.cronJob.successfulJobsHistoryLimit | default 3}}
  successfulJobsHistoryLimit: {{ . }}
  {{- end }}
  {{- with .Values.cronJob.failedJobsHistoryLimit | default 3}}
  failedJobsHistoryLimit: {{ . }}
  {{- end }}
  {{- with .Values.cronJob.startingDeadlineSeconds | default 120}}
  startingDeadlineSeconds: {{ . }}
  {{- end }}
  {{- with .Values.cronJob.suspend | default false}}
  suspend: {{ . }}
  {{- end }}
  jobTemplate:
    spec:
      {{- if .Values.cronJob.activeDeadlineSeconds }}
      activeDeadlineSeconds: {{ .Values.cronJob.activeDeadlineSeconds }}
      {{- end }}
      {{- if .Values.cronJob.backoffLimit }}
      backoffLimit: {{ .Values.cronJob.backoffLimit }}
      {{- end }}
      {{- if .Values.cronJob.completions }}
      completions: {{ .Values.cronJob.completions }}
      {{- end }}
      {{- if .Values.cronJob.parallelism }}
      parallelism: {{ .Values.cronJob.parallelism }}
      {{- end }}
      template:
        metadata:
          {{- with (merge (.Values.controller.labels | default dict) (include "common.labels" $ | fromYaml)) }}
          labels: {{- toYaml . | nindent 12 }}
            app.kubernetes.io/type: "CronJob"
          {{- end }}
          {{- if $annotations }}
          annotations: {{- toYaml $annotations | nindent 12 }}
          {{- end }}
        spec:
      {{- with .Values.cronJob.restartPolicy | default "Never" }}
          restartPolicy: {{ . }}
	    {{- end }}
      {{- include "common.controller.pod" . | nindent 10 -}}

{{- end }}
