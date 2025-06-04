#!/bin/bash
echo "🗑️ Удаление lesta-app через Helm"

echo "📦 Удаление Helm релиза lesta-app..."
if helm list | grep -q lesta-app; then
    helm uninstall lesta-app
    echo "✅ Helm релиз lesta-app удален"
else
    echo "⚠️ Helm релиз lesta-app не найден"
fi

echo "🐳 Очистка Docker образа..."
eval $(minikube docker-env 2>/dev/null) || true
if docker images | grep -q lesta-start:7.1; then
    docker rmi lesta-start:7.1
    echo "✅ Docker образ lesta-start:7.1 удален"
else
    echo "⚠️ Docker образ lesta-start:7.1 не найден"
fi

echo ""
echo "✅ Очистка Helm развертывания завершена!"
echo "📊 Проверка: helm list"
