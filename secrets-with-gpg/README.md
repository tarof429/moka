# Secrets with GPG

This tutorial is an exploration of encrypting secrets with GPG. In this tutorial, secrets can mean anything, from Kubernetes secrets to passwords stored in text files. 

## Setup

1. Generate your keys

```
gpg --full-generate-key
```

This will generate keys in an interactive session. If you already have ~/.gnupg, be careful about running this program. In such a case, it would be wise to skp this step or rename ~/.gnupg.

2. Generate a revocation certificate

This step lets you revoke existing public keys in case your private key becomes known.

```
gpg --output ~/revocation.crt --gen-revoke dave-geek@protonmail.com
```

Be sure to change permissions for this file.

```
chmod 600 ~/revocation.crt
```

## Encrypting files

Let's see how gpg can be used to encrypt a text file containing a pass phrase. We'll create a file and encrypt the contents.

```
echo "some kind of password" > secret
```

Next we'll run the following command to encrypt it.

```
gpg --encrypt --sign --armor -r dave-geek@protonmail.com secret
```

A new file (plain text file, as dicatated by the --armor option) with the encrypted contents. 

## Decrypting files

To decrypt it, first delete `secret` and run the following command on it.

```
gpg secret.asc
```

The file `secret` will appear with the decrypted contents!

## Using GPG with Kubernetes secrets

Now lets create a Kubernetes secret with an OAUTH2 token.

```
kubectl create secret  generic access-token --from-literal=ACCESS_TOKEN=blahblahblah --dry-run=client -o yaml > access-token-secret.yaml
```

It will look something like this.

```
 cat access-token-secret.yaml 
apiVersion: v1
data:
  ACCESS_TOKEN: YmxhaGJsYWhibGFo
kind: Secret
metadata:
  creationTimestamp: null
  name: access-token
```

Commiting this file is not a good idea since the token is simply base64 encoded.

```
echo YmxhaGJsYWhibGFo | base64 -d
blahblahblah
```

Let's encrypt this file.

```
gpg --encrypt --sign --armor -r tarof429@gmail.com access-token-secret.yaml 
```

Now we can delete the yaml file containing our secret.

```
rm access-token-secret.yaml
```

We're left with a fie with an .asc extension containing the encrypted contents of our Kubernetes secret. 

## Conclusion

If we're working on multiple computers or in a CI/CD scenario, we may need to make sure that those parties can decrypt our files. There are tools like `kubesec` specifiically for this purpose.

## References

https://www.howtogeek.com/427982/how-to-encrypt-and-decrypt-files-with-gpg-on-linux/. 

https://blog.stack-labs.com/code/keep-your-kubernetes-secrets-in-git-with-kubesec/
