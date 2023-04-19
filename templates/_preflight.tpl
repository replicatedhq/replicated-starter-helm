{{- define "preflight.spec" }}
apiVersion: troubleshoot.sh/v1beta2
kind: Preflight
metadata:
  name: preflight-sample
spec:
  analyzers:
    - clusterVersion:
        outcomes:
          - fail:
              when: "< 1.19.0"
              message: The application requires at least Kubernetes 1.19.0, and recommends 1.24.0.
              uri: https://kubernetes.io
          - warn:
              when: "< 1.23.0"
              message: Your cluster meets the minimum version of Kubernetes, but we recommend you update to 1.24.0 or later.
              uri: https://kubernetes.io
          - pass:
              message: Your cluster meets the recommended and required versions of Kubernetes.
{{- end }}