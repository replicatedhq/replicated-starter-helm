{{- define "support-bundle.spec" }}
apiVersion: troubleshoot.sh/v1beta2
kind: SupportBundle
metadata:
  name: support-bundle
spec:
  collectors:
    - clusterInfo: {}
    - clusterResources: {}
    - logs:
        selector:
          - app=someapp
        namespace: {{ .Release.Namespace }}
{{- end }}