#! /bin/sh

curl -X POST -H "content-type: application/json" \
     -d '
   {"lat": "34.14338",
    "lon": "-77.86569",
    "numberOfPeople": 3,
    "medicalNeeded": true,
    "victimName": "victim",
    "victimPhoneNumber": "111-111-111"
   }
' \
     localhost:8080/incidents
