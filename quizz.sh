#!/usr/bin/bash
source quizz.lib
SEPARATOR=":" #séparateur par défaut
FILE_EXIST=false #fichier par défaut inexistant
DIR_EXIST=false #répertoire par défaut inexistant
opt_f=false #option -f non utilisée

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
            echo -e -n "$(ls -1 $PATH_DIR | grep .txt | nl )\n" #ls -1 : affiche les noms des fic.txt seulement 
            #echo -e : echo ne met pas de retour à la ligne et echo -n interpréte les caractères spéciaux
        fi
        ;;

    #indique le numéro de la colonne question
    q)
        NUMBER_COLUMNS_QUESTION=$OPTARG
        ;;
    
    #indique le numéro de la colonne réponse
    r)
        NUMBER_COLUMNS_ANSWER=$OPTARG
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