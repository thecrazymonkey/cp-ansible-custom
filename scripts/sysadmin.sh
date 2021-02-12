#/bin/bash

# run as mds
BROKER=kafka1.ivan.ps.confluent.io
MDS_PORT=8090
SYSADMIN_USER=superUser

KAFKA_ID=$(confluent cluster describe --url https://$BROKER:$MDS_PORT -o json | jq -r .crn)
if [ "$KAFKA_ID" == "" ]
then
   echo "Can't get KAFKA_ID"
   exit 1
fi
echo "Provisioning cluster" $KAFKA_ID

SR_GROUP_ID=schema-registry
CONNECT_CLUSTER=connect-cluster
KSQL_CLUSTER=default_

# Rolebinding for SystemAdmin role for the Kafka cluster
confluent iam rolebinding create --principal User:$SYSADMIN_USER \
--role SystemAdmin --kafka-cluster-id $KAFKA_ID

echo "Provisioning cluster" $SR_GROUP_ID
# Rolebinding for SystemAdmin role for the Schema Registry cluster
confluent iam rolebinding create --principal User:$SYSADMIN_USER \
--role SystemAdmin --kafka-cluster-id $KAFKA_ID \
--schema-registry-cluster-id $SR_GROUP_ID

echo "Provisioning cluster" $CONNECT_CLUSTER
# Rolebinding for SystemAdmin role for the Schema Registry cluster
# Rolebinding for SystemAdmin role for the Connect Cluster
confluent iam rolebinding create --principal User:$SYSADMIN_USER \
--role SystemAdmin --kafka-cluster-id $KAFKA_ID \
--connect-cluster-id $CONNECT_CLUSTER

echo "Provisioning cluster" $KSQL_CLUSTER
# Rolebinding for SystemAdmin role for the Schema Registry cluster
# Rolebinding for SystemAdmin role for the KSQL Cluster
confluent iam rolebinding create --kafka-cluster-id $KAFKA_ID \
--principal User:$SYSADMIN_USER \
--role SystemAdmin \
--ksql-cluster-id $KSQL_CLUSTER


