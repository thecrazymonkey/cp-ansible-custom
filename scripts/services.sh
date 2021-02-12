#/bin/bash

# run as SYSADMIN_USER
export NAMESPACE=operator
export BROKER=bootstrap.minikube.lan

# service users
export SR_USER=schemaregistryUser
export CONNECT_USER=connectAdmin
export KSQL_USER=ksqlDBAdmin
export C3_USER=controlcenterAdmin
export REPLICATOR_USER=replicationAdmin


# clusters
export KAFKA_ID=$(confluent cluster describe --url https://$BROKER -o json | jq -r .crn)
export SR_GROUP_ID=id_schemaregistry_$NAMESPACE
export CONNECT_CLUSTER=${NAMESPACE}.connectors
export KSQL_CLUSTER=${NAMESPACE}.ksql_
export REPLICATOR_CLUSTER=${NAMESPACE}.replicator

# schema registry service user
confluent iam rolebinding create --principal User:$SR_USER \
--role SecurityAdmin --kafka-cluster-id $KAFKA_ID \
--schema-registry-cluster-id $SR_GROUP_ID

confluent iam rolebinding create --principal User:$SR_USER \
--role ResourceOwner --kafka-cluster-id $KAFKA_ID \
--resource Group:$SR_GROUP_ID

confluent iam rolebinding create --principal User:$SR_USER \
--role ResourceOwner --kafka-cluster-id $KAFKA_ID \
--resource Topic:_schemas

# connect cluster service user
confluent iam rolebinding create --principal User:$CONNECT_USER \
--role SecurityAdmin --kafka-cluster-id $KAFKA_ID \
--connect-cluster-id $CONNECT_CLUSTER

confluent iam rolebinding create --principal User:$CONNECT_USER \
--role ResourceOwner --resource Group:$CONNECT_CLUSTER \
--kafka-cluster-id $KAFKA_ID

confluent iam rolebinding create --principal User:$CONNECT_USER \
--role ResourceOwner --resource Topic:connect-configs \
--kafka-cluster-id $KAFKA_ID

confluent iam rolebinding create --principal User:$CONNECT_USER \
--role ResourceOwner --resource Topic:connect-offsets \
--kafka-cluster-id $KAFKA_ID

confluent iam rolebinding create --principal User:$CONNECT_USER \
--role ResourceOwner --resource Topic:connect-status \
--kafka-cluster-id $KAFKA_ID


# KSQLDB cluster service user

confluent iam rolebinding create \
--kafka-cluster-id $KAFKA_ID \
--principal User:$KSQL_USER \
--role ResourceOwner \
--ksql-cluster-id $KSQL_CLUSTER \
--resource KsqlCluster:ksql-cluster

confluent iam rolebinding create \
--kafka-cluster-id $KAFKA_ID \
--principal User:$KSQL_USER \
--role ResourceOwner \
--resource Topic:_confluent-ksql-$KSQL_CLUSTER \
--prefix


# C3 service user
confluent iam rolebinding create \
--principal User:$C3_USER \
--role SystemAdmin \
--kafka-cluster-id $KAFKA_ID

# replicator service user
confluent iam rolebinding create \
  --kafka-cluster-id $KAFKA_ID \
  --principal User:$REPLICATOR_USER \
  --role ResourceOwner \
  --resource Group:$REPLICATOR_CLUSTER

confluent iam rolebinding create \
  --kafka-cluster-id $KAFKA_ID \
  --principal User:$REPLICATOR_USER \
  --role DeveloperWrite \
  --resource Topic:_confluent-monitoring \
  --prefix

confluent iam rolebinding create \
  --kafka-cluster-id $KAFKA_ID \
  --principal User:$REPLICATOR_USER \
  --role ResourceOwner \
  --resource Topic:$REPLICATOR_CLUSTER- \
  --prefix
