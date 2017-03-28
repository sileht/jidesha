#!/bin/bash
set -e

source creds

#space-separated list of domains
DOMAINS="jitsi.tetaneutral.net"

# The ID of the extension. This is to be chosen for the particular deployment and
# is used to allow applications (e.g. jitsi-meet) to detect whether the 
# extension they need is installed. The same ID should not be used for different
# deployments.
# See https://developer.mozilla.org/en-US/Add-ons/Install_Manifests for requirements
# for the format.
EXT_ID="jitsi@tetaneutral.net"

CONTENT_ROOT=`echo $EXT_ID | tr @ .`

if [ -z "$DOMAINS" -o -z "$EXT_ID" ]; then
    echo "Domains or extension ID not defined."
    exit 1
fi

rm -rf target
rm -f jidesha.xpi screen-sharing-jitsi-tetaneutral.rdf

mkdir -p target/content
for domain in $DOMAINS ;do
    cp empty.png target/content/$domain.png
done
sed -e "s/JIDESHA_DOMAINS/$DOMAINS/" bootstrap.js > target/bootstrap.js
sed -e "s/JIDESHA_EXT_ID/$EXT_ID/" install.rdf > target/install.rdf
sed -e "s/CONTENT_ROOT/$CONTENT_ROOT/" chrome.manifest > target/chrome.manifest

(cd target ; zip -r ../jidesha.xpi *)

./node_modules/.bin/jpm sign --api-key ${AMO_API_KEY} --api-secret ${AMO_API_SECRET} --xpi jidesha.xpi

rm -f jidesha.xpi
mv -f jidesha_for_jitsitetaneutralnet-*-fx.xpi screen-sharing-jitsi-tetaneutral.xpi
cp target/install.rdf screen-sharing-jitsi-tetaneutral.rdf
