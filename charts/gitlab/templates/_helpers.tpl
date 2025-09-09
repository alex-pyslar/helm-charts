{{- define "gitlab.fullname" -}}
{{- printf "%s-gitlab" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}