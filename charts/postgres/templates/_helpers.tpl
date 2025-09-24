{{/* Вспомогательные функции, если нужны для кастомизации */}}
{{- define "my-postgres-stack.name" -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}