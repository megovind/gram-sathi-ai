import boto3
import time
import uuid
from src.utils.config import config


# Transcribe language code mapping from app language codes
LANGUAGE_MAP = {
    "hi": "hi-IN",
    "en": "en-IN",
    "mr": "mr-IN",
    "ta": "ta-IN",
    "te": "te-IN",
    "kn": "kn-IN",
    "bn": "bn-IN",
    "gu": "gu-IN",
}


class TranscribeService:
    def __init__(self):
        self._client = boto3.client("transcribe", region_name=config.AWS_REGION)

    def transcribe_audio(self, audio_s3_key: str, language_code: str = "hi") -> str:
        """
        Start a transcription job and poll until complete.
        Returns the transcribed text.

        For production, trigger via S3 event + async flow.
        This synchronous version is suitable for short voice clips (<30s).
        """
        job_name = f"gramsathi-{uuid.uuid4().hex}"
        audio_uri = f"s3://{config.S3_AUDIO_BUCKET}/{audio_s3_key}"
        aws_lang = LANGUAGE_MAP.get(language_code, "hi-IN")

        self._client.start_transcription_job(
            TranscriptionJobName=job_name,
            Media={"MediaFileUri": audio_uri},
            MediaFormat=self._detect_format(audio_s3_key),
            LanguageCode=aws_lang,
        )

        return self._poll_job(job_name)

    def _poll_job(self, job_name: str, max_wait_seconds: int = 60) -> str:
        waited = 0
        interval = 3
        while waited < max_wait_seconds:
            response = self._client.get_transcription_job(TranscriptionJobName=job_name)
            status = response["TranscriptionJob"]["TranscriptionJobStatus"]

            if status == "COMPLETED":
                import urllib.request
                transcript_uri = response["TranscriptionJob"]["Transcript"]["TranscriptFileUri"]
                with urllib.request.urlopen(transcript_uri) as f:
                    import json
                    data = json.load(f)
                    return data["results"]["transcripts"][0]["transcript"]

            if status == "FAILED":
                raise RuntimeError(
                    f"Transcription failed: {response['TranscriptionJob'].get('FailureReason', 'unknown')}"
                )

            time.sleep(interval)
            waited += interval

        raise TimeoutError(f"Transcription job {job_name} did not complete in {max_wait_seconds}s")

    def _detect_format(self, s3_key: str) -> str:
        ext = s3_key.rsplit(".", 1)[-1].lower()
        format_map = {
            "mp3": "mp3",
            "mp4": "mp4",
            "wav": "wav",
            "flac": "flac",
            "ogg": "ogg",
            "webm": "webm",
            "amr": "amr",
            "m4a": "mp4",
        }
        return format_map.get(ext, "mp3")


transcribe = TranscribeService()
