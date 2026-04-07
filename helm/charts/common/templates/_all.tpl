{{/*
Main entrypoint for the common library chart. It will render all underlying templates based on the provided values.
Fix: add hard YAML document separators between every rendered resource block to prevent YAML merging.
*/}}
{{- define "common.all" -}}
  {{- /* Merge the local chart values and the common chart defaults */ -}}
  {{- include "common.values.setup" . -}}

  {{ "\n---\n" }}
  {{ include "common.configmap" . | nindent 0 }}

  {{ "\n---\n" }}
  {{- include "common.pvc" . | nindent 0 -}}

  {{ "\n---\n" }}
  {{- include "common.pv" . | nindent 0 -}}

  {{- $sa := .Values.serviceAccount | default dict -}}
  {{- $rbacEnabled := and $sa $sa.rbac (eq (toString $sa.rbac.enabled) "true") -}}

  {{- if .Values.serviceAccount.create -}}
    {{ "\n---\n" }}
    {{- include "common.serviceAccount" . | nindent 0 -}}
  {{- end -}}

  {{- if $rbacEnabled -}}
    {{- $rbacCtx := deepCopy . -}}
    {{- $_ := set $rbacCtx.Values "rbac" $sa.rbac -}}

    {{ "\n---\n" }}
    {{- include "common.rbac.roles" $rbacCtx | nindent 0 -}}

    {{ "\n---\n" }}
    {{- include "common.rbac.rolebindings" $rbacCtx | nindent 0 -}}

    {{ "\n---\n" }}
    {{- include "common.rbac.clusterroles" $rbacCtx | nindent 0 -}}

    {{ "\n---\n" }}
    {{- include "common.clusterrolebinding" $rbacCtx | nindent 0 -}}
  {{- end -}}

  {{ "\n---\n" }}
  {{- include "common.vso" . | nindent 0 -}}

  {{- if .Values.controller.enabled -}}
    {{ "\n---\n" }}
    {{- if eq .Values.controller.type "deployment" -}}
      {{- include "common.deployment" . | nindent 0 -}}
    {{- else if eq .Values.controller.type "daemonset" -}}
      {{- include "common.daemonset" . | nindent 0 -}}
    {{- else if eq .Values.controller.type "statefulset" -}}
      {{- include "common.statefulset" . | nindent 0 -}}
    {{- else if eq .Values.controller.type "cronjob" -}}
      {{- include "common.cronjob" . | nindent 0 -}}
    {{- else if eq .Values.controller.type "job" -}}
      {{- include "common.job" . | nindent 0 -}}
    {{- else if eq .Values.controller.type "dragonfly" -}}
      {{- include "common.dragonfly" . | nindent 0 -}}
    {{- else if eq .Values.controller.type "keycloak" -}}
      {{- include "common.keycloak" . | nindent 0 -}}
    {{- else if eq .Values.controller.type "scaledjob" -}}
      {{- include "common.scaledjob" . | nindent 0 -}}
    {{- else -}}
      {{- fail (printf "Not a valid controller.type (%s)" .Values.controller.type) -}}
    {{- end -}}
  {{- end -}}

  {{ "\n---\n" }}
  {{ include "common.classes.hpa" . | nindent 0 }}

  {{ "\n---\n" }}
  {{ include "common.service" . | nindent 0 }}

  {{ "\n---\n" }}
  {{ include "common.ingress" . | nindent 0 }}

  {{ "\n---\n" }}
  {{ include "common.httproute" . | nindent 0 }}

  {{- if .Values.serviceMonitor.enabled -}}
    {{ "\n---\n" }}
    {{- include "common.serviceMonitor" . | nindent 0 -}}
  {{- end -}}

  {{- if .Values.secret -}}
    {{ "\n---\n" }}
    {{ include "common.secret" . | nindent 0 }}
  {{- end -}}

  {{- if and .Values.backendconfig.enabled (eq .Values.backendconfig.type "ingress") -}}
    {{ "\n---\n" }}
    {{ include "common.backendconfigIngress" . | nindent 0 }}
  {{- end -}}

  {{- if and .Values.backendconfig.enabled (eq .Values.backendconfig.type "gateway") -}}
    {{ "\n---\n" }}
    {{ include "common.backendconfigGateway" . | nindent 0 }}
  {{- end -}}

  {{- if .Values.pdb.enabled -}}
    {{ "\n---\n" }}
    {{ include "common.pdb" . | nindent 0 }}
  {{- end -}}

  {{- if .Values.alertRules -}}
    {{ "\n---\n" }}
    {{ include "chart.alerts" . | nindent 0 }}
  {{- end -}}

  {{- if .Values.serviceAccount.role -}}
    {{ "\n---\n" }}
    {{ include "common.clusterrolebinding" . | nindent 0 }}
  {{- end -}}

  {{- if .Values.scaledObject.enabled -}}
    {{ "\n---\n" }}
    {{ include "common.scaledObject" . | nindent 0 }}
  {{- end -}}

  {{- if .Values.l4gkelb.enabled -}}
    {{ "\n---\n" }}
    {{ include "common.l4gkelb" . | nindent 0 }}
  {{- end -}}

{{- end -}}
