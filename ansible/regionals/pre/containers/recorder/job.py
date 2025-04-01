from kubernetes import client, config
import logging
import uuid


def create_k8s_job(namespace="pipeline", timestamp="", trial_id="", location=""):

    try:
        config.load_incluster_config()
    except config.ConfigException:
        logging.warning(
            "Unable to load in-cluster config, falling back to local kube config"
        )
        config.load_kube_config()

    # Generate a unique job name with UUID suffix
    unique_id = str(uuid.uuid4())[:8]  # Use first 8 chars of UUID for brevity
    job_name = f"data-processor-{unique_id}"

    # Define Job metadata with unique name
    job_metadata = client.V1ObjectMeta(name=job_name)

    # Define environment variables
    env_vars = [
        client.V1EnvVar(name="TIMESTAMP", value=timestamp),
        client.V1EnvVar(name="TRIAL_ID", value=trial_id),
        client.V1EnvVar(name="LOCATION", value=location),
    ]

    container = client.V1Container(
        name="worker",
        image="public.ecr.aws/abcdefg/placebo-pharma/processor:latest",
        env=env_vars,
    )

    template = client.V1PodTemplateSpec(
        metadata=client.V1ObjectMeta(labels={"app": "data-processor", "app.kubernetes.io/name": "processor"}),
        spec=client.V1PodSpec(restart_policy="Never", containers=[container]),
    )

    job_spec = client.V1JobSpec(
        template=template, backoff_limit=1, ttl_seconds_after_finished=180
    )

    job = client.V1Job(
        api_version="batch/v1", kind="Job", metadata=job_metadata, spec=job_spec
    )

    batch_v1 = client.BatchV1Api()
    batch_v1.create_namespaced_job(namespace=namespace, body=job)
