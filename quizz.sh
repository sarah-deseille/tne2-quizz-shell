#!/usr/bin/bash
source quizz.lib
SEPARATOR=":" #séparateur par défaut
FILE_EXIST=false #fichier par défaut inexistant
DIR_EXIST=false #répertoire par défaut inexistant
opt_f=false #option -f non utilisée
opt_r=false #option -r non utilisée
opt_q=false #option -q non utilisée

# gestion des options avec getopts
while getopts "d:f:hp:q:r:sv" opt; do
    case $opt in
    #indique le séparateur à utiliser
    d)
        SEPARATOR=$OPTARG
        ;;
    #indique le fichier de données à utiliser
    f)
        DATA_FILE=$OPTARG
        if [ -e $DATA_FILE ] #vérifier l'existence d'un fichier 
        then
            FILE_EXIST=true
        else
            echo "Le fichier n'existe pas" >&2
            exit 1
        fi
        opt_f=true
        ;;
    #affiche le synopsis du script + s'arrêter
    h)
cat <<HERE >&2 #mise en place d'un here document nommé HERE
Le programme peut fonctionner sans options. Les fonctions possibles sont les suivantes :
    -d : indique le séparateur à utiliser
    -f : indique le fichier de données à utiliser
    -h : affiche le synopsis du script + s'arrêter
    -p : indique le répertoire fic. de données
    -q : indique le numéro de la colonne question
    -r : indique le numéro de la colonne réponse
    -s : affiche les meilleurs scores triés + pseudo + nb points
    -v : mode verbeux : affiche les réponses à saisir
HERE
        exit 1
        ;;
    #indique le répertoire fic. de données
    p)
        PATH_DIR=$OPTARG
        if [ -d $PATH_DIR ]
        then 
            DIR_EXIST=true
        else
            echo "Le répertoire n'existe pas" >&2
            exit 1
        fi
        if [ $opt_f == 'false' ] #comparaison de chaînes
        then
        #afficher le résultat de l'exécution d'une commande ->$() : exécute la commande et retourne le résultat
            #echo -e -n "$(ls -1 $PATH_DIR | grep .txt | nl )\n" #ls -1 : affiche les noms des fic.txt seulement 
            #echo -e : echo ne met pas de retour à la ligne et echo -n interpréte les caractères spéciaux

            OLDIFS=$IFS #sauvegarde de la valeur de IFS, IFS = Internal Field Separator (variable interne)
            IFS=$'\n' #IFS est un caractère de séparation interne
            
            for file in $(ls -1 $PATH_DIR | grep .txt | nl );do
                filename=$(echo $file | tr -s " " '\t' | cut -f3) #découpe la chaîne en fonction du séparateur et retourne le champ n°3 soit le nom ex; 1 departements.txt -> renvoie departements.txt
                #tr supprime les espaces qui se suivent et les remplace par une tabulation
                #cut -f3 : retourne le champ n°3 et considère par défaut le séparateur \t
                listechamps=$(afficherChamps "$filename")
                echo -e -n "$file $listechamps\n"
            done

            IFS=$OLDIFS #restauration de la valeur de IFS
        fi
        ;;

    #indique le numéro de la colonne question
    q)
        NUMBER_COLUMNS_QUESTION=$OPTARG
        opt_q=true
        ;;
    
    #indique le numéro de la colonne réponse
    r)
        NUMBER_COLUMNS_ANSWER=$OPTARG
        opt_r=true
        ;;

    #affiche les meilleurs scores triés + pseudo + nb points
    s)
        ;;

    #mode verbeux : affiche les réponses à saisir
    v)
        ;;

    \?) #passe ici quand l'option n'est pas reconnue
    echo "L'option -$OPTARG est invalide" >&2
    exit 1
    ;;

    :) #passe ici quand il manque l'argument d'une option
    echo "L'option -$OPTARG attend un argument" >&2
    exit 1
    ;;
    esac
done

#est ce que le séparateur défini est bien présent dans le fichier de données ?
#head -1 : affiche la première ligne du fichier
#grep -q : ne pas afficher les résultats, si le résultat est trouvé retour 0
if head -1 $DATA_FILE | grep -v -q "$SEPARATOR" # $? : retourne le code de sortie de la dernière commande exécutée
#on veut ne pas trouver le séparateur
then
    echo "Le séparateur n'est pas présent dans le fichier" >&2
    exit 1
fi
#head -1 $DATA_FILE | grep -q $SEPARATOR  #grep -q : ne pas afficher les résultats, si le résultat est trouvé retour 0
# "" : interprétation de la var


