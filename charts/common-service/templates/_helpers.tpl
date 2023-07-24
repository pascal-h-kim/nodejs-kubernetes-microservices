{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "common-service.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "common-service.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "common-service.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified deployment name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "common-service.deployment.fullname" -}}
{{- printf "%s-%s" (include "common-service.releaseLabel" .) (include "common-service.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "common-service.labels" -}}
helm.sh/chart: {{ include "common-service.chart" . }}
app.kubernetes.io/component: {{ .Values.component | default "unspecified" }}
{{ include "common-service.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "common-service.selectorLabels" -}}
app.kubernetes.io/name: {{ include "common-service.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Allow for the ability to override the release name used as a label in many places.
*/}}
{{- define "common-service.releaseLabel" -}}
{{- .Values.releaseLabelOverride | default .Release.Name | trunc 63 -}}
{{- end -}}

{{/*
Create the name of the deployment config map to use
*/}}
{{- define "common-service.configMapName" -}}
{{- if .Values.config.create -}}
    {{- printf "%s-%s" (include "common-service.releaseLabel" .) (include "common-service.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- else -}}
    {{ default "default" .Values.config.name }}
{{- end -}}
{{- end -}}