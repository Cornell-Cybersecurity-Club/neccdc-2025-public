# Kubernetes Installation

```bash
ansible-playbook playbook.yaml

ansible-playbook post.yaml
```

## Troubleshooting

If the first playbook gets stuck on the prometheus, wait a few minutes then stop the script and run the following command.

```bash
ansible-playbook playbook.yaml -t services,fun,cleanup
```
