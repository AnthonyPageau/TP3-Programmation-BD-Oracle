# README – TP3 Programmation BD / Oracle  

## Contributeurs
**ANTHONY PAGEAU 2411872** 
**VINCENT ROMPRÉ 1940374**

## Répartition des tâches

### Script de création 
- **ANTHONY PAGEAU**

### Procédures opérationnelles
- `ajouter_projet` — **ANTHONY PAGEAU**
- `affecter_equipement` — **ANTHONY PAGEAU**
- `planifier_experience` — **ANTHONY PAGEAU**
- `supprimer_projet` — **VINCENT ROMPRÉ**
- `journaliser_action` — **ANTHONY PAGEAU**

### Fonctions opérationnelles
- `calculer_duree_projet` — **VINCENT ROMPRÉ**
- `verifier_disponibilite_equipement` — **ANTHONY PAGEAU**
- `moyenne_mesures_experience` — **ANTHONY PAGEAU**

### Reporting
- `rapport_projets_par_chercheur` — **ANTHONY PAGEAU**
- `statistiques_equipements` — **VINCENT ROMPRÉ**
- `rapport_activite_projets` — **VINCENT ROMPRÉ**
- `budget_moyen_par_domaine` — **ANTHONY PAGEAU**

### Déclencheurs (Triggers)
- `trg_projet_before_insert` — **ANTHONY PAGEAU**
- `trg_affectation_before_insert` — **ANTHONY PAGEAU**
- `trg_affectation_after_insert` — **ANTHONY PAGEAU**
- `trg_affectation_after_delete` — **ANTHONY PAGEAU**
- `trg_experience_after_insert` — **ANTHONY PAGEAU**
- `trg_echantillon_before_insert` — **VINCENT ROMPRÉ**
- `trg_log_before_insert` — **VINCENT ROMPRÉ**
- `trg_securite_after_update` — **VINCENT ROMPRÉ**
- `trg_chercheur_crypter_nom` — **ANTHONY PAGEAU**

### Sécurité & Privilèges
- Création des rôles — **ANTHONY PAGEAU**
- Attribution des privilèges — **ANTHONY PAGEAU**
- Création des vues sécurisées — **ANTHONY PAGEAU**

### Documentations / Rapport
- Rédaction du rapport PDF — **VINCENT ROMPRÉ**
- Mise à jour du README — **ANTHONY PAGEAU**

## Instructions de lancement

### 1. Création du schéma
- @sql/creation_tables.sql
- @sql/vues_securite.sql

### 2. Chargement des données
- @sql/insertions.sql

### 3. Création des procédures et fonctions
- @plsql/procedures_oper.sql
- @plsql/fonctions_oper.sql
- @plsql/reporting.sql

### 4. Création des déclencheurs
- @plsql/triggers.sql

### 5. Création des transactions
- @plsql/transactions.sql

### 6. Blocs de test
- @tests/tests_blocs.sql

### Date de remise
- 12 décembre 2025

### État du projet
- Terminé
