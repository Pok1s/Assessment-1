{{/*
This template serves as a blueprint for horizontal pod autoscaler objects that are created
using the common library.
*/}}
{{- define "common.classes.hpa" -}}
  {{- if .Values.autoscaling.enabled -}}
  {{- if and ( .Values.scaledObject.enabled ) ( .Values.autoscaling.enabled ) -}}
  {{ fail "Only Keda or HPA should be enabled at same time" }}
  {{- end -}}
    {{- $hpaName := include "common.names.fullname" . -}}
    {{- $targetName := include "common.names.fullname" . }}
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: {{ $hpaName }}
  labels: {{- include "common.labels" $ | nindent 4 }}
  annotations: {{- include "common.annotations" $ | nindent 4 }}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: {{ include "common.names.controllerType" . }}
    name: {{ .Values.autoscaling.target | default $targetName }}
{{- with .Values.autoscaling }}
  {{- if hasKey . "minReplicas" }}
    {{- if or (not .minReplicas) (eq (int .minReplicas) 0) }}
      {{ fail "minReplicas should be set and can't be 0" }}
    {{- end }}
  minReplicas: {{ .minReplicas }}
  {{- else }}
  minReplicas: 1
  {{- end }}
  {{- if hasKey . "maxReplicas" }}
    {{- if or (not .maxReplicas) (eq (int .maxReplicas) 0) }}
      {{ fail "maxReplicas should be set and can't be 0" }}
    {{- end }}
  maxReplicas: {{ .maxReplicas }}
  {{- else }}
  maxReplicas: 3
  {{- end }}
{{- end }}
  metrics:
    {{- if .Values.autoscaling.targetCPUUtilizationPercentage }}
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: {{ .Values.autoscaling.targetCPUUtilizationPercentage }}
    {{- end }}
    {{- if .Values.autoscaling.targetMemoryUtilizationPercentage }}
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: {{ .Values.autoscaling.targetMemoryUtilizationPercentage }}
    {{- end }}
  {{- end -}}
{{- end -}}
