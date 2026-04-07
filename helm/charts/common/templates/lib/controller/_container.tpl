{{- /* The main container included in the controller */ -}}
{{- define "common.controller.mainContainer" -}}
{{- $name := include "common.names.fullname" . -}}
- name: {{ $name }}
  image: {{ printf "%s:%s" .Values.image.repository (default .Chart.AppVersion .Values.image.tag) | quote }}
  imagePullPolicy: {{ .Values.image.pullPolicy }}
  {{- with .Values.workingDir }}
  workingDir: {{ . | quote }}
  {{- end }}
  {{- with .Values.command }}
  command:
    {{- if kindIs "string" . }}
    - {{ . }}
    {{- else }}
      {{ toYaml . | nindent 4 }}
    {{- end }}
  {{- end }}
  {{- with .Values.args }}
  args:
    {{- if kindIs "string" . }}
    - {{ . }}
    {{- else }}
    {{ toYaml . | nindent 4 }}
    {{- end }}
  {{- end }}
  {{- with .Values.securityContext }}
  securityContext:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.lifecycle }}
  lifecycle:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.termination.messagePath }}
  terminationMessagePath: {{ . }}
  {{- end }}
  {{- with .Values.termination.messagePolicy }}
  terminationMessagePolicy: {{ . }}
  {{- end }}

  {{- with .Values.env }}
  env:
    {{- get (fromYaml (include "common.controller.env_vars" $)) "env" | toYaml | nindent 4 -}}
  {{- end }}
  {{ $envfrom := false }}
  {{- range $name, $configmap := .Values.configmap }}
    {{- if $configmap.envfrom -}}
      {{ $envfrom = true }}
    {{- end }}
  {{- end }}
  {{- if or .Values.envFrom .Values.secret $envfrom }}
  envFrom:
    {{- with .Values.envFrom }}
      {{- toYaml . | nindent 4 }}
    {{- end }}
    {{- if .Values.secret }}
    - secretRef:
        name: {{ include "common.names.fullname" . }}
    {{- end }}
    {{- range $confname, $configmap := .Values.configmap }}
    {{- if and $configmap.enabled $configmap.envfrom }}
    {{- $configmapValues := $configmap }}
    {{- $_ := set $ "ObjectValues" (dict "configmap" $configmapValues) }}
    {{- $tmp_name := get $.Values.configmap $confname }}
    {{- $configMapName := printf "%v-%v" $name $tmp_name.nameOverride }}
    - configMapRef:
        name: {{ $configMapName }}
    {{- end }}
    {{- end }}
  {{- end }}
  {{- range .Values.service -}}
    {{- if .enabled }}
  ports:
    {{- end }}
  {{- end -}}
  {{- include "common.controller.ports" . | trim | nindent 4 }}
  {{- with (include "common.controller.volumeMounts" . | trim) }}
  volumeMounts:
    {{- nindent 4 . }}
  {{- end }}
  {{- include "common.controller.probes" . | trim | nindent 2 }}
  {{- with .Values.resources }}
  resources:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end -}}

