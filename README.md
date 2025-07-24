# eksplor-k8s

## Catatan Command

```bash
minikube start
minikube status # cek running / tidak

minikube kubectl -- apply -f . # Jika semua file .yml ada di folder saat ini

# Periksa status pods
minikube kubectl -- get pods
# contoh output:
    # NAME                                         READY   STATUS             RESTARTS      AGE
    # backend-deployment-6fb5d5bc7b-zl4ls          0/1     CrashLoopBackOff   3 (45s ago)   5m30s
    # db-backend-deployment-7fc8fff5c6-rmhw4       0/1     CrashLoopBackOff   5 (9s ago)    5m30s
    # db-verifikator-deployment-655b57c569-j9rk8   0/1     CrashLoopBackOff   4 (40s ago)   5m30s
    # frontend-deployment-98874c778-gqx29          1/1     Running            0             5m30s
    # verifikator-deployment-7c75bc5748-dccql      0/1     CrashLoopBackOff   3 (35s ago)   5m30s

# Periksa status services
minikube kubectl -- get services

# lihat log detail dari suatu pods
minikube kubectl -- logs backend-deployment-6fb5d5bc7b-zl4ls

# lihat url frontend (accesible via browser)
minikube service frontend-service --url

minikube kubectl -- delete -f . # Akan menghapus semua yang ada di folder ini

# hentikan minikube
minikube stop
```
