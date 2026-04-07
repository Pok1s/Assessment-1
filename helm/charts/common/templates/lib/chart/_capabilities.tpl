{{/* Allow KubeVersion to be overridden. */}}
{{- define "common.capabilities.ingress.kubeVersion" -}}
  {{- default .Capabilities.KubeVersion.Version .Values.kubeVersionOverride -}}
{{- end -}}

{{/* Return the appropriate apiVersion for Ingress objects */}}
{{- define "common.capabilities.ingress.apiVersion" -}}
  {{- print "networking.k8s.io/v1" -}}
  {{- if semverCompare "<1.19" (include "common.capabilities.ingress.kubeVersion" .) -}}
    {{- print "beta1" -}}
  {{- end -}}
{{- end -}}

{{/* Check Ingress stability */}}
{{- define "common.capabilities.ingress.isStable" -}}
  {{- if eq (include "common.capabilities.ingress.apiVersion" .) "networking.k8s.io/v1" -}}
    {{- true -}}
  {{- end -}}
{{- end -}}

{{/* Return the appropriate apiVersion for RBAC resources. */}}
{{- define "common.capabilities.rbac.apiVersion" -}}
  {{- if semverCompare "<1.17-0" .Capabilities.KubeVersion.Version -}}
    {{- print "rbac.authorization.k8s.io/v1beta1" -}}
  {{- else -}}
    {{- print "rbac.authorization.k8s.io/v1" -}}
  {{- end -}}
{{- end -}}
