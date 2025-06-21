#!/bin/bash

# Script de monitoring du déploiement Gearted
echo "🚀 Monitoring du déploiement Gearted..."
echo "═══════════════════════════════════════════"

# Fonction pour tester une URL
test_url() {
    local url=$1
    local description=$2
    local status_code=$(curl -s -o /dev/null -w "%{http_code}" "$url")
    
    if [ "$status_code" = "200" ]; then
        echo "✅ $description: OK (200)"
        return 0
    else
        echo "❌ $description: FAILED ($status_code)"
        return 1
    fi
}

# Fonction pour attendre le déploiement
wait_for_deployment() {
    echo "⏳ Attente du déploiement Render..."
    local count=0
    local max_attempts=20
    
    while [ $count -lt $max_attempts ]; do
        local status_code=$(curl -s -o /dev/null -w "%{http_code}" "https://gearted.eu")
        
        if [ "$status_code" = "200" ]; then
            echo "✅ Déploiement détecté !"
            return 0
        fi
        
        echo "⏳ Tentative $((count + 1))/$max_attempts - Status: $status_code"
        sleep 30
        count=$((count + 1))
    done
    
    echo "⚠️  Timeout - Déploiement non détecté après 10 minutes"
    return 1
}

# Test initial
echo "📡 Test initial..."
if test_url "https://gearted.eu" "Site principal"; then
    echo "🎉 Le site est déjà accessible !"
else
    echo "🔄 Le site n'est pas encore accessible, monitoring en cours..."
    if wait_for_deployment; then
        echo "🎉 Déploiement terminé !"
    else
        echo "❌ Problème de déploiement détecté"
        exit 1
    fi
fi

echo ""
echo "🧪 Tests détaillés..."

# Test des ressources critiques
echo "📁 Test des ressources Flutter..."
test_url "https://gearted.eu/main.dart.js" "JavaScript principal Flutter"
test_url "https://gearted.eu/flutter.js" "Runtime Flutter"
test_url "https://gearted.eu/flutter_service_worker.js" "Service Worker"

echo ""
echo "🎨 Test des assets..."
test_url "https://gearted.eu/assets/AssetManifest.json" "Manifeste des assets"
test_url "https://gearted.eu/assets/FontManifest.json" "Manifeste des polices"

echo ""
echo "🔍 Analyse du contenu..."

# Télécharger la page principale et analyser
echo "📄 Analyse de la page principale..."
main_content=$(curl -s "https://gearted.eu")

if echo "$main_content" | grep -q "flutter"; then
    echo "✅ Flutter détecté dans la page"
else
    echo "⚠️  Flutter non détecté - possible problème de build"
fi

if echo "$main_content" | grep -q "main.dart.js"; then
    echo "✅ Script principal Flutter référencé"
else
    echo "⚠️  Script principal non référencé"
fi

if echo "$main_content" | grep -q "Gearted\|GEARTED"; then
    echo "✅ Branding Gearted détecté"
else
    echo "⚠️  Branding non détecté"
fi

echo ""
echo "🏁 Tests terminés !"
echo ""
echo "🌐 Accédez à votre application : https://gearted.eu"
echo "🔧 Pour déboguer :"
echo "   - Ouvrez la console développeur (F12)"
echo "   - Vérifiez les erreurs dans l'onglet Console"
echo "   - Testez les fonctions d'authentification"
echo ""
echo "📊 Statut final :"
if curl -s --head "https://gearted.eu" | head -n 1 | grep -q "200"; then
    echo "✅ Application accessible et fonctionnelle"
    exit 0
else
    echo "❌ Problèmes détectés - vérification nécessaire"
    exit 1
fi
