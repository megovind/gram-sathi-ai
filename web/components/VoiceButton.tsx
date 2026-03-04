'use client'

import { Mic, Square, Loader2 } from 'lucide-react'
import type { RecordingState } from '@/hooks/useAudio'
import { cn } from '@/lib/utils'

interface Props {
  state: RecordingState
  onStart: () => void
  onStop:  () => void
  disabled?: boolean
}

export function VoiceButton({ state, onStart, onStop, disabled }: Props) {
  const isRecording  = state === 'recording'
  const isProcessing = state === 'processing' || state === 'requesting'

  const handleClick = () => {
    if (disabled || isProcessing) return
    isRecording ? onStop() : onStart()
  }

  return (
    <button
      onClick={handleClick}
      disabled={disabled || isProcessing}
      aria-label={isRecording ? 'Stop recording' : 'Start recording'}
      className={cn(
        'relative flex h-12 w-12 flex-shrink-0 items-center justify-center rounded-full transition-all duration-200',
        'focus:outline-none focus:ring-2 focus:ring-offset-2',
        isRecording
          ? 'bg-emergency text-white shadow-lg shadow-emergency/40 focus:ring-emergency animate-pulse'
          : 'bg-primary text-white shadow-md hover:bg-primary-dark focus:ring-primary',
        (disabled || isProcessing) && 'opacity-50 cursor-not-allowed',
      )}
    >
      {isProcessing ? (
        <Loader2 className="h-5 w-5 animate-spin" />
      ) : isRecording ? (
        <Square className="h-5 w-5 fill-white" />
      ) : (
        <Mic className="h-5 w-5" />
      )}
      {isRecording && (
        <span className="absolute -inset-1 rounded-full border-2 border-emergency opacity-60 animate-ping" />
      )}
    </button>
  )
}
