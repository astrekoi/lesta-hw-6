#!/bin/bash
set -e

echo "🚀 Развертывание lesta-app через Helm Chart"

echo "🔧 Проверка наличия Helm..."
if ! command -v helm &> /dev/null; then
    echo "📥 Helm не найден. Установка Helm..."
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod +x get_helm.sh
    ./get_helm.sh
    rm get_helm.sh
    echo "✅ Helm установлен"
else
    echo "✅ Helm уже установлен: $(helm version --short)"
fi

echo "🔍 Проверка статуса minikube..."
if ! minikube status &>/dev/null; then
    echo "❌ Minikube не запущен. Запускаем..."
    minikube delete 2>/dev/null || true
    minikube start --driver=docker --memory=4096 --cpus=2

    echo "⏳ Ожидание готовности API сервера..."
    for i in {1..30}; do
        if kubectl cluster-info &>/dev/null; then
            echo "✅ API сервер готов"
            break
        fi
        echo "Попытка $i/30..."
        sleep 10
    done
fi

echo "🐳 Настройка Docker окружения..."
eval $(minikube docker-env)

echo "🏗️ Сборка Docker образа..."
docker build -t lesta-start:7.1 .

echo "🧹 Очистка предыдущего Helm релиза..."
helm uninstall lesta-app 2>/dev/null || echo "Предыдущий релиз не найден"

echo "📦 Установка приложения через Helm..."
helm install lesta-app ./helm/lesta-chart

echo "⏳ Ожидание готовности PostgreSQL..."
kubectl wait --for=condition=ready pod -l app=postgres --timeout=180s

echo "⏳ Ожидание готовности приложения..."
kubectl wait --for=condition=ready pod -l app=lesta-app --timeout=180s

echo "🌐 Информация о доступе к приложению:"
NODEPORT=$(kubectl get service lesta-app-service -o jsonpath='{.spec.ports[0].nodePort}')
MINIKUBE_IP=$(minikube ip)

echo ""
echo "✅ Развертывание через Helm завершено успешно!"
echo ""
echo "📋 Способы доступа:"
echo "1. NodePort:     http://$MINIKUBE_IP:$NODEPORT"
echo "2. Ingress:      http://lesta.local"
echo "3. Тест ping:    curl http://$MINIKUBE_IP:$NODEPORT/ping"
echo ""
echo "🔧 Настройка hosts (для Ingress):"
echo "echo '$MINIKUBE_IP lesta.local' | sudo tee -a /etc/hosts"
echo ""
echo "📊 Управление Helm релизом:"
echo "helm status lesta-app       # Статус релиза"
echo "helm list                   # Список всех релизов"
echo "helm uninstall lesta-app    # Удаление релиза"
echo ""
echo "🔍 Мониторинг:"
echo "kubectl get pods,svc,ingress"
echo "kubectl logs -f deployment/lesta-app"
