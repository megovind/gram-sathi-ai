'use client'

import { useEffect, useRef, useState } from 'react'
import { Pause, Play, Loader2 } from 'lucide-react'
import { cn } from '@/lib/utils'

interface AudioPlayerProps {
  src: string
  autoPlay?: boolean
  tint?: 'light' | 'dark'
}

export function AudioPlayer({ src, autoPlay = false, tint = 'light' }: AudioPlayerProps) {
  const audioRef              = useRef<HTMLAudioElement | null>(null)
  const [playing, setPlaying] = useState(false)
  const [loading, setLoading] = useState(true)
  const [progress, setProgress] = useState(0)

  useEffect(() => {
    const audio = new Audio(src)
    audioRef.current = audio

    audio.addEventListener('canplaythrough', () => setLoading(false))
    audio.addEventListener('play',    () => setPlaying(true))
    audio.addEventListener('pause',   () => setPlaying(false))
    audio.addEventListener('ended',   () => { setPlaying(false); setProgress(0) })
    audio.addEventListener('timeupdate', () => {
      if (audio.duration) setProgress(audio.currentTime / audio.duration)
    })

    if (autoPlay) audio.play().catch(() => {})

    return () => {
      audio.pause()
      audio.src = ''
    }
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [src])

  const toggle = () => {
    const a = audioRef.current
    if (!a) return
    playing ? a.pause() : a.play().catch(() => {})
  }

  const base = tint === 'dark'
    ? 'bg-white/20 text-white'
    : 'bg-primary/10 text-primary'

  return (
    <button
      onClick={toggle}
      className={cn(
        'flex items-center gap-2 rounded-full px-3 py-1.5 text-xs font-medium transition',
        base,
        'hover:opacity-80 active:scale-95',
      )}
    >
      {loading ? (
        <Loader2 className="h-4 w-4 animate-spin" />
      ) : playing ? (
        <Pause className="h-4 w-4" />
      ) : (
        <Play className="h-4 w-4" />
      )}
      <span>{playing ? 'Pause' : 'Play'}</span>
      {!loading && (
        <div className="relative h-1 w-16 overflow-hidden rounded-full bg-current/20">
          <div
            className="absolute inset-y-0 left-0 rounded-full bg-current"
            style={{ width: `${progress * 100}%` }}
          />
        </div>
      )}
    </button>
  )
}
