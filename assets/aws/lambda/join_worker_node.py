import boto3
import os

s3 = boto3.client("s3")
ec2 = boto3.client("ec2")
ssm = boto3.client("ssm")

# Constants
BUCKET = os.environ.get("S3_BUCKET", "k8s-bootstrap-artifacts")
KEY = os.environ.get("S3_KEY", "join-command.txt")

def lambda_handler(event, context):
    print("Event received:", event)

    # Step 1: Read join command from S3
    try:
        response = s3.get_object(Bucket=BUCKET, Key=KEY)
        join_command = response["Body"].read().decode("utf-8").strip()
        print("Join command:", join_command)
    except Exception as e:
        print("Error fetching join command:", e)
        raise

    # Step 2: Find all EC2 instances tagged with Role=worker-node
    try:
        instances = ec2.describe_instances(
            Filters=[
                {"Name": "tag:Role", "Values": ["worker-node"]},
                {"Name": "instance-state-name", "Values": ["running"]}
            ]
        )

        instance_ids = [
            i["InstanceId"]
            for r in instances["Reservations"]
            for i in r["Instances"]
        ]
    except Exception as e:
        print("Error describing instances:", e)
        raise

    if not instance_ids:
        print("No worker nodes found.")
        return

    print("Targeting instances:", instance_ids)

    # Step 3: Send SSM command to worker nodes
    try:
        ssm.send_command(
            InstanceIds=instance_ids,
            DocumentName="AWS-RunShellScript",
            Parameters={
                "commands": [
                    f"echo '{join_command}' > /tmp/join.sh",
                    "chmod +x /tmp/join.sh",
                    "sudo /tmp/join.sh"
                ]
            },
            Comment="Join K8s cluster",
            TimeoutSeconds=60
        )
        print("SSM command sent.")
    except Exception as e:
        print("Error sending SSM command:", e)
        raise
