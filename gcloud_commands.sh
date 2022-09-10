# enable the required cloud services
gcloud services enable \
cloudbuild.googleapis.com \
container.googleapis.com \
cloudresourcemanager.googleapis.com \
iam.googleapis.com \
containerregistry.googleapis.com \
containeranalysis.googleapis.com \
ml.googleapis.com \
dataflow.googleapis.com

# Editor permission for Cloud Build service account
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
CLOUD_BUILD_SERVICE_ACCOUNT="${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member serviceAccount:$CLOUD_BUILD_SERVICE_ACCOUNT \
  --role roles/editor

#custom service account to give CAIP training job access to AI Platform Vizier service for pipeline hyperparameter tuning
SERVICE_ACCOUNT_ID=tfx-tuner-caip-service-account
gcloud iam service-accounts create $SERVICE_ACCOUNT_ID  \
  --description="A custom service account for CAIP training job to access AI Platform Vizier service for pipeline hyperparameter tuning." \
  --display-name="TFX Tuner CAIP Vizier"

#AI Platform service account additional access permissions to the AI Platform Vizier service for pipeline hyperparameter tuning
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
CAIP_SERVICE_ACCOUNT="service-${PROJECT_NUMBER}@cloud-ml.google.com.iam.gserviceaccount.com"
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member serviceAccount:$CAIP_SERVICE_ACCOUNT \
  --role=roles/storage.objectAdmin

gcloud projects add-iam-policy-binding $PROJECT_ID \
 --member serviceAccount:$CAIP_SERVICE_ACCOUNT \
 --role=roles/ml.admin

# Grant service account access to Storage admin role
SERVICE_ACCOUNT_ID=tfx-tuner-caip-service-account
gcloud projects add-iam-policy-binding $PROJECT_ID \
--member=serviceAccount:${SERVICE_ACCOUNT_ID}@${PROJECT_ID}.iam.gserviceaccount.com \
--role=roles/storage.objectAdmin

# Grant service acount access to AI Platform Vizier role
gcloud projects add-iam-policy-binding $PROJECT_ID \
--member=serviceAccount:${SERVICE_ACCOUNT_ID}@${PROJECT_ID}.iam.gserviceaccount.com \
--role=roles/ml.admin

# Grant your project's AI Platform Google-managed service account the Service Account Admin role for your AI Platform service account
gcloud iam service-accounts add-iam-policy-binding \
 --role=roles/iam.serviceAccountAdmin \
 --member=serviceAccount:service-${PROJECT_NUMBER}@cloud-ml.google.com.iam.gserviceaccount.com \
${SERVICE_ACCOUNT_ID}@${PROJECT_ID}.iam.gserviceaccount.com



