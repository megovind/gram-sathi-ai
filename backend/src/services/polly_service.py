import boto3
import uuid
from src.utils.config import config
from src.services.s3_service import s3


VOICE_MAP = {
    "hi": "Kajal",
    "en": "Aditi",
    "ta": "Kajal",
    "te": "Kajal",
    "mr": "Kajal",
    "kn": "Kajal",
    "bn": "Kajal",
    "gu": "Kajal",
}

ENGINE_MAP = {
    "Kajal": "neural",
    "Aditi": "standard",
}

POLLY_LANG_MAP = {
    "hi": "hi-IN",
    "en": "en-IN",
    "ta": "ta-IN",
    "te": "te-IN",
    "mr": "hi-IN",
    "kn": "hi-IN",
    "bn": "hi-IN",
    "gu": "hi-IN",
}

# Low-bandwidth: OGG_VORBIS ~40% smaller than MP3, 8kHz optimised for voice (US-22)
LOW_BW_FORMAT = "ogg_vorbis"
LOW_BW_CONTENT_TYPE = "audio/ogg"
LOW_BW_SAMPLE_RATE = "8000"

NORMAL_FORMAT = "mp3"
NORMAL_CONTENT_TYPE = "audio/mpeg"
NORMAL_SAMPLE_RATE = "22050"


class PollyService:
    def __init__(self):
        self._client = boto3.client("polly", region_name=config.AWS_REGION)

    def synthesize(self, text: str, language_code: str = "hi", low_bandwidth: bool = False) -> str:
        """
        Convert text to speech using Amazon Polly.
        low_bandwidth=True uses OGG/8kHz (~70% smaller) for slow connections (US-22).
        Returns a presigned S3 download URL.
        """
        voice_id = VOICE_MAP.get(language_code, "Kajal")
        engine = ENGINE_MAP.get(voice_id, "neural")

        if low_bandwidth:
            output_format = LOW_BW_FORMAT
            sample_rate = LOW_BW_SAMPLE_RATE
            content_type = LOW_BW_CONTENT_TYPE
            ext = "ogg"
        else:
            output_format = NORMAL_FORMAT
            sample_rate = NORMAL_SAMPLE_RATE
            content_type = NORMAL_CONTENT_TYPE
            ext = "mp3"

        response = self._client.synthesize_speech(
            Text=text,
            OutputFormat=output_format,
            SampleRate=sample_rate,
            VoiceId=voice_id,
            Engine=engine,
            LanguageCode=POLLY_LANG_MAP.get(language_code, "hi-IN"),
        )

        audio_bytes: bytes = response["AudioStream"].read()
        object_key = f"responses/{uuid.uuid4().hex}.{ext}"
        s3.put_object(object_key, audio_bytes, content_type=content_type)

        return s3.generate_presigned_download_url(object_key)


polly = PollyService()
