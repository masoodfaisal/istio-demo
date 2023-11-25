# Install red hat service mesh, kiali and jaeger operators.

# Verify that the operator is running
oc -n openshift-operators get po -l name=istio-operator -o wide

# Create Istio Control Plane in the istio-system namespace
oc create -n istio-system -f istio-config/1-control-plane.yaml

# Create new namespace to run the demo
oc new-project istio-demo

# register the newly created namespace with the service mesh
oc create -n istio-system -f istio-config/2-member-roll.yaml

# oc get pods -n istio-system -w

# Build the apps
oc project istio-demo
oc import-image ubi8/python-311:1-35 --from=registry.access.redhat.com/ubi8/python-311:1-35 --confirm

oc new-build --name fe-app --binary --strategy source --image-stream python-311:1-35 -n istio-demo
oc start-build fe-app --from-dir=fe-app/ --follow -n istio-demo

oc new-build --name be-app --binary --strategy source --image-stream python-311:1-35 -n istio-demo
oc start-build be-app --from-dir=be-app/ --follow -n istio-demo

# Deploy apps
# note that the deployment yals creating separate service accounts for the apps to run
oc create -f istio-config/3-be-deployment.yaml
oc create -f istio-config/4-fe-deployment.yaml

# Create Istio gateway and Virtual Services for frontend and backend apps
oc replace -f istio-config/5-permissive-peer-auth-policy.yaml 
oc create -f istio-config/6-networking.yaml

# Get the istio gateway coordinates
ISTIO_GATEWAY=$(oc -n istio-system get route istio-ingressgateway -o jsonpath='{.spec.host}')

# Create the Auth policy of DENY the traffic to the backend app from the frontend app
oc create -f istio-config/7-auth-policy.yaml 
# it will fail because fe-app app got error
curl -vvvk http://${ISTIO_GATEWAY}

# now change tge DENY to ALLOW in istio-config/7-auth-policy.yaml and apply it
oc replace -f istio-config/7-auth-policy.yaml
# Great Success! 
curl -vvvk http://${ISTIO_GATEWAY}