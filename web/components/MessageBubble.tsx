import { Bot } from 'lucide-react'
import { AudioPlayer } from './AudioPlayer'
import { FacilityCard } from './FacilityCard'
import { FormattedMessage } from './FormattedMessage'
import type { Facility, Message, NearbyKind } from '@/lib/types'
import { cn } from '@/lib/utils'

interface Props {
  message: Message
}

export function MessageBubble({ message }: Props) {
  const isUser = message.role === 'user'
  const hasFacilities = (message.facilities?.length ?? 0) > 0
  const kind = (message.nearbyKind ?? '') as NearbyKind

  if (isUser) {
    const showTranscript = !message.isUploading && !!message.content

    return (
      <div className="flex justify-end">
        <div className="max-w-[80%] rounded-2xl rounded-br-sm bg-userBubble px-4 py-2.5 text-white shadow-sm">
          {message.isUploading ? (
            <p className="flex items-center gap-2 text-sm opacity-80">
              <span className="inline-block h-4 w-4 animate-spin rounded-full border-2 border-white/40 border-t-white" />
              Processing voice...
            </p>
          ) : message.isVoice && !showTranscript ? (
            <p className="flex items-center gap-1.5 text-sm opacity-90">
              <span>🎤</span>
              Voice message
            </p>
          ) : (
            <FormattedMessage text={message.content} isUser />
          )}
          <p className="mt-1 text-right text-[10px] text-white/60">
            {message.timestamp.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
          </p>
        </div>
      </div>
    )
  }

  return (
    <div className="flex flex-col gap-2">
      {/* Bubble row */}
      <div className="flex items-end gap-2">
        {/* Avatar */}
        <div className="flex h-7 w-7 flex-shrink-0 items-center justify-center rounded-full bg-gradient-to-br from-primary to-primary-light text-white shadow-sm">
          <Bot className="h-4 w-4" />
        </div>

        <div
          className={cn(
            'max-w-[80%] rounded-2xl rounded-bl-sm bg-assistantBubble px-4 py-2.5 shadow-sm',
            'text-textPrimary',
          )}
        >
          {/* Health advice text — shown only when present (health_advice or health_and_nearby) */}
          {message.content && <FormattedMessage text={message.content} />}

          {/* Count line — always shown when facilities are present */}
          {hasFacilities && (
            <div className={message.content ? 'mt-3' : undefined}>
              <NearbyIntroLine count={message.facilities!.length} kind={kind} />
            </div>
          )}

          {message.audioUrl && (
            <div className="mt-2">
              <AudioPlayer src={message.audioUrl} autoPlay tint="light" />
            </div>
          )}

          <p className="mt-1 text-[10px] text-textHint">
            {message.timestamp.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
          </p>
        </div>
      </div>

      {/* Facility cards below the bubble */}
      {hasFacilities && (
        <div className="ml-9 flex flex-col gap-2">
          {message.facilities!.map((f, i) => (
            <FacilityCard key={i} facility={f as Facility} kind={kind} />
          ))}
        </div>
      )}
    </div>
  )
}

function NearbyIntroLine({ count, kind }: { count: number; kind: NearbyKind }) {
  const label =
    kind === 'clinic'    ? `${count} clinic(s) found` :
    kind === 'pharmacy'  ? `${count} pharmacy(ies) found` :
    kind === 'hospital'  ? `${count} hospital(s) found` :
    kind === 'shops'     ? `${count} shop(s) found` :
                           `${count} place(s) found`

  return (
    <p className="flex items-center gap-1.5 text-sm font-medium text-textPrimary">
      <span>📍</span>
      {label} nearby
    </p>
  )
}

export function TypingIndicator() {
  return (
    <div className="flex items-end gap-2">
      <div className="flex h-7 w-7 flex-shrink-0 items-center justify-center rounded-full bg-gradient-to-br from-primary to-primary-light text-white shadow-sm">
        <Bot className="h-4 w-4" />
      </div>
      <div className="rounded-2xl rounded-bl-sm bg-assistantBubble px-4 py-3 shadow-sm">
        <div className="flex items-center gap-1.5">
          {[0, 1, 2].map(i => (
            <span
              key={i}
              className="h-2 w-2 rounded-full bg-primary/40 animate-bounce"
              style={{ animationDelay: `${i * 0.15}s` }}
            />
          ))}
          <span className="ml-1 text-xs text-textSecondary">Thinking...</span>
        </div>
      </div>
    </div>
  )
}
