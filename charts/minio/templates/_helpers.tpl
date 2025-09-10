{{- define "minio.fullname" -}}
{{- printf "%s-minio" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}