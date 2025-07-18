#!/usr/bin/env bash
# Exit on error
set -o errexit

# Update pip
pip3 install --upgrade pip

# Install dependencies
pip3 install -r requirements.txt

# Install Djongo and Pymongo if not in requirements
#pip3 install --upgrade djongo #pymongo
#python -m pip install "pymongo[gssapi,aws,ocsp,snappy,zstd,encryption]"

# Convert static asset files
#rm -rf staticfiles/
#python manage.py collectstatic --no-input

# Apply any outstanding database migrations
python manage.py makemigrations
python manage.py migrate --noinput

# Create superuser if CREATE_SUPERUSER is set
if [[ $CREATE_SUPERUSER == "true" ]]; then
    echo "Creando/overriding superusuario via script…"
    python manage.py shell <<EOF
from django.contrib.auth import get_user_model
U = get_user_model()
U.objects.update_or_create(
    username='$DJANGO_SUPERUSER_USERNAME',
    defaults={
        'email': '$DJANGO_SUPERUSER_EMAIL',
        'is_staff': True,
        'is_superuser': True
    }
)
u = U.objects.get(username='$DJANGO_SUPERUSER_USERNAME')
u.set_password('$DJANGO_SUPERUSER_PASSWORD')
u.save()
print("– Superusuario listo: $DJANGO_SUPERUSER_USERNAME / [PASSWORD SET]")
EOF
fi


echo "Tareas de construcción completadas."