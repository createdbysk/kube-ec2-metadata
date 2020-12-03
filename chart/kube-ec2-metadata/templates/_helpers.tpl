{{/* Compute the name */}}
{{- define "kube-ec2-metadata.sidecarName" }}
{{- default .Release.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Compute the namespace */}}
{{- define "kube-ec2-metadata.sidecarNamespace" }}
{{- default "sidecar-injector" .Values.sidecarInjectorNamespaceOverride  | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Compute the port for the mock metadata api */}}
{{- define "kube-ec2-metadata.mockMetadataPort" }}
{{- .Values.mockMetadata.port | default 9081  }}
{{- end }}

{{/* Compute the port for the mock metadata sidecar container */}}
{{- define "kube-ec2-metadata.mockMetadataSidecarContainerPort" }}
{{- .Values.mockMetadata.sidecarContainerPort | default 9080 }}
{{- end }}

{{/* Compute image tag */}}
{{- define "kube-ec2-metadata.image" }}
image: "{{ .repository }}:{{ .tag | default "latest" }}"
imagePullPolicy: {{ .pullPolicy | default "IfNotPresent" }}
{{- end }}

{{/* Compute image webhook url */}}
{{- define "kube-ec2-metadata.webhookUrl" }}
{{- $name := ( include "kube-ec2-metadata.sidecarName" . ) -}}
{{- default ( nospace ( cat $name ".satvidh.me" ) ) .Values.webhookUrlOverride }}
{{- end }}

{{/* Compute configmap name */}}
{{- define "kube-ec2-metadata.configMapName" }}
{{- nospace (cat ( include "kube-ec2-metadata.sidecarName" . ) "-webhook-configmap" ) -}}
{{- end }}

{{/* Compute deployment name */}}
{{- define "kube-ec2-metadata.deploymentName" }}
{{- nospace (cat ( include "kube-ec2-metadata.sidecarName" . ) "-webhook-deployment" ) -}}
{{- end }}

{{/* Compute service name */}}
{{- define "kube-ec2-metadata.serviceName" }}
{{- nospace (cat ( include "kube-ec2-metadata.sidecarName" . ) "-webhook-svc" ) -}}
{{- end }}

{{/* Compute deployment name */}}
{{- define "kube-ec2-metadata.mutatingWebhookCfgName" }}
{{- nospace (cat ( include "kube-ec2-metadata.sidecarName" . ) "-webhook-cfg" ) -}}
{{- end }}
