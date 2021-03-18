# RKE Cluster in HA Mode

Steps:

1. Install required packages

```
ansible-playbook -i inventory.ini install_required_packages.yml
```

2. Create rke user

```
ansible-playbook -i inventory.ini create_rke_user.yml
```

3. Enable required kernel modules

```
ansible-playbook -i inventory.ini enable_required_modules.yml
```

4. Disable swap and Modify sysctl entries

```
ansible-playbook -i inventory.ini disable_swap.yml
```

5. Install docker

```
ansible-playbook -i inventory.ini install_docker.yml
```

6. Login to dockerhub by running:


```
aruku load .
````

and selecting `Login to hub.docker.com`.



## References

https://computingforgeeks.com/install-kubernetes-production-cluster-using-rancher-rke/