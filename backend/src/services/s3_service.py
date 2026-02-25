import boto3
from botocore.config import Config as BotoConfig
from src.utils.config import config


class S3Service:
    def __init__(self):
        self._client = boto3.client(
            "s3",
            region_name=config.AWS_REGION,
            config=BotoConfig(signature_version="s3v4"),
        )

    def generate_presigned_upload_url(self, object_key: str, content_type: str = "audio/webm") -> str:
        """Generate a presigned PUT URL so the Flutter app can upload audio directly to S3."""
        url = self._client.generate_presigned_url(
            "put_object",
            Params={
                "Bucket": config.S3_AUDIO_BUCKET,
                "Key": object_key,
                "ContentType": content_type,
            },
            ExpiresIn=config.AUDIO_EXPIRY_SECONDS,
        )
        return url

    def generate_presigned_download_url(self, object_key: str) -> str:
        """Generate a presigned GET URL to stream audio response back to client."""
        url = self._client.generate_presigned_url(
            "get_object",
            Params={"Bucket": config.S3_AUDIO_BUCKET, "Key": object_key},
            ExpiresIn=config.AUDIO_EXPIRY_SECONDS,
        )
        return url

    def put_object(self, object_key: str, body: bytes, content_type: str = "audio/mpeg") -> None:
        self._client.put_object(
            Bucket=config.S3_AUDIO_BUCKET,
            Key=object_key,
            Body=body,
            ContentType=content_type,
        )

    def get_object(self, object_key: str) -> bytes:
        response = self._client.get_object(Bucket=config.S3_AUDIO_BUCKET, Key=object_key)
        return response["Body"].read()


s3 = S3Service()
