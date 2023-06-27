# Determined AI Example

[Determined AI](https://docs.determined.ai/latest/index.html)

This example shows how to package an AI application as a KOTS app using the [Replicated Library Helm Chart](https://github.com/replicatedhq/helm-charts/tree/main/charts/replicated-library). Included are several practical examples of common patterns used when deploying a helm chart with KOTS.

# Table of Contents
* [Examples](#examples)
    * [Embedded vs. External Database](##embedded-vs-external-database)
    * [Self-signed Ingress TLS Certificate vs. User-provided](##self-signed-ingress-tls-certificate-vs-user-provided)
    * [Pass Labels and Annotations from Config Options to Helm Chart Values](##pass-labels-and-annotations-from-config-options-to-helm-chart-values)
    * [Wait for Database to Start Before Starting your Application](##wait-for-database-to-start-before-starting-your-application)

# Examples

All of the below examples are snippets from the full example in this directory.

## Embedded vs. External Database

You may have the need to allow end-users to choose between hosting the database required by your application themselves or providing one with the application at install time. This example will show you how to package templates in your helm chart to allow this functionality for a Postgres database as well as how you would integrate it with your KOTS app.

1. First you'll need to template in your helm chart the optionality between "embedded" vs. "external" Postgres

[values.yaml](determined-ai/values.yaml)
```yaml
postgresql:
  enabled: true
  image:
    registry: docker.io
    repository: bitnami/postgresql
    tag: 15.3.0-debian-11-r0
  fullnameOverride: postgresql
  auth:
    postgresPassword: determined

determined:
  postgresPassword: determined
  externalPostgres:
    enabled: false
    username: postgres
    password: determined
    database: postgres
    host: postgresql
    port: 5432
```

**NOTE**: Determined AI uses a secret containing a config file where all of the application configuration lives including the database connection string. The below is a snippet from that configuration file where we are adding our templating. For you this same templating might be added in environment variables or elsewhere but the same logic applies.

[master.yaml](determined-ai/templates/replicated-library.yaml)
```yaml
db:
{{- if .Values.determined.externalPostgres.enabled }}
  user: {{ required "A valid .Values.determined.externalPostgres.username entry required!" .Values.determined.externalPostgres.username | quote }}
  password: {{ required "A valid Values.determined.externalPostgres.password entry required!" .Values.determined.externalPostgres.password | quote }}
  host: {{ .Values.determined.externalPostgres.host }}
  port: {{ .Values.determined.externalPostgres.port }}
  name: {{ .Values.determined.externalPostgres.name | quote }}
{{- else }}
  user: postgres
  password: {{ required "A valid Values.determined.postgresPassword entry required!" .Values.determined.postgresPassword | quote }}
  host: postgresql
  port: 5432
  name: postgres
{{- end }}
```

2. Now that our templating is configured, we can use the new values that we've created for `externalPostgres` in our KOTS Config Options

[kots-config.yaml](determined-ai/manifests/kots-config.yaml)
```yaml
- name: database_settings
  title: Database
  items:
    - name: postgres_type
      help_text: Would you like to use an embedded postgres instance, or connect to an external instance that you manage?
      type: select_one
      title: Postgres
      default: embedded_postgres
      items:
        - name: embedded_postgres
          title: Embedded Postgres
        - name: external_postgres
          title: External Postgres
    - name: embedded_postgres_password
      hidden: true
      readonly: false
      type: password
      value: '{{repl RandomString 32}}'
    - name: external_postgres_host
      title: Postgres Host
      when: '{{repl ConfigOptionEquals "postgres_type" "external_postgres"}}'
      type: text
      default: postgres
    - name: external_postgres_port
      title: Postgres Port
      when: '{{repl ConfigOptionEquals "postgres_type" "external_postgres"}}'
      type: text
      default: "5432"
    - name: external_postgres_username
      title: Postgres Username
      when: '{{repl ConfigOptionEquals "postgres_type" "external_postgres"}}'
      type: text
      required: true
    - name: external_postgres_password
      title: Postgres Password
      when: '{{repl ConfigOptionEquals "postgres_type" "external_postgres"}}'
      type: password
      required: true
    - name: external_postgres_db
      title: Postgres Database
      when: '{{repl ConfigOptionEquals "postgres_type" "external_postgres"}}'
      type: text
      default: postgres
```

[kots-helm.yaml](determined-ai/manifests/kots-helm.yaml)
```yaml
    postgresql:
      enabled: 'repl{{ (ConfigOptionEquals "postgres_type" "embedded_postgres") }}'
      auth:
        postgresPassword: 'repl{{ConfigOption "embedded_postgres_password"}}'

    determined:
      postgresPassword: 'repl{{ConfigOption "embedded_postgres_password"}}'
      externalPostgresql:
        enabled: repl{{ ConfigOptionEquals "postgres_type" "external_postgres" }}
        username: 'repl{{ ConfigOption "external_postgres_username" }}'
        password: 'repl{{ ConfigOption "external_postgres_password" }}'
        database: 'repl{{ ConfigOption "external_postgres_db" }}'
        host: 'repl{{ ConfigOption "external_postgres_host" }}'
        port: 'repl{{ ConfigOption "external_postgres_port" }}'
```

When the user sets the `postgres_type` to `external_postgres` in the KOTS config UI, additional config options are shown allowing them to specify the username, password, host, and port to connect to Postgres.

## Self-signed Ingress TLS Certificate vs. User-provided

## Pass Labels and Annotations from Config Options to Helm Chart Values

## Wait for Database to Start Before Starting your Application

Helm chart for installing Determined on Kubernetes.

[Installation instructions](https://docs.determined.ai/latest/how-to/installation/kubernetes.html)

[Chart Configurations](https://docs.determined.ai/latest/reference/helm-config.html)
