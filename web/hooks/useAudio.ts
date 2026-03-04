'use client'

import { useCallback, useRef, useState } from 'react'

export type RecordingState = 'idle' | 'requesting' | 'recording' | 'processing'

function getBestMimeType(): string {
  const candidates = [
    'audio/webm;codecs=opus',
    'audio/webm',
    'audio/ogg;codecs=opus',
    'audio/mp4',
  ]
  if (typeof MediaRecorder === 'undefined') return ''
  return candidates.find(t => MediaRecorder.isTypeSupported(t)) ?? ''
}

function mimeToExt(mime: string): string {
  if (mime.includes('webm')) return 'webm'
  if (mime.includes('ogg'))  return 'ogg'
  if (mime.includes('mp4'))  return 'mp4'
  return 'webm'
}

export interface AudioResult {
  blob: Blob
  mimeType: string
  extension: string
}

export function useAudio() {
  const [state, setState] = useState<RecordingState>('idle')
  const [error, setError] = useState<string | null>(null)
  const mediaRecorderRef = useRef<MediaRecorder | null>(null)
  const chunksRef        = useRef<Blob[]>([])
  const streamRef        = useRef<MediaStream | null>(null)

  const startRecording = useCallback(async () => {
    setError(null)
    setState('requesting')
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true })
      streamRef.current = stream

      const mimeType = getBestMimeType()
      const recorder  = new MediaRecorder(stream, mimeType ? { mimeType } : undefined)
      mediaRecorderRef.current = recorder
      chunksRef.current = []

      recorder.ondataavailable = (e: BlobEvent) => {
        if (e.data.size > 0) chunksRef.current.push(e.data)
      }

      recorder.start(100)
      setState('recording')
    } catch (err) {
      setState('idle')
      setError(
        err instanceof DOMException && err.name === 'NotAllowedError'
          ? 'Microphone permission denied. Please allow microphone access in your browser.'
          : 'Could not start recording. Please check your microphone.',
      )
    }
  }, [])

  const stopRecording = useCallback((): Promise<AudioResult | null> => {
    return new Promise(resolve => {
      const recorder = mediaRecorderRef.current
      if (!recorder || recorder.state === 'inactive') {
        resolve(null)
        return
      }

      setState('processing')
      const mimeType = recorder.mimeType || 'audio/webm'

      recorder.onstop = () => {
        const blob = new Blob(chunksRef.current, { type: mimeType })
        streamRef.current?.getTracks().forEach(t => t.stop())
        streamRef.current = null
        mediaRecorderRef.current = null
        setState('idle')
        resolve({ blob, mimeType, extension: mimeToExt(mimeType) })
      }

      recorder.stop()
    })
  }, [])

  const cancelRecording = useCallback(() => {
    const recorder = mediaRecorderRef.current
    if (recorder && recorder.state !== 'inactive') {
      recorder.ondataavailable = null
      recorder.onstop = null
      recorder.stop()
    }
    streamRef.current?.getTracks().forEach(t => t.stop())
    streamRef.current = null
    mediaRecorderRef.current = null
    chunksRef.current = []
    setState('idle')
  }, [])

  return { state, error, startRecording, stopRecording, cancelRecording }
}
