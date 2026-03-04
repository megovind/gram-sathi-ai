import type { Config } from 'tailwindcss'

const config: Config = {
  content: [
    './pages/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    './app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: '#1B6CA8',
          light:   '#4A90D9',
          dark:    '#0D4F80',
        },
        secondary: {
          DEFAULT: '#2ECC71',
          light:   '#58D68D',
        },
        accent: '#FF8C00',
        background: '#F5F7FA',
        surface: {
          DEFAULT: '#FFFFFF',
          variant: '#EEF2F7',
        },
        textPrimary:   '#1A1A2E',
        textSecondary: '#6B7280',
        textHint:      '#B0B8C4',
        divider:       '#E2E8F0',
        userBubble:    '#1B6CA8',
        assistantBubble: '#EEF2F7',
        emergency: '#E53E3E',
        warn:      '#ED8936',
        success:   '#38A169',
      },
      fontFamily: {
        sans: ['Noto Sans', 'Noto Sans Devanagari', 'sans-serif'],
      },
      borderRadius: {
        '2xl': '16px',
        '3xl': '24px',
      },
      boxShadow: {
        card: '0 2px 12px rgba(27,108,168,0.08)',
        'card-hover': '0 4px 20px rgba(27,108,168,0.14)',
      },
    },
  },
  plugins: [],
}

export default config
