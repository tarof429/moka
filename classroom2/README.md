# Classroom 2

A second attempt to create a cluster and add users.

## Preparation

```
vagrant up
rke up
```

## Add users

1. Generate a private key and CSR

    ```
    cd certs
    openssl genrsa -out taro.key 2048
    openssl req -new -key taro.key -out taro.csr -subj "/C=US/ST=CA/L=San Jose/O=Engineering/OU=Operations/CN=taro"
    ```

2. Submit the CSR

    ```
    cat <<EOF | kubectl apply -f -
    apiVersion: certificates.k8s.io/v1
    kind: CertificateSigningRequest
    metadata:
    name: taro
    spec:
    groups:
    - system:authenticated
    request: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0KTUlJQ1ZqQ0NBVDRDQVFBd0VURVBNQTBHQTFVRUF3d0dZVzVuWld4aE1JSUJJakFOQmdrcWhraUc5dzBCQVFFRgpBQU9DQVE4QU1JSUJDZ0tDQVFFQTByczhJTHRHdTYxakx2dHhWTTJSVlRWMDNHWlJTWWw0dWluVWo4RElaWjBOCnR2MUZtRVFSd3VoaUZsOFEzcWl0Qm0wMUFSMkNJVXBGd2ZzSjZ4MXF3ckJzVkhZbGlBNVhwRVpZM3ExcGswSDQKM3Z3aGJlK1o2MVNrVHF5SVBYUUwrTWM5T1Nsbm0xb0R2N0NtSkZNMUlMRVI3QTVGZnZKOEdFRjJ6dHBoaUlFMwpub1dtdHNZb3JuT2wzc2lHQ2ZGZzR4Zmd4eW8ybmlneFNVekl1bXNnVm9PM2ttT0x1RVF6cXpkakJ3TFJXbWlECklmMXBMWnoyalVnald4UkhCM1gyWnVVV1d1T09PZnpXM01LaE8ybHEvZi9DdS8wYk83c0x0MCt3U2ZMSU91TFcKcW90blZtRmxMMytqTy82WDNDKzBERHk5aUtwbXJjVDBnWGZLemE1dHJRSURBUUFCb0FBd0RRWUpLb1pJaHZjTgpBUUVMQlFBRGdnRUJBR05WdmVIOGR4ZzNvK21VeVRkbmFjVmQ1N24zSkExdnZEU1JWREkyQTZ1eXN3ZFp1L1BVCkkwZXpZWFV0RVNnSk1IRmQycVVNMjNuNVJsSXJ3R0xuUXFISUh5VStWWHhsdnZsRnpNOVpEWllSTmU3QlJvYXgKQVlEdUI5STZXT3FYbkFvczFqRmxNUG5NbFpqdU5kSGxpT1BjTU1oNndLaTZzZFhpVStHYTJ2RUVLY01jSVUyRgpvU2djUWdMYTk0aEpacGk3ZnNMdm1OQUxoT045UHdNMGM1dVJVejV4T0dGMUtCbWRSeEgvbUNOS2JKYjFRQm1HCkkwYitEUEdaTktXTU0xMzhIQXdoV0tkNjVoVHdYOWl4V3ZHMkh4TG1WQzg0L1BHT0tWQW9FNkpsYWFHdTlQVmkKdjlOSjVaZlZrcXdCd0hKbzZXdk9xVlA3SVFjZmg3d0drWm89Ci0tLS0tRU5EIENFUlRJRklDQVRFIFJFUVVFU1QtLS0tLQo=
    signerName: kubernetes.io/kube-apiserver-client
    usages:
    - client auth
    EOF
    ```

    request is the base64 encoded value of the CSR file content. You can get the content using this command: cat taro.csr | base64 | tr -d "\n"

3. Get the list of CSR

    ```
     kubectl get csr
    NAME   AGE     SIGNERNAME                            REQUESTOR    CONDITION
    taro   5m18s   kubernetes.io/kube-apiserver-client   kube-admin   Pending
    ```

4. Approve the CSR

    ```
    kubectl certificate approve taro
    certificatesigningrequest.certificates.k8s.io/taro approved
    ```


5. Retrieve the certificate. Save it to a file like taro.crt

    ```
    kubectl get csr/taro -o yaml > certs/taro.crt
    ```

6. Create Role and RoleBinding

    ```
    kubectl create role developer --verb=create --verb=get --verb=list --verb=update --verb=delete --resource=pods

    kubectl create rolebinding developer-binding-taro --role=developer --user=taro
    ```

7. Add to kubeconfig

    ```
    kubectl config set-credentials taro --client-key=certs/taro.key --client-certificate=certs/taro.crt --embed-certs=true
    ```

8. Set context

    ```
    kubectl config set-context taro --cluster=local --user=taro
    ```

9. Test

    ```
    kubectl config use-context taro
    ```

## References

https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/


