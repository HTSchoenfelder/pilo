k3s_terraform_dir := "./infrastructure/k3s/terraform"
k3s_ansible_dir := "./infrastructure/k3s/ansible"
tls_dir := "./infrastructure/k3s/tls"
app_dir := "./app"

deploy-infrastructure:
    cd {{k3s_terraform_dir}} && ./deploy-infrastructure.sh

deploy-k3s:
    cd {{k3s_ansible_dir}} && ./deploy-k3s.sh
    
setup-tls:
    cd {{tls_dir}} && ./setup-tls.sh

deploy-app:
    cd {{app_dir}} && ./deploy-pilo.sh