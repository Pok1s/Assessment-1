{{/*
This template serves as the blueprint for the PodDisruptionBudget objects that are created
within the common library.
*/}}
{{- define "common.pdb" -}}
---
{{- if .Values.controller.enabled -}}
{{- $controller := .Values.controller.type -}}
{{- if and (ne $controller "statefulset") (ne $controller "deployment") -}}
{{- fail (printf "Not valid controller type for use pdb (%s)" $controller) }}
{{- end }}
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: {{ include "common.names.fullname" . }}
  {{- with (merge (.Values.controller.labels | default dict) (include "common.labels" $ | fromYaml)) }}
  labels: {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with (merge (.Values.controller.annotations | default dict) (include "common.annotations" $ | fromYaml)) }}
  annotations: {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  selector:
    matchLabels:
      {{- include "common.labels.selectorLabels" . | nindent 6 }}
  {{- if .Values.pdb.minAvailable }}
  minAvailable: {{ .Values.pdb.minAvailable }}
  {{- end }}
  {{- if .Values.pdb.maxUnavailable }}
  maxUnavailable: {{ .Values.pdb.maxUnavailable }}
  {{- end }}
{{- end }}
{{- end }}
