#!/bin/bash
echo "🧪 Тестирование Helm Chart..."

echo "📋 Проверка синтаксиса Chart..."
helm lint ./helm/lesta-chart

echo "🔍 Dry-run установки..."
helm install lesta-app ./helm/lesta-chart --dry-run --debug

echo "📄 Генерация итоговых манифестов..."
helm template lesta-app ./helm/lesta-chart > generated-manifests.yaml

echo "✅ Тестирование завершено!"
echo "📄 Проверьте файл generated-manifests.yaml"
