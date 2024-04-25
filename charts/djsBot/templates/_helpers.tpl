{{/*
Expand the name of the chart.
*/}}
{{- define "djsBot.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "djsBot.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "djsBot.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "djsBot.labels" -}}
helm.sh/chart: {{ include "djsBot.chart" . }}
{{ include "djsBot.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "djsBot.selectorLabels" -}}
app.kubernetes.io/name: {{ include "djsBot.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Selector labels dashboard
*/}}
{{- define "djsBot.dashboard.selectorLabels" -}}
app.kubernetes.io/name: app.kubernetes.io/name: {{ print (include "djsBot.name" .) "-" .Values.dashboard.deploymentName }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Selector labels lavalink
*/}}
{{- define "djsBot.lavalink.selectorLabels" -}}
app.kubernetes.io/name: app.kubernetes.io/name: {{ print (include "djsBot.name" .) "-" .Values.lavalink.deploymentName }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Selector labels postgresDb
*/}}
{{- define "djsBot.postgresDb.selectorLabels" -}}
app.kubernetes.io/name: app.kubernetes.io/name: {{ print (include "djsBot.name" .) "-" .Values.postgresDb.deploymentName }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}