# eksplor-k8s

## Cara Menjalankan

```bash
# LANGKAH 0 : PASTIKAN MINIKUBE SUDAH TERINSTALL DAN BERJALAN

# JALANKAN SCRIPT OTOMASI U/ TAMBAHKAN IP MINIKUBE KE INGRESS URL
./add_host_minikube.sh

# JALANKAN SCRIPT UNTUK MEMULAI SEMUA PODS
./k8s-mng.sh --run
```

## Setting Ingress

**langkah 0**. instalasi:

```bash
minikube addons enable ingress
```

**langkah 1**. buat manifest ingress `frontend-ingress.yml`.

**langkah 2.** Perbarui File `/etc/hosts` (Lokal):
Untuk menguji Ingress secara lokal di Minikube, kita perlu memetakan nama domain ke IP Minikube.

Dapatkan IP Minikube: `minikube ip` (misalnya, `192.168.49.2`)
Tambahkan entri ke `/etc/hosts` (atau `C:\Windows\System32\drivers\etc\hosts` di Windows):

```c
192.168.49.2 wondr.desktop.com
```

## Catatan Command

### Cek IP dari minikube

```bash
minikube ip
```

### Debugging pods

```bash
# menampilkan environment variable
minikube kubectl -- exec -it db-verifikator-deployment-8577fd7498-tjqpd -- env

# menampilkan file di dalam direktori tertentu
minikube kubectl -- exec -it db-verifikator-deployment-8577fd7498-tjqpd -- ls /docker-entrypoint-initdb.d/

# menjalankan container (docker exec)
minikube kubectl -- exec -it db-verifikator-deployment-8577fd7498-tjqpd -- /bin/bash

# menjalankan postgres
minikube kubectl -- exec -it db-verifikator-deployment-8577fd7498-tjqpd -- psql -U postgres

# setelah melakukan kubectl apply, bisa tunggu hingga container ready dengan:
minikube kubectl -- get pods -w     # -w : watch

minikube kubectl -- logs backend-deployment-558b488746-fc72j -f  # -f : follow
```

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

#### Hapus PV (persistent volume)

```bash
minikube kubectl -- get pv
minikube kubectl -- delete pv [nama-pv]
```

## Catatan Tambahan

### Konfigurasi CORS untuk backend agar allow frontned

Catatan: Anda perlu memperbarui nilai value untuk FRONTEND_URL setiap kali NodePort frontend berubah. Ini bisa diotomatisasi dengan skrip CI/CD yang membaca NodePort dan kemudian memperbarui deployment YAML sebelum menerapkan.

Cek IP frontend:

```bash
FRONTEND_IP=$(minikube ip)
FRONTEND_NODEPORT=$(minikube kubectl -- get service frontend-service -o jsonpath='{.spec.ports[0].nodePort}')
ACTUAL_FRONTEND_URL="http://${FRONTEND_IP}:${FRONTEND_NODEPORT}"
echo "Frontend URL yang sebenarnya: ${ACTUAL_FRONTEND_URL}"
# contoh output: Frontend URL yang sebenarnya: http://192.168.49.2:32138 
```

pada manifest backend (deployment):

```yaml
 # FRONTEND_URL (Ganti baris ini dengan nilai yang dievaluasi)
- name: FRONTEND_URL
    value: "http://192.168.49.2:32138" # Ganti dengan nilai ACTUAL_FRONTEND_URL
```

lalu apply lagi :

```bash
minikube kubectl -- apply -f backend-deployment.yaml
```

contoh script otomatisasi untuk CI/CD:

```bash
#!/bin/bash

# Dapatkan IP Minikube dan NodePort Frontend
FRONTEND_IP=$(minikube ip)
FRONTEND_NODEPORT=$(minikube kubectl -- get service frontend-service -o jsonpath='{.spec.ports[0].nodePort}')
ACTUAL_FRONTEND_URL="http://${FRONTEND_IP}:${FRONTEND_NODEPORT}"

echo "Menggunakan Frontend URL: ${ACTUAL_FRONTEND_URL}"

# Ganti placeholder di YAML dengan nilai yang sebenarnya
# Gunakan sed atau yq/jsonnet untuk manipulasi YAML yang lebih robust
# Contoh sederhana dengan sed (pastikan Anda hanya memiliki satu baris FRONTEND_URL)
sed -i "s|value: \"http://$(minikube ip):$(minikube kubectl -- get service frontend-service -o jsonpath='{.spec.ports[0].nodePort}')\"|value: \"${ACTUAL_FRONTEND_URL}\"|" backend-deployment.yaml

# Atau jika Anda menggunakan placeholder yang lebih eksplisit di YAML:
# value: "FRONTEND_URL_PLACEHOLDER"
# sed -i "s|FRONTEND_URL_PLACEHOLDER|${ACTUAL_FRONTEND_URL}|" backend-deployment.yaml

# Terapkan deployment
minikube kubectl -- apply -f backend-deployment.yaml

echo "Deployment backend diperbarui."
```
