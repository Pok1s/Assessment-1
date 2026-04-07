{{/*
Renders the VMRule alerts objects required by the chart.
*/}}
{{- define "chart.alerts" -}}
{{- $globalcontext := . -}}
{{- $name := include "common.names.fullname" . }}
{{- $namespace := .Release.Namespace }}
{{- if .Values.alertRules -}}
{{- $values := .Values.alertRules -}}
---
apiVersion: operator.victoriametrics.com/v1beta1
kind: VMRule
metadata:
  name: {{ printf "%v-%v" $name "alerts" }}
  namespace: {{ $namespace }}
spec:
  groups:
    - name: {{ printf "%v-%v" $name "alerts" }}
      rules:
        {{- range $rulename, $rules := $values }}
        {{- if not $rules.annotations }}
        {{ fail "Annotations for Alert are required" }}
        {{- end -}}
        {{- if not $rules.annotations.description }}
        {{ fail "Description for Alert is required" }}
        {{- end -}}
        {{- if not $rules.annotations.summary }}
        {{ fail "Summary for Alert is required" }}
        {{- end -}}
        {{- if not $rules.annotations.runbook_url }}
        {{ fail "Runbook for Alert is required" }}
        {{- end -}}
        {{- if not $rules.thresholds }}
        {{ fail "At least one threshold is required" }}
        {{- end -}}
        {{- with $globalcontext -}}
        {{ $severity := "" }}
        {{- range $threshold, $value := $rules.thresholds -}}
        {{- if or (eq ($threshold | toString) "critical") (eq ($threshold | toString) "P1") -}}
        {{- $severity = "critical" -}}
        {{- else if or (eq ($threshold | toString) "warning") (eq ($threshold | toString) "P2") -}}
        {{- $severity = "warning" -}}
        {{- else if or (eq ($threshold | toString) "info") (eq ($threshold | toString) "P3") -}}
        {{- $severity = "info" -}}
        {{- else if or (eq ($threshold | toString) "log") (eq ($threshold | toString) "P4") -}}
        {{- $severity = "log" -}}
        {{- end }}
        - alert: {{ printf "%v-%v" $rulename $severity }}
          {{- with $rules.annotations }}
          annotations: {{ toYaml . | nindent 12 }}
          {{- end }}
          expr: |
          {{- $promql := include "common.valuesrender" (dict "value" $rules.promql "context" $) -}}
          {{- $value := include "common.valuesrender" (dict "value" $value "context" $) -}}
          {{- printf "(%s %s %s)" $promql $rules.compare $value | nindent 12 }}
          for: {{ $rules.duration }}
          labels:
            severity: {{ $severity }}
            namespace: {{ $namespace }}
            {{- if $rules.webhooks -}}
            {{ range $severity_hook, $url := $rules.webhooks }}
            {{ if eq $severity_hook $severity }}
            {{ printf "%v_uptime_webhook_url" $severity_hook }}: {{ $url }}
            {{- end }}
            {{- end }}
            {{- end }}
            {{- with $rules.labels -}}
            {{ toYaml . | trim | nindent 12 }}
            {{- end -}}
        {{- end }}
        {{- end }}
        {{- end }}
{{- end }}
{{- end -}}
