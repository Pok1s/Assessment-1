{{/*
This template serves as a blueprint for all Ingress objects that are created
within the common library.
*/}}
{{- define "common.classes.ingress" -}}
  {{- $fullName := include "common.names.fullname" . -}}
  {{- $ingressName := $fullName -}}
  {{- $values := .Values.ingress -}}

  {{- if hasKey . "ObjectValues" -}}
    {{- with .ObjectValues.ingress -}}
      {{- $values = . -}}
    {{- end -}}
  {{- end -}}

  {{- if and (hasKey $values "nameOverride") $values.nameOverride -}}
    {{- $ingressName = printf "%v-%v" $ingressName $values.nameOverride -}}
  {{- end -}}

  {{- $defaultServiceName := "" -}}
  {{- $defaultServicePort := dict -}}
  {{- if .Values.service }}
    {{- $primaryServiceName := include "common.service.primary" . -}}
    {{- $primaryService := get .Values.service $primaryServiceName -}}
    {{- if $primaryService }}
      {{- $defaultServiceName = $fullName -}}
      {{- if and (hasKey $primaryService "nameOverride") $primaryService.nameOverride -}}
        {{- $defaultServiceName = printf "%v-%v" $defaultServiceName $primaryService.nameOverride -}}
      {{- end -}}
      {{- if $primaryService.ports }}
        {{- $primaryPortName := include "common.classes.service.ports.primary" (dict "values" $primaryService) -}}
        {{- if $primaryPortName }}
          {{- $defaultServicePort = get $primaryService.ports $primaryPortName -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{- $isStable := include "common.capabilities.ingress.isStable" . -}}
  {{- if and $values.provisionGoogleManagedCert $values.tls }}
    {{- fail "Only one of Google Certs or TLS could be enabled" }}
  {{- end }}
---
apiVersion: {{ include "common.capabilities.ingress.apiVersion" . }}
kind: Ingress
metadata:
  name: {{ $ingressName }}
  {{- with (merge ($values.labels | default dict) (include "common.labels" $ | fromYaml)) }}
  labels: {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- $ingress_annotations := (merge ($values.annotations | default dict) (include "common.annotations" $ | fromYaml)) }}
  {{- if and (not $ingress_annotations) $values.provisionGoogleManagedCert }}
  annotations:
    networking.gke.io/managed-certificates: {{ $ingressName }}-certs
  {{- end }}
  {{- with $ingress_annotations }}
  annotations: {{- toYaml . | nindent 4 }}
  {{- if $values.provisionGoogleManagedCert }}
    networking.gke.io/managed-certificates: {{ $ingressName }}-certs
  {{- end }}
  {{- end }}
spec:
  {{- if and $isStable $values.ingressClassName }}
  ingressClassName: {{ $values.ingressClassName }}
  {{- end }}
  {{- if $values.tls }}
  tls:
    {{- range $values.tls }}
    - hosts:
        {{- range .hosts }}
        - {{ tpl . $ | quote }}
        {{- end }}
      {{- if .secretName }}
      secretName: {{ tpl .secretName $ | quote }}
      {{- end }}
    {{- end }}
  {{- end }}
  rules:
    {{ range $values.hosts }}
    - host: {{ tpl .host $ | quote }}
      http:
        paths:
          {{ range .paths }}
          {{- $service := $defaultServiceName -}}
          {{- $port := get $defaultServicePort "port" -}}
          {{- if .service }}
            {{- $service = default $service .service.name -}}
            {{- $port = default $port .service.port -}}
          {{- end -}}
          {{- if not $service }}
            {{- fail (printf "Ingress path %q must define service.name or chart must define a primary service" .path) }}
          {{- end -}}
          {{- if not $port }}
            {{- fail (printf "Ingress path %q must define service.port or chart must define a primary service port" .path) }}
          {{- end -}}
          - path: {{ tpl .path $ | quote }}
            {{- if $isStable }}
            pathType: {{ default "Prefix" .pathType }}
            {{- end }}
            backend:
              {{- if $isStable }}
              service:
                name: {{ $service }}
                port:
                  number: {{ $port }}
              {{- else }}
              serviceName: {{ $service }}
              servicePort: {{ $port }}
              {{- end }}
          {{ end }}
    {{ end }}
{{- if $values.provisionGoogleManagedCert }}
---
apiVersion: networking.gke.io/v1
kind: ManagedCertificate
metadata:
  name: {{ $ingressName }}-certs
spec:
  domains:
    {{- range $values.hosts }}
    - {{ tpl .host $ | quote }}
    {{- end }}
{{- end }}
{{- end }}