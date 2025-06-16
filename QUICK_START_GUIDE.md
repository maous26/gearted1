# 🎯 Guide d'Utilisation Rapide - Workflow Gearted

## ✅ Configuration Terminée !

Votre workflow de développement professionnel est maintenant configuré et testé avec succès.

## 🚀 Utilisation Quotidienne

### 1. Développer une Nouvelle Fonctionnalité

```bash
# Créer une branche feature
./scripts/dev-workflow.sh feature nom-fonctionnalite

# Développer votre code...
# Puis finaliser
./scripts/dev-workflow.sh finish_feature nom-fonctionnalite
```

### 2. Déployer et Tester

```bash
# Déployer en staging pour tests
./scripts/dev-workflow.sh staging

# Tester sur staging, puis déployer en production
./scripts/dev-workflow.sh production
```

### 3. Corrections Urgentes

```bash
# Créer un hotfix
./scripts/dev-workflow.sh hotfix nom-urgence

# Corriger le problème...
# Puis déployer immédiatement
./scripts/dev-workflow.sh finish_hotfix nom-urgence
```

## 📋 Commandes Utiles

```bash
# Voir l'état du projet
./scripts/dev-workflow.sh status

# Nettoyer les branches
./scripts/dev-workflow.sh cleanup

# Lancer tous les tests
./scripts/dev-workflow.sh test

# Configurer Redis (améliore les performances)
./scripts/setup-redis.sh

# Aide complète
./scripts/dev-workflow.sh help
```

## ⚡ Optimisation des Performances

### Redis Cache (Recommandé)

Pour améliorer significativement les performances de votre API :

```bash
# Installation Redis local (développement)
./scripts/setup-redis.sh

# Configuration Redis Cloud (production)
# Voir REDIS_SETUP_GUIDE.md pour les détails
```

**Impact** : Redis améliore les temps de réponse de 3-5x et réduit la charge sur MongoDB.

## 🌍 URLs de votre Application

### Production (LIVE)
- **Backend** : https://gearted.eu ✅
- **Backend Render** : https://gearted-backend.onrender.com ✅
- **Admin** : https://admin.gearted.eu (à configurer)

### Staging (Tests)
- **Backend** : https://gearted-backend-staging.onrender.com (à configurer)
- **Admin** : https://gearted-admin-staging.netlify.app (à configurer)

### Développement (Local)
- **Backend** : http://localhost:3000
- **Mobile** : Émulateur/Device
- **Admin** : http://localhost:3001

## 📊 Structure des Branches

```
main (production) ←── staging (tests) ←── develop (intégration)
                                              ↑
                                    feature/ma-fonctionnalite
```

## 🎯 Exemples Concrets

### Ajouter une API de notifications
```bash
./scripts/dev-workflow.sh feature api-notifications
# Développer dans gearted-backend/src/api/routes/notifications.routes.ts
./scripts/dev-workflow.sh finish_feature api-notifications
./scripts/dev-workflow.sh staging
./scripts/dev-workflow.sh production
```

### Ajouter une page mobile
```bash
./scripts/dev-workflow.sh feature page-profile
# Développer dans gearted-mobile/lib/screens/profile_screen.dart
./scripts/dev-workflow.sh finish_feature page-profile
./scripts/dev-workflow.sh staging
./scripts/dev-workflow.sh production
```

### Correction d'urgence
```bash
./scripts/dev-workflow.sh hotfix auth-token-bug
# Corriger dans gearted-backend/src/middlewares/auth.middleware.ts
./scripts/dev-workflow.sh finish_hotfix auth-token-bug
```

## 📖 Documentation Complète

- 📖 [Guide Détaillé du Workflow](DEVELOPMENT_WORKFLOW_GUIDE.md)
- ✅ [Checklist de Développement](DEVELOPMENT_CHECKLIST.md)
- ☁️ [Plan de Déploiement](CLOUD_DEPLOYMENT_PLAN.md)

## 🎉 Félicitations !

Votre environnement de développement professionnel Gearted est prêt !

Vous pouvez maintenant développer de manière organisée et déployer en toute sécurité. 

**Prochaine étape** : Commencez à développer votre première fonctionnalité ! 🚀
