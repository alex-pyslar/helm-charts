GitLab Chart
Custom Helm chart for GitLab CE.
Install
helm install gitlab ./charts/gitlab --namespace default

Values

image.repository: gitlab/gitlab-ce
image.tag: latest
global.psql.host: postgres service name
