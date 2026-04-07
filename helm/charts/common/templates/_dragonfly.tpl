{{/*
Renders the Dragonfly objects required by the chart.
*/}}
{{- define "common.dragonfly" }}
---
apiVersion: dragonflydb.io/v1alpha1
kind: Dragonfly
{{- $annotations := merge (.Values.controller.annotations | default dict) (include "common.annotations" $ | fromYaml) }}
metadata:
  name: {{ include "common.names.fullname" . }}
  {{- with (merge (.Values.controller.labels | default dict) (include "common.labels" $ | fromYaml)) }}
  labels: {{- toYaml . | nindent 4 }}
    app.kubernetes.io/type: "Dragonfly"
  {{- end }}
  {{- if $annotations }}
  annotations: {{- toYaml $annotations | nindent 4 }}
  {{- end }}
spec:
  {{- with .Values.dragonfly }}
  {{- toYaml . | nindent 2 }}
  {{- else }}
  {}
  {{- end }}
{{- end }}
