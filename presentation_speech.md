# Discours de Présentation - Projet Notre-Dame PRO

**Durée estimée :** ~10-15 minutes
**Public cible :** Jury, Direction, ou Investisseurs

---

## 1. Introduction (2-3 minutes)

**"Bonjour à toutes et à tous, et merci de votre présence aujourd'hui."**

**[Le contexte & le Problème]**
"Aujourd'hui, la gestion d'un établissement scolaire moderne est devenue un défi complexe. Entre le suivi pédagogique des élèves, la communication avec les parents, la gestion des enseignants et les tâches administratives, les établissements croulent sous la paperasse et les processus manuels qui ralentissent la transmission de l'information."

**[La Solution]**
"C'est pour répondre à ces défis que nous avons conçu et développé **Notre-Dame PRO** : une plateforme numérique complète, intégrée et sur-mesure. Notre vision était simple : réunir **tous** les acteurs de la vie scolaire — la Direction, les Professeurs, les Parents et les Élèves — autour d'un écosystème unique, sécurisé et accessible en temps réel."

---

## 2. Architecture et Technologies (2 minutes)

**"Pour soutenir cette ambition, nous avons opté pour une architecture technique robuste et moderne."**

- **Le Cœur du Système (Backend)** : "Le moteur de notre application est développé sous **Laravel**, un framework PHP réputé pour sa sécurité et sa scalabilité. Il agit comme une API RESTful centrale qui protège les données et gère une logique métier complexe (droits d'accès, processus de validation, etc.)."
- **Les Portails Web (Frontend)** : "Pour l'administration, le secrétariat et les élèves, nous avons développé des interfaces web réactives et fluides en **React.js**. Cela garantit une expérience utilisateur optimale sur ordinateur comme sur tablette."
- **Les Applications Mobiles** : "Enfin, parce que les parents et les professeurs ont besoin de mobilité, nous avons développé des applications natives en **Flutter**, leur permettant d'avoir l'école littéralement dans leur poche."

---

## 3. Les Fonctionnalités Clés par Acteur (5-7 minutes)

**"Découvrons concrètement comment Notre-Dame PRO transforme le quotidien de chaque utilisateur."**

### A. La Direction et le Censeur (Portail Web)
"Le rôle du Censeur est crucial pour la rigueur académique. Sur son tableau de bord, il a une vue globale :
- Il construit les emplois du temps.
- Il a un droit de regard absolu sur la **validation des notes**. Un aspect majeur de notre système est que *les professeurs insèrent les notes, mais seul le Censeur ou la Direction peut modifier une note déjà saisie*. Cela garantit la traçabilité et l'intégrité des bulletins.
- Il supervise les présences et les plaintes enregistrées par la surveillance."

### B. Le Secrétariat et la Scolarité (Portail Web)
"Le secrétariat est le premier point de contact :
- Il gère la base de données des élèves et leur immatriculation.
- Il met à disposition une **bibliothèque d'Anciennes Épreuves** (sujets d'examens passés en format PDF) pour l'entraînement des élèves.
- Récemment, nous avons intégré un module spécialisé pour la saisie groupée des résultats des **Examens Blancs et Examens Nationaux**, afin d'avoir une centralisation parfaite des performances."

### C. Les Professeurs (Application Mobile Flutter / Web)
"Les enseignants gagnent un temps précieux :
- Depuis leur smartphone, ils remplissent le **Cahier de Texte numérique** après chaque cours.
- Ils saisissent les notes (Interrogations, Devoirs) directement en ligne, depuis l'application. Plus besoin de fiches papier qui peuvent se perdre."

### D. Les Parents (Application Mobile Flutter)
"C'est souvent le maillon faible dans les écoles traditionnelles. Avec notre app Parent :
- Ils sont alertés en temps réel si leur enfant est absent.
- Ils consultent les notes et disposent de **graphiques analytiques (BarCharts)** pour visualiser l'évolution de leur enfant.
- Ils peuvent suivre le statut de leurs paiements auprès de la caisse, tout ça depuis leur téléphone."

### E. Les Élèves (Portail Web - Espace Élève)
"L'élève est responsabilisé :
- Il se connecte via son **matricule unique**.
- Il accède à son propre tableau de bord pour consulter ses relevés de notes par trimestre.
- Il peut télécharger et s'exercer sur les anciennes épreuves ajoutées par le secrétariat."

---

## 4. Sécurité et Fiabilité (1-2 minutes)

**"Une donnée scolaire est une donnée sensible. C'est pourquoi la sécurité a été au centre de notre développement."**

"L'ensemble des requêtes passe par une authentification par tokens (**Laravel Sanctum**). Nous avons implémenté des **Middlewares stricts** définissant les rôles : un professeur ne peut pas accéder aux données financières de la caisse, et un élève ne voit que ses notes.
De plus, chaque action sensible, comme la modification d'une note, est tracée et horodatée (savoir *qui* a validé *quoi* et *quand*)."

---

## 5. Conclusion (1 minute)

**"En conclusion..."**

"Notre-Dame PRO n'est pas qu'un simple logiciel de gestion. C'est un véritable **partenaire numérique** qui optimise le temps administratif de 40%, augmente la transparence avec les familles de 100%, et permet au corps enseignant de se concentrer sur l'essentiel : l'éducation de nos enfants.

L'architecture que nous avons mise en place aujourd'hui est prête à évoluer, que ce soit pour intégrer des moyens de paiement mobiles locaux (Mobile Money) ou de l'Intelligence Artificielle pour prédire le décrochage scolaire.

Je vous remercie de votre attention et serai ravi de vous faire une démonstration en direct ou de répondre à vos questions."
