# Red Hat Developer Sandbox Setup Guide

##  Overview

The **Red Hat Developer Sandbox** provides a **free OpenShift cluster** in the cloud for learning and development. It includes:

-  **Free 30-day access** (renewable)
-  **Pre-configured OpenShift 4.x cluster**
-  **2 projects/namespaces**
-  **No credit card required**
-  **Access to OpenShift Web Console**
-  **CLI access with oc command**
-  **helm access with helm command**
-  **tekton access with tkn command**

---

##  Step-by-Step Setup

### Step 1: Create a Red Hat Account

1. Go to [Red Hat Developer Portal](https://developers.redhat.com/)
2. Click **"Log in"** in the top right corner
3. Click **"Register for a Red Hat account"**
4. Fill in the registration form:
   - Email address
   - Username
   - Password
   - Accept terms and conditions
5. Click **"Create My Account"**
6. **Verify your email** (check inbox for verification link)

---

### Step 2: Access the Developer Sandbox

1. Navigate to [Developer Sandbox](https://developers.redhat.com/developer-sandbox)
2. Click **"Start your sandbox for free"** or **"Launch your Developer Sandbox"**
3. Sign in with your Red Hat account credentials
4. Accept the **Terms and Conditions** for the Developer Sandbox

---

### Step 3: Activate Your Sandbox

1. After accepting terms, click **"Start using your sandbox"**
2. You'll be redirected to a **phone verification page**
3. Select your **country code**
4. Enter your **phone number**
5. Click **"Send verification code"**
6. Enter the **verification code** you receive via SMS
7. Click **"Verify code"**

**Note:** Phone verification is required to prevent abuse and ensure one sandbox per person.

---

### Step 4: Access OpenShift Web Console

Once verified, you'll be automatically redirected to the **OpenShift Web Console**.

**Your Sandbox Includes:**
- **2 namespaces:**
  - `<username>-dev` - Development namespace
  - `<username>-stage` - Staging namespace

**Web Console URL:**
```
https://console.redhat.com/openshift/sandbox
```

Or click **"OpenShift Console"** from the Developer Sandbox page.

---

##  Setting Up CLI Access

### Step 1: Install OpenShift CLI (oc)

#### Linux
```bash
# Download oc CLI
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/openshift-client-linux.tar.gz

# Extract
tar -xvf openshift-client-linux.tar.gz

# Move to system path
sudo mv oc /usr/local/bin/
sudo chmod +x /usr/local/bin/oc

# Verify installation
oc version
```

#### macOS
```bash
# Using Homebrew
brew install openshift-cli

# Or download manually
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/openshift-client-mac.tar.gz
tar -xvf openshift-client-mac.tar.gz
sudo mv oc /usr/local/bin/
```

#### Windows
1. Download from [OpenShift Mirror](https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/)
2. Extract `oc.exe`
3. Add to your PATH under environment variables

---

### Step 2: Get Login Command

1. In the **OpenShift Web Console**, click your **username** (top right)
2. Click **"Copy login command"**
3. You'll be redirected to a token page
4. Click **"Display Token"**
5. Copy the `oc login` command that looks like:

```bash
oc login --token=sha256~XXXXXXXXXXXXX --server=https://api.sandbox-xxx.openshiftapps.com:6443
```

---

### Step 3: Login via CLI

Paste and run the login command in your terminal:

```bash
oc login --token=sha256~YOUR_TOKEN --server=https://api.sandbox-xxx.openshiftapps.com:6443
```

**Verify login:**
```bash
# Check current user
oc whoami

# List projects
oc projects

# Switch to dev project
oc project <username>-dev
```

---

##  Basic OpenShift Commands

### Project Management
```bash
# List all projects
oc projects

# Switch project
oc project <username>-dev

# Get current project
oc project
```

### Application Deployment
```bash
# Create a new app from Git
oc new-app https://github.com/sclorg/nodejs-ex

# Create app from Docker image
oc new-app --docker-image=nginx:latest

# Expose service as route
oc expose svc/nodejs-ex
```

### Resource Management
```bash
# List all resources
oc get all

# List pods
oc get pods

# List services
oc get svc

# List routes
oc get routes

# View pod logs
oc logs <pod-name>

# Describe resource
oc describe pod <pod-name>
```

### Scaling Applications
```bash
# Scale deployment
oc scale deployment/nodejs-ex --replicas=3

# Auto-scale
oc autoscale deployment/nodejs-ex --min=2 --max=5 --cpu-percent=80
```

---

##  Deploying Your First Application

### Example: Deploy a Node.js App

```bash
# Switch to dev namespace
oc project <username>-dev

# Create new app from Git
oc new-app https://github.com/sclorg/nodejs-ex --name=my-nodejs-app

# Watch build progress
oc logs -f bc/my-nodejs-app

# Expose the service
oc expose svc/my-nodejs-app

# Get the route URL
oc get route my-nodejs-app
```

**Access your app:**
```bash
# Get the URL
URL=$(oc get route my-nodejs-app -o jsonpath='{.spec.host}')
echo "Application URL: https://$URL"

# Open in browser
curl https://$URL
```

---

##  Working with Secrets and ConfigMaps

### Create a Secret
```bash
# From literal values
oc create secret generic my-secret \
  --from-literal=username=admin \
  --from-literal=password=secret123

# From file
oc create secret generic my-secret --from-file=ssh-key=~/.ssh/id_rsa
```

### Create a ConfigMap
```bash
# From literal values
oc create configmap my-config \
  --from-literal=app.env=production \
  --from-literal=log.level=info

# From file
oc create configmap my-config --from-file=config.yaml
```

### Use in Deployment
```bash
# Set environment variable from secret
oc set env deployment/my-app --from=secret/my-secret

# Mount configmap as volume
oc set volume deployment/my-app \
  --add --type=configmap \
  --configmap-name=my-config \
  --mount-path=/etc/config
```

---

##  Deploying the OpenShift Production Platform

### Clone the Repository
```bash
git clone https://github.com/blessing-bester/openshift-production-platform.git
cd openshift-production-platform
```

### Install ArgoCD
```bash
# Create namespace
oc new-project argocd

# Install ArgoCD
oc apply -n argocd -f manifests/argocd/install.yaml

# Wait for pods to be ready
oc wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Get ArgoCD admin password
oc -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Expose ArgoCD server
oc expose svc argocd-server -n argocd

# Get ArgoCD URL
oc get route argocd-server -n argocd
```

### Install Tekton
```bash
# Install Tekton Operator
oc apply -f manifests/tekton/operator.yaml

# Install Tekton Pipelines
oc apply -f manifests/tekton/pipelines/
```

### Install Monitoring Stack
```bash
# Create monitoring namespace
oc new-project monitoring

# Install Prometheus
oc apply -f manifests/monitoring/prometheus/

# Install Grafana
oc apply -f manifests/monitoring/grafana/

# Get Grafana URL
oc get route grafana -n monitoring
```

---

## ⚠️ Sandbox Limitations

| Resource | Limit |
|----------|-------|
| **Duration** | 30 days (renewable) |
| **Projects** | 2 namespaces |
| **Memory** | 7 GB RAM per namespace |
| **CPU** | Shared, no guaranteed limits |
| **Storage** | 15 GB persistent storage |
| **Pods** | ~20 pods per namespace |
| **Sleep Mode** | Inactive clusters sleep after 8 hours |

**Notes:**
- Cluster automatically hibernates after 8 hours of inactivity
- Wake up by logging into the console
- No custom operator installations allowed
- Limited to standard OpenShift resources

---

##  Renewing Your Sandbox

Your sandbox expires after **30 days**. To renew:

1. Go to [Developer Sandbox](https://developers.redhat.com/developer-sandbox)
2. Sign in with your Red Hat account
3. Click **"Renew your sandbox"**
4. Accept terms and conditions
5. Your sandbox will be reset with fresh namespaces

** Warning:** Renewal **deletes all data**. Export important work before renewal.

---

##  Exporting Your Work Before Renewal

### Export All Resources
```bash
# Export all resources from dev namespace
oc get all -o yaml > backup-dev.yaml

# Export specific resources
oc get deployments,services,routes -o yaml > backup-apps.yaml

# Export secrets (be careful with sensitive data)
oc get secrets -o yaml > backup-secrets.yaml

# Export configmaps
oc get configmaps -o yaml > backup-configmaps.yaml
```

### Backup Using oc CLI
```bash
# Create backup script
cat << 'EOF' > backup-sandbox.sh
#!/bin/bash
BACKUP_DIR="sandbox-backup-$(date +%Y%m%d)"
mkdir -p $BACKUP_DIR

for project in $(oc projects -q); do
  echo "Backing up project: $project"
  oc project $project
  oc get all,secrets,configmaps,pvc -o yaml > "$BACKUP_DIR/$project.yaml"
done

echo "Backup complete: $BACKUP_DIR"
EOF

chmod +x backup-sandbox.sh
./backup-sandbox.sh
```

---

##  Troubleshooting

### Cannot Login
```bash
# Check token expiration
oc whoami

# Get new login token
# Go to Web Console → Username → Copy Login Command
```

### Pod Not Starting
```bash
# Check pod status
oc get pods

# View pod details
oc describe pod <pod-name>

# Check logs
oc logs <pod-name>

# Check events
oc get events --sort-by='.lastTimestamp'
```

### Route Not Accessible
```bash
# Verify route exists
oc get routes

# Check if service is running
oc get svc

# Verify pods are ready
oc get pods
```

### Out of Resources
```bash
# Check resource quotas
oc describe quota

# Check resource usage
oc adm top pods
oc adm top nodes
```

---

##  Additional Resources

- [OpenShift Documentation](https://docs.openshift.com/)
- [OpenShift Interactive Learning](https://learn.openshift.com/)
- [Developer Sandbox FAQ](https://developers.redhat.com/developer-sandbox/faq)
- [OpenShift CLI Reference](https://docs.openshift.com/container-platform/latest/cli_reference/openshift_cli/getting-started-cli.html)
- [Tekton Documentation](https://tekton.dev/docs/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)

---

##  Best Practices

1. **Use GitOps** - Store all configurations in Git
2. **Label resources** - Use proper labels for organization
3. **Resource limits** - Always set resource requests/limits
4. **Health checks** - Configure liveness and readiness probes
5. **Backup regularly** - Export configurations before renewal
6. **Use secrets** - Never hardcode sensitive data
7. **Monitor usage** - Stay within quota limits

---

##  Next Steps

1.  Complete the setup
2.  Follow [OpenShift Interactive Learning](https://learn.openshift.com/)
3.  Deploy the production platform from this repository
4.  Build your own applications
5.  Contribute back to the community

---

**Need Help?**  
- [OpenShift Community Forums](https://community.redhat.com/)
- [Red Hat Developer Support](https://developers.redhat.com/support)

---
