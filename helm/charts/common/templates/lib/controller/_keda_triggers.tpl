{{/*
Triggers parameters used by Keda Scaled Obects.
*/}}

{{/*
Trigger's parameters for Prometheus
@ref https://keda.sh/docs/2.14/scalers/prometheus/.
*/}}
{{- define "common.controller.keda_trigger_prometheus" }}
  - type: {{ .trigger.type }}
    {{ if eq .scalerType "scaledObject" }}
    metricType: {{ .trigger.metricType | default "AverageValue" }}
    {{ end }}
    metadata:
      serverAddress: {{ include "common.valuesrender" (dict "value" .trigger.metadata.serverAddress "context" .Chart) }}
      query: {{ include "common.valuesrender" (dict "value" .trigger.metadata.query "context" .Chart) }}
      {{ if .trigger.metadata.queryParameters }}
      queryParameters: {{ include "common.valuesrender" (dict "value" .trigger.metadata.queryParameters "context" .Chart) }}
      {{ end }}
      threshold: "{{ .trigger.metadata.threshold | default "1" }}"
      activationThreshold: "{{ .trigger.metadata.activationThreshold | default "0" }}"
      {{ if .trigger.metadata.namespace }}
      namespace: {{ .trigger.metadata.namespace }}
      {{ end }}
      ignoreNullValues: {{ (.trigger.metadata.ignoreNullValues | default "true") | quote }}
{{- end }}
{{- define "common.controller.keda_trigger_postgresql" }}
  - type: {{ .trigger.type }}
    metadata:
      query: {{ .trigger.metadata.query }}
      activationThreshold: "{{ .trigger.metadata.activationThreshold }}"
      targetQueryValue: "{{ .trigger.metadata.targetQueryValue }}"
    authenticationRef:
      name: {{ .trigger.triggerAuthentication }}
{{- end }}
{{- define "common.controller.keda_trigger_cpu" }}
{{- if eq .Chart.Values.controller.type "scaledjob" -}}
{{- fail  "scaledjob doesn't support CPU keda scaler" }}
{{- end }}
  - type: {{ .trigger.type }}
    metricType: {{ .trigger.metricType | default "Utilization" }}
    metadata:
      value: "{{ .trigger.metadata.value | default "80" }}"
      {{ if .trigger.metadata.containerName }}
      containerName: {{ .trigger.metadata.containerName }}
      {{ end }}
{{- end }}
{{- define "common.controller.keda_trigger_memory" }}
{{- if eq .Chart.Values.controller.type "scaledjob" -}}
{{- fail "scaledjob doesn't support MEMORY keda scaler" }}
{{- end }}
  - type: {{ .trigger.type }}
    metricType: {{ .trigger.metricType | default "Utilization" }}
    metadata:
      value: "{{ .trigger.metadata.value | default "80" }}"
      {{ if .trigger.metadata.containerName }}
      containerName: {{ .trigger.metadata.containerName }}
      {{ end }}
{{- end }}
