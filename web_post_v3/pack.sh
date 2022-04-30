#/bin/sh
zip -r template_post_v3.zip build
sign=$(md5 -q template_post_v3.zip)
cp template_post_v3.zip template.$sign.zip
