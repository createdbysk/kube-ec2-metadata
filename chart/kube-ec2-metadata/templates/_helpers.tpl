{{/* Compute the name */}}
{{- define "kube-ec2-metadata.sidecarName" }}
{{- default .Release.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Compute the namespace */}}
{{- define "kube-ec2-metadata.sidecarNamespace" }}
{{- ( eq .Release.Namespace "default" ) | ternary ( default "sidecar-injector" .Values.sidecarInjectorNamespace ) .Release.Namespace  | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Compute the port for the mock metadata api */}}
{{- define "kube-ec2-metadata.mockMetadataPort" }}
{{- .Values.mockMetadata.port | default 9081 | quote }}
{{- end }}

{{/* Compute the port for the mock metadata sidecar container */}}
{{- define "kube-ec2-metadata.mockMetadataSidecarContainerPort" }}
{{- .Values.mockMetadata.sidecarContainerPort | default 9080 | quote }}
{{- end }}

{{/* Compute image tag */}}
{{- define "kube-ec2-metadata.image" }}
image: "{{ .repository }}:{{ .tag | default "latest" }}"
imagePullPolicy: {{ .pullPolicy | default "IfNotPresent" }}
{{- end }}
