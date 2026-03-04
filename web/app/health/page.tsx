'use client'

import { useCallback, useEffect, useRef, useState } from 'react'
import { useRouter } from 'next/navigation'
import { ArrowLeft, Send, AlertTriangle, FileText, LocateFixed, LocateOff } from 'lucide-react'
import { toast } from 'sonner'
import { MessageBubble, TypingIndicator } from '@/components/MessageBubble'
import { VoiceButton } from '@/components/VoiceButton'
import { useAudio } from '@/hooks/useAudio'
import { store } from '@/lib/store'
import { healthQuery, getAudioUploadUrl, uploadAudioToS3 } from '@/lib/api'
import { getStrings } from '@/lib/strings'
import type { Facility, Message, NearbyKind } from '@/lib/types'
import { cn } from '@/lib/utils'

let msgId = 0
const nextId = () => String(++msgId)

export default function HealthPage() {
  const router  = useRouter()
  const audio   = useAudio()
  const t = getStrings(store.getLanguage())
  const [messages, setMessages]   = useState<Message[]>([])
  const [input, setInput]         = useState('')
  const [loading, setLoading]     = useState(false)
  const [emergency, setEmergency] = useState(false)
  const [convId, setConvId]       = useState<string | undefined>()
  const [summaryLoading, setSummaryLoading] = useState(false)
  const [summary, setSummary] = useState<string | null>(null)
  const [userLocation, setUserLocation] = useState<{ lat: number; lon: number } | null>(null)
  const listRef = useRef<HTMLDivElement>(null)

  const scrollBottom = () =>
    listRef.current?.scrollTo({ top: listRef.current.scrollHeight, behavior: 'smooth' })

  useEffect(() => { scrollBottom() }, [messages, loading])

  // Request GPS — used for "nearby clinics" queries; falls back gracefully if denied
  useEffect(() => {
    if (typeof navigator === 'undefined' || !('geolocation' in navigator)) return
    navigator.geolocation.getCurrentPosition(
      pos => setUserLocation({ lat: pos.coords.latitude, lon: pos.coords.longitude }),
      () => { /* permission denied or unavailable — text search will be used as fallback */ },
      { enableHighAccuracy: false, timeout: 8000, maximumAge: 300_000 },
    )
  }, [])

  // Display audio error if permission denied
  useEffect(() => {
    if (audio.error) toast.error(audio.error)
  }, [audio.error])

  const sendMessage = useCallback(async (text: string, audioS3Key?: string) => {
    if (!text.trim() && !audioS3Key) return
    setLoading(true)

    const userMsg: Message = {
      id: nextId(), role: 'user', content: text,
      timestamp: new Date(), isVoice: !!audioS3Key,
      isUploading: !!audioS3Key && !text,
    }
    setMessages(prev => [...prev, userMsg])
    setInput('')

    try {
      const lang = store.getLanguage()
      const res  = await healthQuery({
        text: text || undefined,
        audioS3Key,
        language: lang,
        conversationId: convId,
        lowBandwidth: false,
        latitude:  userLocation?.lat,
        longitude: userLocation?.lon,
        // Pincode is used as a fallback location anchor when GPS is unavailable
        pincode: store.getPincode() ?? undefined,
      })

      if (res.conversationId) setConvId(res.conversationId)
      if (res.isEmergency)    setEmergency(true)

      // If the audio message had no text yet, update user bubble with transcription
      if (audioS3Key && res.userText) {
        setMessages(prev =>
          prev.map(m => m.id === userMsg.id ? { ...m, content: res.userText!, isUploading: false } : m)
        )
      }

      const facilities = (res.facilities ?? []) as unknown as Facility[]
      const nearbyKind = (res.nearbyKind ?? '') as NearbyKind

      const assistantMsg: Message = {
        id: nextId(), role: 'assistant', content: res.text,
        audioUrl: res.audioUrl, timestamp: new Date(),
        facilities, nearbyKind,
      }
      setMessages(prev => [...prev, assistantMsg])
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to get response')
      setMessages(prev => prev.filter(m => m.id !== userMsg.id))
    } finally {
      setLoading(false)
    }
  }, [convId, userLocation])

  const handleVoiceStop = useCallback(async () => {
    const result = await audio.stopRecording()
    if (!result) return

    try {
      const fileName   = `audio_${Date.now()}.${result.extension}`
      const { uploadUrl, s3Key } = await getAudioUploadUrl(fileName, result.mimeType)
      await uploadAudioToS3(uploadUrl, result.blob, result.mimeType)
      await sendMessage('', s3Key)
    } catch (err) {
      toast.error('Failed to upload audio. Please try again.')
      console.error(err)
    }
  }, [audio, sendMessage])

  const handleGetSummary = async () => {
    if (!convId) return
    setSummaryLoading(true)
    try {
      const lang = store.getLanguage()
      const res  = await healthQuery({
        text: 'Generate summary',
        language: lang,
        conversationId: convId,
        generateSummary: true,
      })
      setSummary(res.doctorSummary ?? res.text)
    } catch {
      toast.error('Could not generate summary')
    } finally {
      setSummaryLoading(false)
    }
  }

  const isEmpty = messages.length === 0

  return (
    <div className="flex h-dvh flex-col">
      {/* AppBar */}
      <div className="flex items-center gap-3 bg-primary px-4 py-3 text-white shadow-md md:px-8">
        <button onClick={() => router.push('/home')} className="rounded-full p-1 hover:bg-white/20">
          <ArrowLeft className="h-5 w-5" />
        </button>
        <div className="flex-1">
          <p className="font-semibold">{t.healthTitle}</p>
          <p className="text-xs text-white/70">{t.healthSubtitle}</p>
        </div>
        <div title={userLocation ? 'Location active — nearby searches use GPS' : 'Location off — grant permission for accurate nearby results'}>
          {userLocation
            ? <LocateFixed className="h-4 w-4 text-white/80" />
            : <LocateOff className="h-4 w-4 text-white/40" />
          }
        </div>
        {messages.length >= 4 && (
          <button
            onClick={handleGetSummary}
            disabled={summaryLoading}
            className="flex items-center gap-1 rounded-lg bg-white/20 px-2.5 py-1 text-xs font-medium hover:bg-white/30"
          >
            <FileText className="h-3.5 w-3.5" />
            {summaryLoading ? '...' : t.summary}
          </button>
        )}
      </div>

      {/* Emergency banner */}
      {emergency && (
        <div className="flex items-center gap-2 bg-emergency px-4 py-2 text-white">
          <AlertTriangle className="h-4 w-4 flex-shrink-0" />
          <p className="text-sm font-medium">{t.emergencyText}</p>
        </div>
      )}

      {/* Doctor summary modal */}
      {summary && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 px-5">
          <div className="w-full max-w-sm rounded-2xl bg-surface p-5 shadow-2xl">
            <h3 className="mb-3 font-bold text-textPrimary">{t.doctorSummaryTitle}</h3>
            <p className="whitespace-pre-wrap text-sm text-textSecondary">{summary}</p>
            <button
              onClick={() => setSummary(null)}
              className="mt-4 w-full rounded-xl bg-primary py-3 text-sm font-semibold text-white"
            >
              {t.doctorSummaryClose}
            </button>
          </div>
        </div>
      )}

      {/* Messages */}
      <div ref={listRef} className="flex-1 overflow-y-auto">
        <div className="mx-auto w-full max-w-3xl px-4 py-4 space-y-3">
          {isEmpty && (
            <EmptyState onSuggestion={t => sendMessage(t)} />
          )}
          {messages.map(m => <MessageBubble key={m.id} message={m} />)}
          {loading && <TypingIndicator />}
        </div>
      </div>

      {/* Input bar */}
      <div className="border-t border-divider bg-surface px-3 py-3 md:px-8">
        <div className="mx-auto flex w-full max-w-3xl items-end gap-2">
          <VoiceButton
            state={audio.state}
            onStart={audio.startRecording}
            onStop={handleVoiceStop}
            disabled={loading}
          />
          <div className="flex flex-1 items-end gap-2 rounded-2xl bg-surface-variant px-3 py-2">
            <textarea
              value={input}
              onChange={e => setInput(e.target.value)}
              onKeyDown={e => {
                if (e.key === 'Enter' && !e.shiftKey) {
                  e.preventDefault()
                  sendMessage(input)
                }
              }}
              placeholder={t.typeMessage}
              rows={1}
              maxLength={1000}
              className="flex-1 resize-none bg-transparent text-sm text-textPrimary placeholder:text-textHint outline-none max-h-24"
              style={{ scrollbarWidth: 'none' }}
            />
            <button
              onClick={() => sendMessage(input)}
              disabled={!input.trim() || loading}
              className={cn(
                'flex h-8 w-8 flex-shrink-0 items-center justify-center rounded-xl transition',
                input.trim() && !loading
                  ? 'bg-primary text-white'
                  : 'bg-primary/20 text-primary/40',
              )}
            >
              <Send className="h-4 w-4" />
            </button>
          </div>
        </div>

        {audio.state === 'recording' && (
          <p className="mt-2 text-center text-xs font-medium text-emergency animate-pulse">
            🔴 Recording… tap Stop when done
          </p>
        )}
      </div>
    </div>
  )
}

function EmptyState({ onSuggestion }: { onSuggestion: (t: string) => void }) {
  const t = getStrings(store.getLanguage())
  return (
    <div className="flex flex-col items-center py-8 text-center">
      <div className="mb-4 text-5xl">🏥</div>
      <h2 className="text-lg font-semibold text-textPrimary">{t.healthTitle}</h2>
      <p className="mt-1 max-w-[260px] text-sm text-textSecondary">{t.healthSubtitle}</p>
      <div className="mt-5 flex flex-wrap justify-center gap-2">
        {t.healthSuggestions.map(s => (
          <button
            key={s}
            onClick={() => onSuggestion(s)}
            className="rounded-full border border-primary/30 bg-primary/5 px-3 py-1.5 text-xs font-medium text-primary hover:bg-primary/10"
          >
            {s}
          </button>
        ))}
      </div>
    </div>
  )
}
