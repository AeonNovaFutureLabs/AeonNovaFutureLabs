{{/*
----------------------------------------------------------------------------
File: _helpers.tpl
Location: /Volumes/mattstack/VSCode/AeonNovaFutureLabs/helm/ai-components/templates/
Purpose: Helper templates for AI components
Security Level: Confidential
Owner: Infrastructure Team
Version: 1.0
Last Modified: 2025-02-08
----------------------------------------------------------------------------
*/}}

{{/*
Expand the name of the chart.
*/}}
{{- define "ai-components.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "ai-components.fullname" -}}
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
{{- define "ai-components.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "ai-components.labels" -}}
helm.sh/chart: {{ include "ai-components.chart" . }}
{{ include "ai-components.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: anfl
app.kubernetes.io/component: ai
{{- end }}

{{/*
Selector labels
*/}}
{{- define "ai-components.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ai-components.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "ai-components.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "ai-components.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the image pull secret name
*/}}
{{- define "ai-components.imagePullSecretName" -}}
{{- printf "%s-registry" (include "ai-components.fullname" .) -}}
{{- end }}

{{/*
Define the api version for PodDisruptionBudget.
*/}}
{{- define "ai-components.pdb.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "policy/v1" }}
{{- print "policy/v1" }}
{{- else }}
{{- print "policy/v1beta1" }}
{{- end }}
{{- end }}

{{/*
Define the api version for HorizontalPodAutoscaler.
*/}}
{{- define "ai-components.hpa.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "autoscaling/v2" }}
{{- print "autoscaling/v2" }}
{{- else }}
{{- print "autoscaling/v2beta1" }}
{{- end }}
{{- end }}