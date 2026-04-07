{{/*
This template serves as a blueprint for all HTTPRoute objects that are created
within the common library.
*/}}
{{- define "common.classes.httproute" -}}
  {{- $fullName := include "common.names.fullname" . -}}
  {{- $routeName := $fullName -}}
  {{- $values := .Values.route -}}

  {{- if hasKey . "ObjectValues" -}}
    {{- with .ObjectValues.route -}}
      {{- $values = . -}}
    {{- end -}}
  {{- end -}}

  {{- if and (hasKey $values "nameOverride") $values.nameOverride -}}
    {{- $routeName = printf "%v-%v" $routeName $values.nameOverride -}}
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

---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: {{ $routeName }}
spec:
  parentRefs:
    - group: gateway.networking.k8s.io
      kind: Gateway
      name: {{ $values.gatewayName | default $.Values.global.gatewayName | default "traefik-dev-internal-gateway" }}
      namespace: {{ $values.gatewayNamespace | default $.Values.global.gatewayNamespace | default "traefik" }}
      {{- if $values.listenerName }}
      sectionName: {{ $values.listenerName | default $.Values.global.defaultListener | default "https-dev-internal"}}
      {{- end }}
  hostnames:
    {{- range $values.hostnames }}
    - {{ tpl . $ | quote }}
    {{- end }}
  rules:
    {{- range $values.rules }}
    {{- if .matches }}
    - matches:
        {{- toYaml .matches | nindent 8 }}
      backendRefs:
    {{- else }}
    - backendRefs:
    {{- end }}
      {{- range .backends }}
        {{- $backendName := default $defaultServiceName .name -}}
        {{- $backendPort := default (get $defaultServicePort "port") .port -}}

        {{- if not $backendName -}}
          {{- fail (printf "HTTPRoute %q: backend name must be defined or chart must have a primary service" $routeName) -}}
        {{- end -}}
        
        {{- if not $backendPort -}}
          {{- fail (printf "HTTPRoute %q: backend port must be defined or chart must have a primary service port" $routeName) -}}
        {{- end }}  
        - group: ""
          kind: Service
          name: {{ $backendName }}
          port: {{ $backendPort }}
          weight: {{ if .weight }}{{ .weight }}{{ else }}1{{ end }}
      {{- end }}
      
      {{- if not .backends }}
        {{- $finalPort := get $defaultServicePort "port" -}}
        {{- if and $defaultServiceName $finalPort }}
        - group: ""
          kind: Service
          name: {{ $defaultServiceName }}
          port: {{ $finalPort }}
          weight: 1
        {{- else }}
          {{- fail (printf "HTTPRoute %q: no backends defined and no primary service found" $routeName) -}}
        {{- end }}
      {{- end }}
    {{- end }}
{{- end -}}