{{- define "common.serviceAccount" }}
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ include "common.names.serviceAccountName" . }}
  # --- Labels (merge base + overrides from values) ---
  {{- $baseLabels := (include "common.labels" $ | fromYaml) | default dict }}
  {{- $extraLabels := (.Values.serviceAccount.labels | default dict) }}
  {{- $labels := merge (deepCopy $baseLabels) (deepCopy $extraLabels) }}
  {{- if $labels }}
  labels: {{- toYaml $labels | nindent 4 }}
  {{- end }}
  # --- Annotations (merge base + overrides from values) ---
  {{- $baseAnn := (include "common.annotations" $ | fromYaml) | default dict }}
  {{- $extraAnn := (.Values.serviceAccount.annotations | default dict) }}
  {{- $ann := merge (deepCopy $baseAnn) (deepCopy $extraAnn) }}
  {{- if $ann }}
  annotations: {{- toYaml $ann | nindent 4 }}
  {{- end }}
{{- if hasKey .Values.serviceAccount "automountServiceAccountToken" }}
automountServiceAccountToken: {{ .Values.serviceAccount.automountServiceAccountToken }}
{{- end }}
{{- end }}