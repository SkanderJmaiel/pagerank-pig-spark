BUCKET_NAME="thebuckett"
gsutil cp gs://public_lddm_data/page_links_en.nt.bz2 gs://"$BUCKET_NAME"/
gsutil cp pig_page_rank.py gs://"$BUCKET_NAME"/
gsutil cp spark_page_rank.py gs://"$BUCKET_NAME"/