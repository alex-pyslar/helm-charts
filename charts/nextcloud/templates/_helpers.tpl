{{- define "nextcloud.fullname" -}}
{{- printf "%s-nextcloud" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}