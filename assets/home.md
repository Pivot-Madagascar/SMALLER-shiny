## Bienvenue au SMALLER!

Cette application fait partie du projet 'Surveillance and control of malaria at the local level using e-health platforms' (SMALLER) et a été créé en collaboration avec [Institut de Recherche pour le Développement](https://www.ird.fr/) et l'ONG [Pivot](https://www.pivotworks.org/). Elle présente les données historiques et les prédictions futures concernant le paludisme pour le district d'Ifanadiana à Vatovavy, Madagascar.

### Comment l'utiliser?

La barre de navigation à gauche contient des pages présentant différents types d'informations sur le paludisme:

- **Palu en Bref**: Un tableau de bord avec des alertes sur quatre indicateurs et une carte d'incidence prévue pour les trois prochains mois. En cliquant sur un fokontany, une fenêtre s'affiche avec les séries temporelles actuelles et historiques pour ce fokontany.

- **Tableau des Données**: Cette page contient un tableau des incidences et des nombres de cas que l'utilisateur peut explorer en filtrant sur une commune ou un fokontany donné. Les données peuvent également être téléchargées sur cette page.

- **Besoins Communautaires**: Cette page affiche le nombre total de cas attendus par fokontany, répartis entre les cas prévus pour être traités au CSB et ceux qui restent au niveau communautaire. Elle peut être utilisée pour planifier la quantité des intrants nécessaire à chaque niveau du système de santé.

- **Besoins aux CSBs**: Cette page fournit des informations sur les besoins de médicaments antipaludiques passés et prévus sous la forme de polythérapies à base d'artémisinine (ACT) au niveau du CSB. Ces informations ne sont actuellement disponibles que pour les CSB2.

### Mises à Jours

- **22 Jan 2026**: Depuis janvier 2026, le modèle utilise les données de température d'ERA5 au lieu de MODIS et CFSv2 en raison du manque de disponibilité des données CFSv2 sur Google Earth Engine.
- **10 Mars 2025**: Le modèle maintenant prend en compte la distribution des moustiquaires qui a eu lieu en octobre 2024.
- **11 Nov 2024**: L'estimation des cas venant aux formations sanitaires a été mis à jour avec les données jusqu'à septembre 2024.
- **8 Oct 2024**: Les données d'entrainement sont maintenant à jour jusqu'à septembre 2024.

### Contactez-nous

Avez-vous des questions ou des suggestions? N'hesitez-pas de nous contacter [par mail](mailto:mv.evans.phd@gmail.com) ou par notre repo [gitlab](https://gitlab.com/pivot-sci-apps/smaller-shiny)..

### Code source

L'ensemble du code source est disponible sur un repo [gitlab](https://gitlab.com/pivot-sci-apps/smaller-shiny). Les spécifications de la modèle géostatistique qui produit les prédictions sont rapportées dans Evans et al. (*in prep*).

### License

GPL-3+
