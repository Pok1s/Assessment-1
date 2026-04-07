{{/*
Renders the KEDA's ScaledObject.
*/}}
{{- define "common.scaledObject" -}}
{{- $controllerType := include "common.names.controllerType" . -}}
{{- if and ( .Values.scaledObject.enabled ) ( .Values.autoscaling.enabled ) -}}
{{ fail "Only Keda or HPA should be enabled at the same time" }}
{{- end -}}
{{- if and ( ne $controllerType "Deployment") ( ne $controllerType "StatefulSet" ) -}}
{{ fail "Keda support only Deployment or StatefulSet controller types" }}
{{- end -}}
{{- $kedaName := include "common.names.fullname" . -}}
---
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: {{ $kedaName }}
  annotations:
  {{- with include "common.podAnnotations" . }}
    {{- . | nindent 10 }}
  {{- end }}
  {{ if .Values.scaledObject.paused }}
    autoscaling.keda.sh/paused-replicas: {{ .Values.scaledObject.pausedReplicas | default 0 | quote }}
    autoscaling.keda.sh/paused: "true"
  {{ end }}
spec:
  scaleTargetRef:
    kind: {{ $controllerType }}
    name: {{ include "common.names.fullname" . }}
  pollingInterval: {{ .Values.scaledObject.pollingInterval | default "30" }}
  cooldownPeriod: {{ .Values.scaledObject.cooldownPeriod | default "300" }}
  minReplicaCount: {{ .Values.scaledObject.minReplicaCount | default "0" }}
  maxReplicaCount: {{ .Values.scaledObject.maxReplicaCount | default "2" }}
  advanced:
    horizontalPodAutoscalerConfig:
      behavior:
        scaleDown:
          stabilizationWindowSeconds: {{ .Values.scaledObject.stabilizationWindowSeconds | default "300" }}
  triggers:
  {{- range .Values.scaledObject.triggers }}
    {{- $triggerContext := dict "Values" $.Values "scalerType" "scaledObject" "trigger" . "Chart" $ }}
    {{- include (printf "common.controller.keda_trigger_%s" .type) $triggerContext | nindent 2 }}
  {{- end }}
{{- end }}
