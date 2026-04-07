{{/*
Renders the ScaledJob objects required by the chart.
*/}}
{{- define "common.scaledjob" }}
apiVersion: keda.sh/v1alpha1
kind: ScaledJob
metadata:
  name: {{ include "common.names.fullname" . }}
  {{- with (merge (.Values.controller.labels | default dict) (include "common.labels" $ | fromYaml) (.Values.podLabels | default dict)) }}
  labels: {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with (merge (.Values.controller.annotations | default dict) (include "common.annotations" $ | fromYaml)) }}
  annotations: {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  jobTargetRef:
    parallelism: {{ .Values.scaledjob.jobTargetRef.parallelism }}
    completions: {{ .Values.scaledjob.jobTargetRef.completions }}
    activeDeadlineSeconds: {{ .Values.scaledjob.jobTargetRef.activeDeadlineSeconds }}
    backoffLimit: {{ .Values.scaledjob.jobTargetRef.backoffLimit }}
    template:
      metadata:
        {{- with include ("common.podAnnotations") . }}
        annotations:
          {{- . | nindent 10 }}
        {{- end }}
        {{- with (merge (.Values.controller.labels | default dict) (include "common.labels" $ | fromYaml) (.Values.podLabels | default dict)) }}
        labels: {{- toYaml . | nindent 10 }}
        {{- end }}
      spec:
      {{- include "common.controller.pod" . | nindent 8 -}}
      {{- with .Values.scaledjob.jobTargetRef.restartPolicy | default "Never" }}
        restartPolicy: {{ . }}
	    {{- end }}
  pollingInterval: {{ .Values.scaledjob.pollingInterval }}
  successfulJobsHistoryLimit: {{ .Values.scaledjob.successfulJobsHistoryLimit }}
  failedJobsHistoryLimit: {{ .Values.scaledjob.failedJobsHistoryLimit }}
  envSourceContainerName: {{ include "common.names.fullname" . }}
  minReplicaCount: {{ .Values.scaledjob.minReplicaCount }}
  maxReplicaCount: {{ .Values.scaledjob.maxReplicaCount }}
  {{- with .Values.scaledjob.rollout }}
  rollout:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.scaledjob.scalingStrategy }}
  scalingStrategy:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  triggers:
  {{- range .Values.scaledjob.triggers }}
    {{- $triggerContext := dict "Values" $.Values "scalerType" "scaledjob" "trigger" . "Chart" $ }}
    {{- include (printf "common.controller.keda_trigger_%s" .type) $triggerContext | nindent 2 }}
  {{- end }}
{{- end }}
