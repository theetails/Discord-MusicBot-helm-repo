{{/*
Expand the name of the chart.
*/}}
{{- define "djs-bot.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "djs-bot.fullname" -}}
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
{{- define "djs-bot.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "djs-bot.labels" -}}
helm.sh/chart: {{ include "djs-bot.chart" . }}
{{ include "djs-bot.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "djs-bot.selectorLabels" -}}
app.kubernetes.io/name: {{ include "djs-bot.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Selector labels dashboard
*/}}
{{- define "djs-bot.dashboard.selectorLabels" -}}
app.kubernetes.io/name: app.kubernetes.io/name: {{ print (include "djs-bot.name" .) "-" .Values.dashboard.deployment-name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Selector labels lavalink
*/}}
{{- define "djs-bot.lavalink.selectorLabels" -}}
app.kubernetes.io/name: app.kubernetes.io/name: {{ print (include "djs-bot.name" .) "-" .Values.lavalink.deployment-name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Selector labels postgres-db
*/}}
{{- define "djs-bot.postgres-db.selectorLabels" -}}
app.kubernetes.io/name: app.kubernetes.io/name: {{ print (include "djs-bot.name" .) "-" .Values.postgres-db.deployment-name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}