{{/*
VSO integration (Vault Secrets Operator).

Modes:
- Global: creates VaultConnection + VaultAuthGlobal once (vso.global.enabled=true).
- Service: creates VaultAuth + VaultStaticSecret per release/namespace (vso.service.enabled=true).

Contract:
- VaultAuth.spec.kubernetes.role == VaultStaticSecret.spec.vaultAuthRef == identity
- role-operator derives Vault ACL policy from VaultStaticSecret and ensures Vault role/policy named "identity".
*/}}

{{- define "common.vso" -}}
{{- $v := .Values.vso | default dict -}}
{{- if $v.enabled -}}
{{- include "common.vso.global" . -}}
{{- include "common.vso.service" . -}}
{{- end -}}
{{- end -}}


{{- define "common.vso.global" -}}
{{- $v := .Values.vso | default dict -}}
{{- $g := $v.global | default dict -}}
{{- $commonAnn := (include "common.annotations" . | fromYaml) | default dict -}}
{{- if and ($v.enabled) ($g.enabled | default false) -}}

{{- $c := $g.vaultConnection | default dict -}}
{{- $ag := $g.vaultAuthGlobal | default dict -}}

{{- $connName := required "vso.global.vaultConnection.name is required" ($c.name | default "") -}}
{{- $connNs := default .Release.Namespace ($c.namespace | default "") -}}
{{- $authgName := required "vso.global.vaultAuthGlobal.name is required" ($ag.name | default "") -}}
{{- $authgNs := default .Release.Namespace ($ag.namespace | default "") -}}

{{/*
Global resources (create once):
- VaultConnection configures Vault endpoint/TLS.
- VaultAuthGlobal provides shared defaults and allow-lists namespaces that may reference it.
*/}}
---
apiVersion: secrets.hashicorp.com/v1beta1
kind: VaultConnection
metadata:
  name: {{ $connName | quote }}
  namespace: {{ $connNs | quote }}
  {{- with $commonAnn }}
  annotations: {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  address: {{ required "vso.global.vaultConnection.address is required" ($c.address | default "") | quote }}
  {{- with $c.caCertSecretRef }}
  caCertSecretRef: {{ . | quote }}
  {{- end }}
  {{- if ($c.skipTLSVerify | default false) }}
  skipTLSVerify: true
  {{- end }}

---
apiVersion: secrets.hashicorp.com/v1beta1
kind: VaultAuthGlobal
metadata:
  name: {{ $authgName | quote }}
  namespace: {{ $authgNs | quote }}
  {{- with $commonAnn }}
  annotations: {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  vaultConnectionRef: {{ required "vso.global.vaultAuthGlobal.vaultConnectionRef is required" ($ag.vaultConnectionRef | default "") | quote }}

  allowedNamespaces:
  {{- toYaml ( $ag.allowedNamespaces | default (list "*") ) | nindent 2 }}

  defaultAuthMethod: {{ default "kubernetes" ($ag.defaultAuthMethod | default "") | quote }}

  kubernetes:
    mount: {{ default "kubernetes" (dig "kubernetes" "mount" "" $ag | default "kubernetes") | quote }}
    {{- with (dig "kubernetes" "audiences" nil $ag) }}
    audiences:
    {{- toYaml . | nindent 6 }}
    {{- end }}

{{- end -}}
{{- end -}}


{{- define "common.vso.service" -}}
{{- $v := .Values.vso | default dict -}}
{{- $s := $v.service | default dict -}}
{{- $commonAnn := (include "common.annotations" . | fromYaml) | default dict -}}
{{- if and ($v.enabled) ($s.enabled | default false) -}}

{{/*
Identity selection:
- identityBase -> identity = <namespace>-<identityBase>  (default; avoids cross-namespace collisions)
- identityFull -> identity = <identityFull>              (shared role name; use intentionally for shared secrets)
*/}}
{{- $full := ($s.identityFull | default "") -}}
{{- $base := ($s.identityBase | default "") -}}
{{- if and (not $full) (not $base) -}}
  {{- fail "vso.service.identityFull or vso.service.identityBase is required" -}}
{{- end -}}
{{- $identity := (ternary $full (printf "%s-%s" .Release.Namespace $base) (ne $full "")) | trunc 63 | trimSuffix "-" -}}
{{- $grefName := required "vso.service.vaultAuthGlobalRef.name is required" (dig "vaultAuthGlobalRef" "name" "" $s) -}}
{{- $grefNs := required "vso.service.vaultAuthGlobalRef.namespace is required" (dig "vaultAuthGlobalRef" "namespace" "" $s) -}}
{{- $sa := required "vso.service.kubernetes.serviceAccount is required" (dig "kubernetes" "serviceAccount" "" $s) -}}

{{/*
Service resources:
- VaultAuth defines how VSO authenticates to Vault.
- VaultStaticSecret declares what to read from Vault and what Kubernetes Secret to write.
*/}}
---
apiVersion: secrets.hashicorp.com/v1beta1
kind: VaultAuth
metadata:
  name: {{ $identity | quote }}
  namespace: {{ .Release.Namespace | quote }}
  {{- with $commonAnn }}
  annotations: {{- toYaml . | nindent 4 }}
  {{- end }}
  labels:
    app.kubernetes.io/instance: {{ .Release.Name }}
spec:
  vaultAuthGlobalRef:
    name: {{ $grefName | quote }}
    namespace: {{ $grefNs | quote }}
  method: kubernetes
  kubernetes:
    # Must match VaultStaticSecret.spec.vaultAuthRef
    role: {{ $identity | quote }}
    serviceAccount: {{ $sa | quote }}

{{ $items := $s.secrets | default list -}}
{{- if eq (len $items) 0 -}}
{{- fail "vso.service.secrets[] must have at least one item when vso.service.enabled=true" -}}
{{- end -}}

{{ range $i, $it := $items }}
{{- $n := required (printf "vso.service.secrets[%d].name is required" $i) ($it.name | default "") -}}
{{- $mount := required (printf "vso.service.secrets[%d].mount is required" $i) ($it.mount | default "") -}}
{{- $path := required (printf "vso.service.secrets[%d].path is required" $i) ($it.path | default "") -}}
{{- $dest := required (printf "vso.service.secrets[%d].dest is required" $i) ($it.dest | default "") -}}

---
apiVersion: secrets.hashicorp.com/v1beta1
kind: VaultStaticSecret
metadata:
  # Name is prefixed with identity for traceability (role/policy mapping).
  name: {{ printf "%s-%s" $identity $n | trunc 63 | trimSuffix "-" | quote }}
  namespace: {{ $.Release.Namespace | quote }}
  {{- with $commonAnn }}
  annotations: {{- toYaml . | nindent 4 }}
  {{- end }}
  labels:
    app.kubernetes.io/instance: {{ $.Release.Name }}
spec:
  # Reference to VaultAuth in the same namespace.
  vaultAuthRef: {{ $identity | quote }}
  type: {{ default "kv-v2" ($it.type | default "") | quote }}
  mount: {{ $mount | quote }}
  path: {{ $path | quote }}

  {{- with $it.version }}
  version: {{ . }}
  {{- end }}

  {{- with $it.refreshAfter }}
  refreshAfter: {{ . | quote }}
  {{- end }}

  destination:
    name: {{ $dest | quote }}
    create: true
    type: {{ default "Opaque" ($it.secretType | default "") | quote }}

  {{- with $it.transformation }}
    transformation:
    {{- toYaml . | nindent 6 }}
  {{- end }}

  {{- with $it.rollout }}
  rolloutRestartTargets:
    - kind: {{ default "Deployment" (.kind | default "") | quote }}
      name: {{ required (printf "vso.service.secrets[%d].rollout.name is required when rollout is set" $i) (.name | default "") | quote }}
      {{- with .namespace }}
      namespace: {{ . | quote }}
      {{- end }}
  {{- end }}

{{- end }}{{/* range */}}

{{- end -}}
{{- end -}}
