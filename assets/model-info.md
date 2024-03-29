## À propos du modèle

Les prédictions visualisées sur cette application ont été créées par un modèle géostatistique. Ce modèle combine les données du système de santé et les données écologiques obtenues par télédétection pour prédire le taux du paludisme en fonction des variables socio-écologiques. Les spécifications du modèle sont rapportées dans Evans et al. (*in prep*).

<p style="text-align:center;"><img src="model-workflow.png" alt="Modeling Workflow" width="600px"></p>

### Les facteurs prises en compte

Nous avons inclus quatorze variables sociales et environnementales dans le modèle prédictif. Il s'agit de sept variables statiques et de sept variables dynamiques, qui sont mises à jour mensuellement.

| **Variable**                   | **Définition**                                                                                                                                                         |
|--------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Temperature                    | Température moyenne mensuelle                                                                                                                                          |
| Précipitation                  | Précipitations mensuelles totales                                                                                                                                      |
| MNDWI (Village)               | McFeeter's Normalized Difference Water Index: Identification de l'eau de surface et zones inondés par mois dans les quatre plus grands villages du fokontany           |
| EVI (Village)                  | Enhanced Vegetation Index: Indicateur représentant l'abondance de la vegetation verte par mois dans les quatre plus grands villages du fokontany                       |
| Indicateur Rizière             | Trois indicateurs mensuels dérivés d'une 'Principal Components Analysis' de tous les indicateurs de végétation et d'inondation observés dans les rizières du fokontany |
| Distance au CSB                | Moyenne distance au CSB                                                                                                                                                |
| TWI (Village)                  | Topographic Wetness Index: Indicateur représentant la tendance de l'eau à s'accumuler. Moyenne dans les quatre plus grands villages du fokontany                       |
| Proportion de Plaine Inondable | La proportion de terres dans un fokontany caractérisée comme une plaine d'inondation ("topographic sink")                                                              |
| Richesse                       | Moyenne niveau socio-économique du fokontany                                                                                                                           |
| Densité de Bâtiments           | Le nombre moyen de bâtiments dans un rayon de 100 m autour d'un bâtiment                                                                                                |
| Proportion Rizière             | La proportion de terres dans un fokontany caractérisée comme une rizière                                                                                               |
| TWI (Rizière)                  | Topographic Wetness Index: Indicateur représentant la tendance de l'eau à s'accumuler. Moyenne des rizières     

<p style="text-align:center;"><img src="variable-maps.png" alt="Maps of Variables" width="900px"></p>


### Validation du modèle

En générale, notre modèle reproduit bien les dynamics du paludisme dans le district. Son 'root-mean-square-error' est de 67.48 cas par 1000 individus et sa corrélation de Spearman est 0.640. Plus de détails sur la performance de modèle se trouvent dans Evans et al. (*in prep*).

<p style="text-align:center;"><img src="validation-fkt.png" width="600px"></p>

Notre estimation du nombre de cas ressemble également au nombre "réel" de cas observés dans les CSB.

<p style="text-align:center;"><img src="validation-case.png" width="600px"></p>
