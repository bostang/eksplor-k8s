# eksplor-k8s

## Catatan Command

### Flow Dasar

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

# ketika ada perubahan pada .yml hapus lalu `minikube kubectl -- apply -f .` lagi
minikube kubectl -- delete -f . # Akan menghapus semua yang ada di folder ini

# hentikan minikube
minikube stop
```

### Apply untuk DB saja (debug)

#### Apply deployment

```bash
minikube kubectl -- apply -f db_backend-deployment.yml
minikube kubectl -- apply -f db_backend-init-script-configmap.yml
minikube kubectl -- apply -f db_backend-pvc.yml
minikube kubectl -- apply -f db_backend-service.yml

minikube kubectl -- apply -f db_verifikator-deployment.yml
minikube kubectl -- apply -f db_verifikator-init-script-configmap.yml
minikube kubectl -- apply -f db_verifikator-pvc.yml
minikube kubectl -- apply -f db_verifikator-service.yml
```

#### Hapus semua yang berhubungan dengan DB

```bash
minikube kubectl -- delete deployment db-backend-deployment
minikube kubectl -- delete service db-backend-service
minikube kubectl -- delete configmap db-backend-init-script-config
minikube kubectl -- delete pvc db-backend-pvc
minikube kubectl -- delete pod -l app=db-backend

minikube kubectl -- delete deployment db-verifikator-deployment
minikube kubectl -- delete service db-verifikator-service
minikube kubectl -- delete configmap db-verifikator-init-script-config
minikube kubectl -- delete pvc db-verifikator-pvc
minikube kubectl -- delete pod -l app=db-verifikator

# verifikasi telah terhapus
minikube kubectl -- get pvc

```
