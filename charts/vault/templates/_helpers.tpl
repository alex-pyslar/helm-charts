{{- define "vault.fullname" -}}
{{- printf "%s-vault" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}