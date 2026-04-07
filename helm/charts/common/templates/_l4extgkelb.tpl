{{/*
Renders the l4 GKE load balancer service object required by the chart.
*/}}
{{- define "common.l4gkelb" -}}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ printf "%s-l4-lb" (include "common.names.fullname" .) }}
  {{- with (merge (.Values.controller.labels | default dict) (include "common.labels" $ | fromYaml)) }}
  labels: {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with (merge (.Values.controller.annotations | default dict) (include "common.annotations" $ | fromYaml)) }}
  annotations: {{- toYaml . | nindent 4 }}
  {{- end }}
    {{/* This is L4 so it should never be proxified */}}
    external-dns.alpha.kubernetes.io/cloudflare-proxied: "false"
    external-dns.alpha.kubernetes.io/hostname: {{ .Values.l4gkelb.host }}
  {{ if eq .Values.l4gkelb.type "external" }}
    cloud.google.com/l4-rbs: "enabled"
  {{ else }}
    networking.gke.io/load-balancer-type: "Internal"
  {{ end }}
  {{ if .Values.l4gkelb.allowGlobalAccess }}
    networking.gke.io/internal-load-balancer-allow-global-access:: "true"
  {{ end }}
spec:
  type: LoadBalancer
  externalTrafficPolicy: Cluster
  ports:
  - name: {{ .Values.l4gkelb.targetPort }}
    port: {{ .Values.l4gkelb.port }}
    protocol: {{ .Values.l4gkelb.protocol }}
    targetPort: {{ .Values.l4gkelb.targetPort }}
  selector:
    {{- include "common.labels.selectorLabels" . | nindent 4 }}
{{- end }}
