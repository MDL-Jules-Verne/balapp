# Balapp
Ce repo est la partie front de l'appliction Balapp.
Pour utiliser l'application, voir [la partie backend](https://github.com/MDL-Jules-Verne/balapp-api)

## Explication de l'application
### Démarrage
Au lancement, il est demandé de renseigner un nom. Il est utilisé pour séparer les applications dans le dashboard.
Ensuite l'ip d'un serveur est demandée. [voir la partie backend](https://github.com/MDL-Jules-Verne/balapp-api)

### Pages
 * ![Home](https://github.com/MDL-Jules-Verne/balapp/blob/new/READMEpics/Home.jpg?raw=true)Home: Barre de recherche pour les vestiaires et les boissons gratuites. Peut être utilisé en cas de doute sur un billet. Le bouton SCAN permet de chercher un ticket en le scannant. **Seuls les tickets enregistrés sont montrés**  
 Cliquer sur un ticket l'ajoute dans la popup en bas et montre ses objets aux vestiaires.
 * ![Scan](https://github.com/MDL-Jules-Verne/balapp/blob/new/READMEpics/Scan.jpg?raw=true)Scan: Accessible avec le bouton en forme de qrcode sur la page d'accueil.
 En mode buy, scanner un billet permet de l'enregistrer. En mode bal, permet de s'assurer qu'un billet n'est pas utilisé plusieurs fois. Un bouton pour allumer le flash ainsi qu'un bouton pour une recherche rapide sont disponibles. Cliquer sur un ticket dans la recherche rapide permet de faire comme si il avait été scanné : utile si le qrcode du billet est illisible.
 * ![Settings](https://github.com/MDL-Jules-Verne/balapp/blob/new/READMEpics/Settings.jpg?raw=true)Réglages: Accessible avec l'engrenage dans la page d'accueil.
 Sont disponibles 
    * Le bouton de connexion au serveur et son statut
    * Mode hors ligne. En cas de problèmes de connexion, utiliser le mode hors ligne et en sortir pour synchroniser les opérations faites en mode hors ligne. **Ne pas utiliser plus d'un téléphone en mode hors ligne en mode bal**
    * Changer de mode. En mode hors ligne le mode n'est pas synchronisé, il est donc parfois nécéssaire de le modifier.
    * Exporter les données. En mode hors ligne, partage la base locale. En mode connecté, partage la base distante
 * ![Vestiaires](https://github.com/MDL-Jules-Verne/balapp/blob/new/READMEpics/Vestiaires.jpg?raw=true)Vestiaires: Accessible en mode bal avec l'icone de cintre. Commencer par scanner un ticket. Ajouter ensuite en fonction des objets apportés. La suite alphanumérique qui appraraît est l'ID du vêtement, nous conseillons de l'écrire sur un scotch ou une étiquette s'accrochant sur l'objet. 
    * Le premier chiffre est l'ID de la zone
    * La lettre qui suit est le type d'objet
    * Les deux chiffres suivants sont le numéro de l'objet
* Quand une zone est pleine, cliquer sur EDIT OPEN ZONES et décocher la zone en question, l'application arrêtera d'envoyer des vêtements dans les zones décochées
