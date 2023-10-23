#!/bin/bash

# Spécifiez le nom du job et le code Pig
JOB_NAME="pig_job"
PIG_SCRIPT="pig_page_rank.py"
BUCKET_NAME="thebuckett"

# Fichier pour enregistrer les temps d'exécution
TIMING_FILE="pig_execution_times.txt"

# Supprimez le fichier de temps d'exécution s'il existe
rm -f "$TIMING_FILE"

# Créez un cluster avec différents nombres de workers
for NUM_WORKERS in 2 4 6
do
    echo "Création du cluster avec $NUM_WORKERS workers..."
    gcloud dataproc clusters create "$JOB_NAME-cluster-$NUM_WORKERS" \
        --enable-component-gateway \
        --region europe-west1 \
        --zone europe-west1-c \
        --master-machine-type n1-standard-4 \
        --master-boot-disk-size 500 \
        --num-workers "$NUM_WORKERS" \
        --worker-machine-type n1-standard-4 \
        --worker-boot-disk-size 500 \
        --image-version 2.0-debian10 \
        --project pagerank-402507

    # Nettoyez le répertoire de sortie
    gsutil rm -rf gs://"$BUCKET_NAME"/out

    # Exécutez le job Pig
    echo "Exécution du job Pig sur un cluster avec $NUM_WORKERS workers..."
    START_TIME=$(date +%s)
    gcloud dataproc jobs submit pig --region europe-west1 --cluster "$JOB_NAME-cluster-$NUM_WORKERS" -f gs://"$BUCKET_NAME"/"$PIG_SCRIPT"
    END_TIME=$(date +%s)
    ELAPSED_TIME=$((END_TIME - START_TIME))

    # Enregistrez le temps d'exécution dans un fichier
    echo "$NUM_WORKERS,$ELAPSED_TIME" >> "$TIMING_FILE"

    # Supprimez le cluster
    echo "Suppression du cluster avec $NUM_WORKERS workers..."
    gcloud dataproc clusters delete "$JOB_NAME-cluster-$NUM_WORKERS" --region europe-west1
done
