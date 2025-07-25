#!/bin/bash

# Script untuk menambahkan/memperbarui entri Minikube di /etc/hosts

# Fungsi untuk memeriksa status Minikube
check_minikube_status() {
    echo "Memeriksa status Minikube..."
    if ! minikube status &>/dev/null; then
        echo "Minikube tidak berjalan atau tidak terinstal. Pastikan Minikube berjalan sebelum melanjutkan."
        exit 1
    fi
    echo "Minikube berjalan."
}

# Fungsi untuk menambahkan atau memperbarui entri di /etc/hosts
update_hosts_entry() {
    local minikube_ip="$1"
    local domain="$2"
    local hosts_file="/etc/hosts"

    # Periksa apakah entri sudah ada
    if grep -q "${minikube_ip}\s*${domain}" "${hosts_file}"; then
        echo "Entri '${domain}' dengan IP '${minikube_ip}' sudah ada di ${hosts_file}. Melewati."
    else
        # Periksa apakah domain sudah ada dengan IP lain, dan hapus jika ya
        if grep -q "\s*${domain}" "${hosts_file}"; then
            echo "Memperbarui entri untuk '${domain}' di ${hosts_file}..."
            sudo sed -i "/\s*${domain}/d" "${hosts_file}"
        else
            echo "Menambahkan entri baru untuk '${domain}' ke ${hosts_file}..."
        fi
        # Tambahkan entri baru
        echo "${minikube_ip} ${domain}" | sudo tee -a "${hosts_file}" > /dev/null
        echo "Entri '${minikube_ip} ${domain}' berhasil ditambahkan/diperbarui."
    fi
}

# Main logic
check_minikube_status

MINIKUBE_IP=$(minikube ip)
if [ -z "$MINIKUBE_IP" ]; then
    echo "Gagal mendapatkan IP Minikube. Pastikan Minikube berjalan dengan baik."
    exit 1
fi

echo "Minikube IP terdeteksi: ${MINIKUBE_IP}"

# Daftar domain yang akan ditambahkan
DOMAINS=("wondr.desktop.com")

for domain in "${DOMAINS[@]}"; do
    update_hosts_entry "${MINIKUBE_IP}" "${domain}"
done

echo ""
echo "Pembaruan /etc/hosts selesai."
echo "Anda mungkin perlu me-restart browser atau flush DNS cache Anda."
echo "Untuk Linux, coba: sudo systemd-resolve --flush-caches"
echo "Untuk macOS, coba: sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder"
