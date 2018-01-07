#!/bin/bash
set +ex
. common.env
cd containers
./build.sh test/base
docker tag $CONTRAIL_REGISTRY/contrail-test-base:$CONTRAIL_VERSION-centos7-$OPENSTACK_VERSION $CONTRAIL_REGISTRY/contrail-test-base:latest 
./build.sh test/ocata
docker tag $CONTRAIL_REGISTRY/contrail-test-ocata:$CONTRAIL_VERSION-centos7-$OPENSTACK_VERSION $CONTRAIL_REGISTRY/contrail-test-ocata:latest 
./build.sh test/test
docker tag $CONTRAIL_REGISTRY/contrail-test-test:$CONTRAIL_VERSION-centos7-$OPENSTACK_VERSION $CONTRAIL_REGISTRY/contrail-test:static-$OPENSTACK_VERSION
#docker push $CONTRAIL_REGISTRY/contrail-test:static-$OPENSTACK_VERSION
