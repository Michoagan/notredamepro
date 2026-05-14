# Frontend Direction - Guide de Démarrage

Ce dossier contient l'application React pour l'interface de Direction (Directeur, Comptable, etc.).

## Pré-requis
*   **Node.js** doit être installé sur votre machine.

## Installation et Lancement
Comme l'installation automatique a échoué, vous devez lancer ces commandes manuellement dans votre terminal :

1.  Ouvrez un terminal (PowerShell ou CMD).
2.  Allez dans le dossier du frontend :
    ```bash
    cd frontend-direction
    ```
3.  Installez les dépendances :
    ```bash
    npm install
    ```
4.  Lancez le serveur :
    ```bash
    npm run dev
    ```
5.  Ouvrez votre navigateur sur l'URL affichée (ex: `http://localhost:3000`).

## Fonctionnalités incluses
*   **Login** : Connexion sécurisée avec l'API Laravel (`/api/direction/login`).
*   **Tableau de Bord** : Structure de base avec menu latéral.
*   **Comptabilité** : Vue des Entrées/Sorties et Solde (connecté au `ComptabiliteController`).

## Structure du Code
*   `src/App.jsx` : Routeur principal et Layout (Sidebar).
*   `src/pages/Login.jsx` : Page de connexion.
*   `src/pages/Comptabilite.jsx` : Page du tableau de bord comptable.
*   `src/services/api.js` : Configuration Axios (Proxy vers Laravel).
