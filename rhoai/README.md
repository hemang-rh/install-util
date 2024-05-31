# RHOAI Installation Util (imperatively)

Automation to install below operators:

- RedHat Authorino
- RedHat OpenShift AI
- RedHat OpenShift Serverless
- RedHat OpenShift Service Mesh

## Links

- [Installing and Deploying Openshift AI](https://access.redhat.com/documentation/en-us/red_hat_openshift_ai_self-managed/2.9/html/installing_and_uninstalling_openshift_ai_self-managed/installing-and-deploying-openshift-ai_install#doc-wrapper)
- [Download OpenShift CLI](https://docs.openshift.com/container-platform/4.15/cli_reference/openshift_cli/getting-started-cli.html#installing-openshift-cli)
- [Serving LLMs](https://access.redhat.com/documentation/en-us/red_hat_openshift_ai_self-managed/2.9/html/serving_models/serving-large-models_serving-large-models)
- [Manually Installing KServe](https://access.redhat.com/documentation/en-us/red_hat_openshift_ai_self-managed/2.9/html/serving_models/serving-large-models_serving-large-models#manually-installing-kserve_serving-large-models)
- [Installing the Serverless Operator](https://docs.openshift.com/serverless/1.32/install/install-serverless-operator.html)
- [Installing the Service Mesh Operator](https://docs.openshift.com/container-platform/4.15/service_mesh/v2x/installing-ossm.html#installing-ossm)

## Steps

### 0. Adding administrative user

- [ ] Create an htpasswd file to store the user and password information
- [ ] Create a secret to represent the htpasswd file
- [ ] Define the custom resource for htpasswd
- [ ] Apply the resource to the default OAuth configuration to add the identity provider

### 1. Installing the Red Hat OpenShift AI Operator using the CLI

- [ ] Create a namespace YAML file
- [ ] Apply the namespace object
- [ ] Create an OperatorGroup object custom resource (CR) file
- [ ] Apply the OperatorGroup object
- [ ] Create a Subscription object CR file
- [ ] Apply the Subscription object
- [ ] Verification
  - [ ] Check the installed operators
  - [ ] Check the created projects

### 2. Installing and managing Red Hat OpenShift AI components

- [ ] Create a DataScienceCluster object custom resource (CR) file
- [ ] Apply DSC object

### 3. Installing KServe dependencies

#### 3.1 Installing RHOS ServiceMesh

    (Optional operators - Kiali, Tempo)
    (Deprecated operators - Jaeger, Elastricsearch)

- [ ] Create the required namespace for Red Hat OpenShift Service Mesh
- [ ] Define the required subscription for the Red Hat OpenShift Service Mesh Operator
- [ ] Create the Service Mesh subscription to install the operator
- [ ] Define a ServiceMeshControlPlane object in a YAML file
- [ ] Create the servicemesh control plane object
- [ ] Verify the pods are running for the service mesh control plane, ingress gateway, and egress gateway

#### 3.2 Installing RHOS Serverless

- [ ] Create namespace
- [ ] Create opeator group
- [ ] Create subscription

#### 3.3 Installing KNative Serving

- [ ] Create knative-serving namespace if it doesn't exist
- [ ] Define a ServiceMeshMember object in a YAML file
- [ ] Create the ServiceMeshMember object in the istio-system namespace
- [ ] Define a KnativeServing object in a YAML file
- [ ] Create the KnativeServing object in the specified knative-serving namespace
- [ ] Verification
  - [ ] Review the default ServiceMeshMemberRoll object in the istio-system namespace and confirm that it includes the knative-serving namespace
  - [ ] Verify creation of the Knative Serving instance

#### 3.4 Creating secure gateways for Knative Serving

- [ ] Set environment variables to define base directories for generation of a wildcard certificate and key for the gateways.
- [ ] Set an environment variable to define the common name used by the ingress controller of your OpenShift cluster
- [ ] Create the required base directories for the certificate generation, based on the environment variables that you previously set
- [ ] Create the OpenSSL configuration for generation of a wildcard certificate
- [ ] Generate a root certificate
- [ ] Generate a wildcard certificate signed by the root certificate
- [ ] Verify the wildcard certificate
- [ ] Export the wildcard key and certificate that were created by the script to new environment variables
- [ ] Create a TLS secret in the istio-system namespace using the environment variables that you set for the wildcard certificate and key
- [ ] Create a serverless-gateways.yaml YAML file
- [ ] Apply the serverless-gateways.yaml file to create the defined resources
- [ ] Review the gateways that you created

#### 3.5 Installing Kserve

- [ ] Set serviceMesh component as "managementState: Unmanaged" (inside default-dsci)

  ```
  spec:
    serviceMesh:
      managementState: Unmanaged
  ```

- [ ] Set kserve component as "managementState: Managed" (inside default-dsc)
- [ ] Set serving component within kserve component as "managementState: Unmanaged" (inside default-dsc)

  ```
  spec:
    components:
      kserve:
        managementState: Managed
        serving:
          managementState: Unmanaged
  ```

#### 3.6 Manually adding an authorization provider

- [ ] Create subscription for the Authorino Operator
- [ ] Install the Authorino operator
- [ ] Create a namespace to install the Authorino instance
- [ ] Enroll the new namespace for the Authorino instance in your existing OpenShift Service Mesh instance
- [ ] Create the ServiceMeshMember resource on your cluster
- [ ] Configure an Authorino instance, create a new YAML file as shown
- [ ] Create the Authorino resource on your cluster
- [ ] Patch the Authorino deployment to inject an Istio sidecar, which makes the Authorino instance part of your OpenShift Service Mesh instance
- [ ] Check the pods (and containers) that are running in the namespace that you created for the Authorino instance, as shown in the following example

#### 3.7 Configuring an OpenShift Service Mesh instance to use Authorino

- [ ] Create a new YAML file to patch the ServiceMesh Control Plane
- [ ] Use the oc patch command to apply the YAML file to your OpenShift Service Mesh instance
- [ ] Verification

  - [ ] Inspect the ConfigMap object for your OpenShift Service Mesh instance (should look similar to below)

  ```
  defaultConfig:
    discoveryAddress: istiod-data-science-smcp.istio-system.svc:15012
    proxyMetadata:
      ISTIO_META_DNS_AUTO_ALLOCATE: "true"
      ISTIO_META_DNS_CAPTURE: "true"
      PROXY_XDS_VIA_AGENT: "true"
    terminationDrainDuration: 35s
    tracing: {}
  dnsRefreshRate: 300s
  enablePrometheusMerge: true
  extensionProviders:
  - envoyExtAuthzGrpc:
      port: 50051
      service: authorino-authorino-authorization.opendatahub-auth-provider.svc.cluster.local
    name: opendatahub-auth-provider
  ingressControllerMode: "OFF"
  rootNamespace: istio-system
  trustDomain: null%
  ```

### 3.8 Configuring authorization for KServe

- [ ] Create a new YAML file for
- [ ] Create the AuthorizationPolicy resource in the namespace for your OpenShift Service Mesh instance
- [ ] Create another new YAML file with the following contents:
- [ ] Create the EnvoyFilter resource in the namespace for your OpenShift Service Mesh instance
- [ ] Check that the AuthorizationPolicy resource was successfully created
- [ ] Check that the EnvoyFilter resource was successfully created
