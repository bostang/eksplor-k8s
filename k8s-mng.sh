#!/bin/bash

# Script untuk mengelola deployment aplikasi di Minikube

# Fungsi untuk memeriksa status Minikube
check_minikube_status() {
    echo "Memeriksa status Minikube..."
    if ! minikube status &>/dev/null; then
        echo "Minikube tidak berjalan atau tidak terinstal. Pastikan Minikube berjalan sebelum melanjutkan."
        exit 1
    fi
    echo "Minikube berjalan."
}

# Fungsi untuk menjalankan (deploy) aplikasi
run_app() {
    check_minikube_status

    echo "Menerapkan resource dasar (Secrets, ConfigMaps, PVCs, Services)..."
    # Terapkan resource yang tidak bergantung pada NodePort dinamis atau deployment lainnya
    # Urutan penting untuk dependensi (misal: Secret sebelum Deployment yang menggunakannya)
    minikube kubectl -- apply -f backend-secrets.yml
    minikube kubectl -- apply -f db_backend-init-script-configmap.yml
    minikube kubectl -- apply -f db_verifikator-init-script-configmap.yml
    minikube kubectl -- apply -f db_backend-pvc.yml
    minikube kubectl -- apply -f db_verifikator-pvc.yml
    minikube kubectl -- apply -f backend-service.yml
    minikube kubectl -- apply -f db_backend-service.yml
    minikube kubectl -- apply -f db_verifikator-service.yml
    minikube kubectl -- apply -f frontend-service.yml
    minikube kubectl -- apply -f verifikator-service.yml

    echo "Menunggu sebentar agar services siap..."
    sleep 5 # Beri waktu sebentar agar service benar-benar terdaftar

    echo "Menerapkan Ingress Resources (hanya untuk Frontend)..."
    minikube kubectl -- apply -f frontend-ingress.yml # Hanya frontend yang terekspos via Ingress

    echo "Menerapkan Deployment..."
    # Terapkan Deployments dalam urutan yang logis (misal: database dulu, lalu backend, frontend, verifikator)
    minikube kubectl -- apply -f db_backend-deployment.yml
    minikube kubectl -- apply -f db_verifikator-deployment.yml
    minikube kubectl -- apply -f backend-deployment.yml
    minikube kubectl -- apply -f frontend-deployment.yml
    minikube kubectl -- apply -f verifikator-deployment.yml

    echo "Deployment selesai. Memeriksa status semua resource..."
    minikube kubectl -- get all

    echo ""
    echo "Aplikasi Anda sekarang dapat diakses melalui Ingress (Frontend)."
    echo "Pastikan Anda telah menambahkan entri ke file /etc/hosts Anda (atau setara di Windows):"
    echo "  $(minikube ip) wondr.desktop.com"
    echo "Kemudian akses frontend di browser Anda melalui: http://wondr.desktop.com"
    echo ""
    echo "Backend API diakses secara internal oleh frontend melalui: http://backend-service:8080"
    echo "Verifikator API diakses secara internal oleh frontend melalui: http://verifikator-service:8081"
}

# Fungsi untuk menghentikan (delete) aplikasi
stop_app() {
    check_minikube_status

    echo "Menghapus semua resource Kubernetes..."
    minikube kubectl -- delete -f .

    echo "Penghapusan selesai. Memeriksa status..."
    minikube kubectl -- get all
}

# Fungsi untuk melihat log dari deployment tertentu
get_logs() {
    check_minikube_status
    local deployment_name="$1"
    if [ -z "$deployment_name" ]; then
        echo "Penggunaan: --logs <nama_deployment>"
        echo "Contoh: --logs backend-deployment"
        exit 1
    fi
    echo "Melihat log untuk deployment: ${deployment_name}..."
    minikube kubectl -- logs -f deployment/${deployment_name}
}

# Fungsi untuk mendapatkan URL frontend service
get_frontend_url() {
    check_minikube_status
    echo "Mendapatkan URL frontend service untuk diakses di browser..."
    MINIKUBE_IP=$(minikube ip)
    if [ -z "$MINIKUBE_IP" ]; then
        echo "Gagal mendapatkan IP Minikube. Pastikan Minikube berjalan dengan baik."
        exit 1
    fi

    FRONTEND_NODEPORT=$(minikube kubectl -- get service frontend-service -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null)
    if [ -z "$FRONTEND_NODEPORT" ]; then
        echo "Frontend service belum terdeploy atau NodePort belum dialokasikan."
        exit 1
    fi

    echo "URL Frontend Service (NodePort): http://${MINIKUBE_IP}:${FRONTEND_NODEPORT}"
    echo ""
    echo "Untuk akses melalui Ingress, gunakan domain yang sudah Anda atur di /etc/hosts:"
    echo "  http://wondr.desktop.com"
}

# Fungsi untuk mengeksekusi perintah di dalam container deployment tertentu
exec_command() {
    check_minikube_status
    local deployment_name="$1"
    shift # Geser argumen pertama ($1)
    local command="$@" # Semua argumen sisanya adalah perintah

    if [ -z "$deployment_name" ] || [ -z "$command" ]; then
        echo "Penggunaan: --exec <nama_deployment> <perintah>"
        echo "Contoh: --exec backend-deployment bash"
        echo "Contoh: --exec db-backend-deployment psql -U postgres"
        exit 1
    fi

    echo "Mengeksekusi perintah '${command}' di deployment: ${deployment_name}..."
    # Dapatkan nama pod dari deployment
    POD_NAME=$(minikube kubectl -- get pods -l app=${deployment_name%%-deployment*} -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
    if [ -z "$POD_NAME" ]; then
        echo "Tidak dapat menemukan pod untuk deployment ${deployment_name}. Pastikan deployment berjalan."
        exit 1
    fi
    minikube kubectl -- exec -it ${POD_NAME} -- ${command}
}

# Fungsi untuk melihat variabel lingkungan dari container deployment tertentu
get_env() {
    check_minikube_status
    local deployment_name="$1"
    if [ -z "$deployment_name" ]; then
        echo "Penggunaan: --env <nama_deployment>"
        echo "Contoh: --env backend-deployment"
        exit 1
    fi
    echo "Melihat variabel lingkungan untuk deployment: ${deployment_name}..."
    # Dapatkan nama pod dari deployment
    POD_NAME=$(minikube kubectl -- get pods -l app=${deployment_name%%-deployment*} -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
    if [ -z "$POD_NAME" ]; then
        echo "Tidak dapat menemukan pod untuk deployment ${deployment_name}. Pastikan deployment berjalan."
        exit 1
    fi
    minikube kubectl -- exec -it ${POD_NAME} -- env
}

get_pods() {
    check_minikube_status
    echo "Mendapatkan daftar pods..."
    minikube kubectl -- get pods
}

get_services() {
    check_minikube_status
    echo "Mendapatkan daftar services..."
    minikube kubectl -- get services
}


# Logika argumen
case "$1" in
    --run)
        run_app
        ;;
    --stop)
        stop_app
        ;;
    --logs)
        get_logs "$2"
        ;;
    --url)
        get_frontend_url
        ;;
    --exec)
        # Shift argumen pertama (--exec) dan teruskan sisanya
        shift
        exec_command "$@"
        ;;
    --env)
        get_env "$2"
        ;;
    --pods)
        get_pods
        ;;
    --services)
        get_services
        ;;
    *)
        echo "Penggunaan: $0 [--run | --stop | --logs <nama_deployment> | --url | --exec <nama_deployment> <perintah> | --env <nama_deployment> | --pods | --services]"
        echo "  --run : Menerapkan semua manifest Kubernetes (termasuk Ingress)."
        echo "  --stop: Menghapus semua resource Kubernetes."
        echo "  --logs <nama_deployment>: Melihat log dari deployment tertentu (misal: backend-deployment, frontend-deployment)."
        echo "  --url : Menampilkan URL frontend service (NodePort) dan URL Ingress untuk diakses di browser."
        echo "  --exec <nama_deployment> <perintah>: Mengeksekusi perintah di dalam container deployment (misal: bash, ls -l)."
        echo "  --env <nama_deployment>: Menampilkan variabel lingkungan dari container deployment."
        echo "  --pods : Menampilkan daftar pods yang ada."
        echo "  --services : Menampilkan daftar services yang ada."
        echo "Contoh: $0 --run"
        echo "Contoh: $0 --logs backend-deployment"
        echo "Contoh: $0 --exec backend-deployment bash"
        echo "Contoh: $0 --env backend-deployment"
        echo "Contoh: $0 --pods"
        echo "Contoh: $0 --services"
        exit 1
        ;;
esac
