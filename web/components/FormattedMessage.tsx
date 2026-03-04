import { cn } from '@/lib/utils'

interface Props {
  text: string
  isUser?: boolean
}

interface Block {
  type: 'heading' | 'bullet' | 'numbered' | 'divider' | 'warning' | 'paragraph'
  text: string
  index?: number
}

function parseLine(line: string, idx: number): Block {
  const t = line.trim()
  if (!t) return { type: 'divider', text: '' }
  if (t === '---' || t === '***') return { type: 'divider', text: '' }
  if (/^#{1,2}\s/.test(t)) return { type: 'heading', text: t.replace(/^#{1,2}\s/, '') }
  if (/^(\*\*[^*]+\*\*):?\s*$/.test(t)) return { type: 'heading', text: t.replace(/\*\*/g, '') }
  if (/^[-•*→]\s/.test(t)) return { type: 'bullet', text: t.replace(/^[-•*→]\s/, '') }
  if (/^\d+[.)]\s/.test(t)) return { type: 'numbered', text: t.replace(/^\d+[.)]\s/, ''), index: idx }
  if (t.startsWith('⚠️') || /EMERGENCY/i.test(t)) return { type: 'warning', text: t.replace(/^⚠️\s*/, '') }
  return { type: 'paragraph', text: t }
}

function inlineFormat(text: string): React.ReactNode[] {
  const parts: React.ReactNode[] = []
  const re = /(\*\*(.+?)\*\*|\*(.+?)\*)/g
  let last = 0
  let match: RegExpExecArray | null
  let key = 0
  while ((match = re.exec(text)) !== null) {
    if (match.index > last) parts.push(text.slice(last, match.index))
    if (match[2]) parts.push(<strong key={key++}>{match[2]}</strong>)
    else if (match[3]) parts.push(<em key={key++}>{match[3]}</em>)
    last = match.index + match[0].length
  }
  if (last < text.length) parts.push(text.slice(last))
  return parts
}

export function FormattedMessage({ text, isUser = false }: Props) {
  if (isUser) {
    return <p className="text-sm leading-relaxed whitespace-pre-wrap">{text}</p>
  }

  const lines = text.split('\n')
  let numberedCount = 0

  return (
    <div className="space-y-1 text-sm leading-relaxed">
      {lines.map((line, i) => {
        const block = parseLine(line, ++numberedCount)

        if (block.type === 'divider')
          return <hr key={i} className="border-divider my-1" />

        if (block.type === 'heading')
          return (
            <p key={i} className="font-semibold text-textPrimary">
              {inlineFormat(block.text)}
            </p>
          )

        if (block.type === 'bullet')
          return (
            <div key={i} className="flex gap-2">
              <span className="mt-1.5 h-1.5 w-1.5 flex-shrink-0 rounded-full bg-primary" />
              <p>{inlineFormat(block.text)}</p>
            </div>
          )

        if (block.type === 'numbered')
          return (
            <div key={i} className="flex gap-2">
              <span className="flex-shrink-0 font-semibold text-primary">{block.index}.</span>
              <p>{inlineFormat(block.text)}</p>
            </div>
          )

        if (block.type === 'warning')
          return (
            <div
              key={i}
              className="flex gap-2 rounded-lg border border-warn/40 bg-warn/10 px-3 py-2"
            >
              <span>⚠️</span>
              <p className="font-medium text-warn">{inlineFormat(block.text)}</p>
            </div>
          )

        return <p key={i} className={cn(!line.trim() && 'h-2')}>{inlineFormat(block.text)}</p>
      })}
    </div>
  )
}
