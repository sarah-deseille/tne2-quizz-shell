#!/usr/bin/bash
source quizz.lib
SEPARATOR=":" #séparateur par défaut
PATH_DIR="." #répertoire par défaut
FILE_EXIST=false #fichier par défaut inexistant
DIR_EXIST=false #répertoire par défaut inexistant
opt_f=false #option -f non utilisée
opt_r=false #option -r non utilisée
opt_q=false #option -q non utilisée
opt_v=false #option -v non utilisée

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
            exit 0 #sortie du script
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
        opt_v=true
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

#nombre de champs du fichier
MAXCHAMPS=$(nbChamps "$PATH_DIR/$DATA_FILE" $SEPARATOR)

#vérifier que les options -q et -r sont utilisées
if [ $opt_q == 'false' ] && [ $opt_r == 'false' ] 
then
    NUMBER_COLUMNS_QUESTION=$(alea 1 $MAXCHAMPS) #considère que le min sera 1

    #init condition - forcer rentrer dans la boucle while
    NUMBER_COLUMNS_ANSWER=$NUMBER_COLUMNS_QUESTION

    #trouver NUMBER_COLUMNS_ANSWER différent de NUMBER_COLUMNS_QUESTION
    while [ $NUMBER_COLUMNS_ANSWER -eq $NUMBER_COLUMNS_QUESTION ]
    do
        NUMBER_COLUMNS_ANSWER=$(alea 1 $MAXCHAMPS)
    done
    echo "Question : $NUMBER_COLUMNS_QUESTION Réponse : $NUMBER_COLUMNS_ANSWER"

elif [ $opt_q == 'false' ] && [ $opt_r == 'true' ] #cas où la question n'est pas définie et la réponse définie
then
    VAL_REPONSE=$NUMBER_COLUMNS_ANSWER #récup la valeur du champs réponse entrée par l'utilisateur
    #vérifier que VAL_REPONSE <= MAXCHAMPS
    if [ $VAL_REPONSE -gt $MAXCHAMPS ]
    then
        echo "Le numéro de la colonne réponse est supérieur au nombre de colonnes du fichier" >&2
        exit 1
    fi
    NUMBER_COLUMNS_QUESTION=$NUMBER_COLUMNS_ANSWER
    while [ $NUMBER_COLUMNS_QUESTION -eq $VAL_REPONSE ]
    do
        NUMBER_COLUMNS_QUESTION=$(alea 1 $MAXCHAMPS)
    done
    echo "Question : $NUMBER_COLUMNS_QUESTION Réponse : $NUMBER_COLUMNS_ANSWER"

elif [ $opt_q == 'true' ] && [ $opt_r == 'false' ] #cas où la question est définie et la réponse non définie
then
    VAL_QUESTION=$NUMBER_COLUMNS_QUESTION #récup la valeur du champs question entrée par l'utilisateur
    #vérifier que VAL_QUESTION<= MAXCHAMPS
    if [ $VAL_QUESTION -gt $MAXCHAMPS ]
    then
        echo "Le numéro de la colonne question est supérieur au nombre de colonnes du fichier" >&2
        exit 1
    fi
    NUMBER_COLUMNS_ANSWER=$NUMBER_COLUMNS_QUESTION
    while [ $NUMBER_COLUMNS_ANSWER -eq $VAL_QUESTION ]
    do
        NUMBER_COLUMNS_ANSWER=$(alea 1 $MAXCHAMPS)
    done
    echo "Question : $NUMBER_COLUMNS_QUESTION Réponse : $NUMBER_COLUMNS_ANSWER"

fi

#jeu de quizz
while true
do 
    #afficher le mode verbeux
    if [ $opt_v == 'true' ]
    then
        echo "Question : $(afficherChamps $DATA_FILE $SEPARATOR $NUMBER_COLUMNS_QUESTION)"
    fi

    #afficher la question
    selectLignes "$PATH_DIR/$DATA_FILE" 
    echo "Question : $(afficherChamps $DATA_FILE $SEPARATOR $NUMBER_COLUMNS_QUESTION)"
    #saisir la réponse
    read -p "Votre réponse : " REPONSE
    #afficher la réponse
    echo "Réponse : $(afficherChamps $DATA_FILE $SEPARATOR $NUMBER_COLUMNS_ANSWER)"
    #vérifier la réponse
    if [ $REPONSE == $(afficherChamps $DATA_FILE $SEPARATOR $NUMBER_COLUMNS_ANSWER) ]
    then
        echo "Bonne réponse"
    else
        echo "Mauvaise réponse"
    fi
    #continuer ou arrêter
    read -p "Continuer (o/n) ? " CONTINUER
    if [ $CONTINUER == 'n' ]
    then
        break
    fi
done


