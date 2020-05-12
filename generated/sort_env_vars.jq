if ( .kind == "Deployment" or .kind == "StatefulSet" ) then
     .spec.template.spec.containers[] |= (.env = ( (.env // [])   | . |= sort_by( .name )))
else
   .
end